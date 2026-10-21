install.packages(c(
  "readr",
  "dplyr",
  "ggplot2",
  "lubridate"
))
source("R/01_data_audit.R")
source("R/02_build_order_level_data.R")
source("R/03_first_visualization.R")

dat <- readr::read_csv(
  "data/processed/olist_analysis_orders.csv",
  show_col_types = FALSE
)

dat |>
  dplyr::select(
    order_id, total_item_price, total_freight,
    freight_ratio, review_score
  ) |>
  dplyr::arrange(dplyr::desc(freight_ratio)) |>
  head(10)

comparison <- dat |>
  dplyr::mutate(
    freight_quartile = dplyr::ntile(freight_ratio, 4),
    delivery_group = dplyr::if_else(
      late_delivery == 1,
      "Late",
      "On time"
    )
  ) |>
  dplyr::group_by(delivery_group, freight_quartile) |>
  dplyr::summarise(
    n = dplyr::n(),
    low_rating_pct = round(100 * mean(low_rating), 2),
    .groups = "drop"
  )

print(comparison)


model_dat <- dat |>
  dplyr::mutate(
    freight_10pp = freight_ratio / 0.10,
    log_order_value = log(total_item_price)
  )

# Model 1: 
m1 <- lm(
  low_rating ~ late_delivery,
  data = model_dat
)

# Model 2
m2 <- lm(
  low_rating ~ late_delivery + freight_10pp,
  data = model_dat
)

# Model 3
m3 <- lm(
  low_rating ~ late_delivery + freight_10pp +
    log_order_value + num_items + factor(purchase_month),
  data = model_dat
)

install.packages(c("lmtest", "sandwich"))

lmtest::coeftest(m1, vcov. = sandwich::vcovHC(m1, type = "HC1"))

lmtest::coeftest(m2, vcov. = sandwich::vcovHC(m2, type = "HC1"))

result_m3 <- lmtest::coeftest(m3, vcov. = sandwich::vcovHC(m3, type = "HC1"))

result_m3[c("late_delivery", "freight_10pp"), , drop = FALSE]
