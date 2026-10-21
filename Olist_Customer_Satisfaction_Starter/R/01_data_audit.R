# STEP 1: Audit the original Olist CSVs (no cleaning yet)
needed <- c("readr", "dplyr")
missing_pkgs <- needed[!vapply(needed, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)]
if (length(missing_pkgs)) stop("Install packages: install.packages(c(", paste(shQuote(missing_pkgs), collapse=", "), "))")

raw_dir <- "data/raw"
files <- c("olist_orders_dataset.csv", "olist_order_items_dataset.csv", "olist_order_reviews_dataset.csv")
paths <- file.path(raw_dir, files)
if (!all(file.exists(paths))) {
  stop("Missing required files in data/raw/: ", paste(files[!file.exists(paths)], collapse=", "),
       "\nDownload from https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce")
}

dir.create("outputs", showWarnings=FALSE, recursive=TRUE)
for (i in seq_along(files)) {
  data <- readr::read_csv(paths[i], show_col_types=FALSE)
  cat("\n=== ", files[i], " ===\n", sep="")
  cat("Rows:", nrow(data), " Columns:", ncol(data), "\n")
  print(utils::head(data, 3))
  audit <- data.frame(column=names(data),
                      type=vapply(data, function(x) paste(class(x), collapse="/"), character(1)),
                      missing_n=vapply(data, function(x) sum(is.na(x)), integer(1)),
                      missing_pct=round(100*vapply(data, function(x) mean(is.na(x)), numeric(1)),2))
  print(audit)
  stem <- sub("\\.csv$", "", files[i])
  readr::write_csv(audit, file.path("outputs", paste0(stem, "_audit.csv")))
  if ("order_id" %in% names(data)) {
    cat("Distinct order IDs:", dplyr::n_distinct(data$order_id), "\n")
    cat("Rows beyond distinct order IDs:", nrow(data) - dplyr::n_distinct(data$order_id), "\n")
  }
}
cat("\nStep 1 complete. See the three *_audit.csv files inside outputs/.\n")
