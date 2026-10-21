# STEP 2: Build a reproducible one-row-per-order dataset
needed <- c("readr", "dplyr", "lubridate")
missing_pkgs <- needed[!vapply(needed, requireNamespace, FUN.VALUE=logical(1), quietly=TRUE)]
if (length(missing_pkgs)) stop("Install packages: ", paste(missing_pkgs, collapse=", "))

orders <- readr::read_csv("data/raw/olist_orders_dataset.csv", show_col_types=FALSE)
items <- readr::read_csv("data/raw/olist_order_items_dataset.csv", show_col_types=FALSE)
reviews <- readr::read_csv("data/raw/olist_order_reviews_dataset.csv", show_col_types=FALSE)

cat("Orders:",nrow(orders),"items:",nrow(items),"reviews:",nrow(reviews),"\n")
cat("Orders with more than one review row:",
    sum(table(reviews$order_id)>1),"\n")

# An order may contain several items: combine prices and freight BEFORE joining.
item_summary <- items |>
  dplyr::group_by(order_id) |>
  dplyr::summarise(total_item_price=sum(price,na.rm=TRUE),
                   total_freight=sum(freight_value,na.rm=TRUE),
                   num_items=dplyr::n(), .groups="drop")

# When an order has several review rows, take the earliest dated review.
# Alternate policies should be assessed later for sensitivity.
review_summary <- reviews |>
  dplyr::filter(!is.na(review_score)) |>
  dplyr::arrange(order_id, review_creation_date, review_answer_timestamp) |>
  dplyr::group_by(order_id) |>
  dplyr::slice(1) |>
  dplyr::ungroup() |>
  dplyr::select(order_id, review_score, review_creation_date, review_answer_timestamp)

stopifnot(!anyDuplicated(orders$order_id),
          !anyDuplicated(item_summary$order_id),
          !anyDuplicated(review_summary$order_id))

# Joining from order grain, not items grain, prevents duplicate order observations.
joined <- orders |>
  dplyr::left_join(item_summary, by="order_id") |>
  dplyr::left_join(review_summary, by="order_id")
stopifnot(nrow(joined)==nrow(orders), !anyDuplicated(joined$order_id))

# Construct dates with the same conventions used throughout the analysis.
joined <- joined |>
  dplyr::mutate(purchase_dt=lubridate::ymd_hms(order_purchase_timestamp, quiet=TRUE),
                delivered_dt=lubridate::ymd_hms(order_delivered_customer_date, quiet=TRUE),
                estimated_dt=lubridate::ymd_hms(order_estimated_delivery_date, quiet=TRUE),
                delivery_days=as.numeric(difftime(delivered_dt, purchase_dt, units="days")),
                days_late=pmax(0, as.numeric(as.Date(delivered_dt)-as.Date(estimated_dt))),
                late_delivery=as.integer(as.Date(delivered_dt)>as.Date(estimated_dt)),
                freight_ratio=total_freight / dplyr::if_else(total_item_price>0, total_item_price, NA_real_),
                low_rating=dplyr::if_else(is.na(review_score), NA_integer_, as.integer(review_score<=2)),
                purchase_month=format(purchase_dt,"%Y-%m"))

cat("Delivered orders before complete-case filters:", sum(joined$order_status=="delivered", na.rm=TRUE),"\n")
analysis <- joined |>
  dplyr::filter(order_status=="delivered",
                !is.na(delivered_dt),!is.na(estimated_dt), !is.na(purchase_dt),
                !is.na(review_score),!is.na(total_item_price),total_item_price>0,
                !is.na(total_freight), total_freight>=0,
                !is.na(delivery_days), delivery_days>=0,
                !is.na(freight_ratio), is.finite(freight_ratio)) |>
  dplyr::select(order_id, review_score, low_rating, late_delivery, days_late,
                delivery_days, total_item_price, total_freight, freight_ratio,
                num_items, purchase_dt, purchase_month, delivered_dt, estimated_dt)
stopifnot(!anyDuplicated(analysis$order_id))
cat("Analysis orders:",nrow(analysis),"\n")
cat("Share with low ratings:",round(mean(analysis$low_rating)*100,2),"%\n")
cat("Share delivered late:",round(mean(analysis$late_delivery)*100,2),"%\n")
cat("Freight ratio quantiles:\n")
print(stats::quantile(analysis$freight_ratio, c(0,.25,.50,.75,.95,.99,1)))
dir.create("data/processed", recursive=TRUE, showWarnings=FALSE)
readr::write_csv(analysis,"data/processed/olist_analysis_orders.csv")
cat("Saved data/processed/olist_analysis_orders.csv\n")
