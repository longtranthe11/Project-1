# STEP 3: First visualization (descriptive only, NOT causal)
needed <- c("readr", "dplyr", "ggplot2")
missing_pkgs <- needed[!vapply(needed, requireNamespace, FUN.VALUE=logical(1), quietly=TRUE)]
if (length(missing_pkgs)) stop("Install packages: ", paste(missing_pkgs,collapse=", "))
if (!file.exists("data/processed/olist_analysis_orders.csv")) {
  stop("First run source('R/02_build_order_level_data.R')")
}
dat <- readr::read_csv("data/processed/olist_analysis_orders.csv",show_col_types=FALSE)

# Compare low-review shares among late vs on-time deliveries.
p <- dat |>
  dplyr::group_by(late_delivery) |>
  dplyr::summarise(n=dplyr::n(), low_rating_rate=mean(low_rating), .groups="drop") |>
  dplyr::mutate(group=ifelse(late_delivery==1,"Delivered late","On or before estimate")) |>
  ggplot2::ggplot(ggplot2::aes(x=group,y=low_rating_rate)) +
  ggplot2::geom_col(fill="#3274ab",width=.6) +
  ggplot2::geom_text(ggplot2::aes(label=paste0(round(low_rating_rate*100,1),"% (n=",n,")")),
                     vjust=-.4,size=3.5) +
  ggplot2::scale_y_continuous(labels=function(x)paste0(round(100*x),"%"), limits=c(0,NA),expand=ggplot2::expansion(mult=c(0,.15))) +
  ggplot2::labs(title="Low review ratings and delivery timeliness",subtitle="Olist delivered and reviewed orders; descriptive comparison",
                x=NULL,y="Share of 1–2 star reviews") +
  ggplot2::theme_minimal(base_size=12)
print(p)
dir.create("outputs",recursive=TRUE,showWarnings=FALSE)
ggplot2::ggsave("outputs/late_delivery_low_rating.png", p, width=8,height=5,dpi=180)
cat("Saved outputs/late_delivery_low_rating.png\n")

# Summarize freight-cost burden using four similarly sized groups.
freight_groups <- dat |>
  dplyr::mutate(freight_quartile=dplyr::ntile(freight_ratio,4)) |>
  dplyr::group_by(freight_quartile) |>
  dplyr::summarise(n=dplyr::n(), low_rating_rate=mean(low_rating), median_ratio=median(freight_ratio), .groups="drop")
print(freight_groups)
readr::write_csv(freight_groups,"outputs/freight_quartile_summary.csv")
