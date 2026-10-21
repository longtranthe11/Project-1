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