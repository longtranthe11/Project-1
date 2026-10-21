# Planned analytical data dictionary

| Variable | Construction | Unit |
|---|---|---|
| order_id | unique identifier for purchase | string |
| review_score | Olist review score | integer, 1–5 |
| low_rating | review_score <= 2 | 0/1 |
| order_purchase_timestamp | order datetime | timestamp |
| order_delivered_customer_date | actual receipt datetime | timestamp |
| order_estimated_delivery_date | estimate shown at purchase | timestamp |
| delivery_days | actual receipt minus purchase | days (may be fractional) |
| days_late | max(0, actual delivery calendar date minus estimated calendar date) | days |
| late_delivery | actual delivery calendar date > estimated calendar date | 0/1 |
| total_item_price | sum(price) over all order items | Brazilian real (BRL) |
| total_freight | sum(freight_value) over all order items | BRL |
| freight_ratio | total_freight / total_item_price, if positive | unitless |
| num_items | count of order item rows | integer |
| purchase_month | year-month of purchase | YYYY-MM |

Ensure `order_id` is unique after join. Check and document distributions and outliers before fitting regression.
