# What Matters More: Fast Delivery or Low Shipping Fees?

Research project starter | Programming for Business Analytics | 2026

## Research question
How are delivery performance and shipping costs associated with customer satisfaction in Brazilian e-commerce, after accounting for order characteristics?

**Scope:** Olist Brazilian E-Commerce Public Dataset (~100,000 orders, 2016-2018). The study is correlational; conclusions about causal effects cannot be made from these data.

## Step 1 — Obtain the data
Download **Brazilian E-Commerce Public Dataset by Olist** from:
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Unzip into `data/raw/` and keep the original file names. Minimum three files:
- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_order_reviews_dataset.csv`

Optional later: customers, products, sellers, category translations for additional controls and subgroup analyses.

## Step 2 — Open in RStudio
From RStudio: File > New Project > Existing Directory, select this directory.
Run in the Console:

```r
install.packages(c("readr", "dplyr", "ggplot2", "lubridate"))
source("R/01_data_audit.R")
```

After confirming field names and issues:

```r
source("R/02_build_order_level_data.R")
source("R/03_first_visualization.R")
```

Output files are placed in `outputs/`, derived files in `data/processed/`.

## Data construction rules
- **Observation unit:** ONE delivered, reviewed order (not an order item).
- Sum price and freight across order items **BEFORE** joining to orders and reviews.
- For orders with multiple review records, the starter takes the chronologically **first** observed review and reports how frequently this issue occurs. Validate and test sensitivity later.
- `late_delivery`: actual delivery calendar DATE is after the **estimated delivery date**, not a strict time comparison; same-day delivery is on time.
- `freight_ratio = total_freight / total_item_price` and `low_rating = 1` for 1–2 stars.
- Keep missingness visible in audit. Filtering to delivered/reviewed orders creates sample selection; disclose it.
- No claim that shipping costs or delays *cause* low ratings without stronger identification.

## License and reproducibility
The original dataset is attributed to Olist and is distributed under CC BY-NC-SA 4.0. Link to Kaggle rather than committing raw CSVs to your public GitHub repository. Dataset source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## Plan
1. 21 Oct: audit CSV structure and missingness.
2. 22 Oct: verify joins and define unit of analysis.
3. 23 Oct: produce initial descriptive graph; state hypothesis and limitations.
4. 24 Oct: write proposal and commit code/docs to GitHub.
5. 25 Oct: submit data and proposal.

See `Proposal_Draft.md` and `Data_Dictionary.md`.
