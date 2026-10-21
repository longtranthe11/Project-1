# Proposal Draft (for discussion — not yet a final proposal)

## Working title
**What Matters More: Fast Delivery or Low Shipping Fees? Delivery Performance, Freight Costs, and Customer Satisfaction in Brazilian E-Commerce**

## Motivation and business relevance
Online retailers must decide whether to prioritize delivery reliability or reduce shipping fees. Both may be associated with how customers rate their shopping experience, but delivery lateness and freight cost represent different dimensions of the customer experience. Studying their relationship with review ratings can inform operations and customer-experience strategy.

## Main research question
**How are delivery performance and shipping costs associated with customer satisfaction in Brazilian e-commerce, after accounting for differences in order characteristics?**

## Hypotheses
- **H1:** Orders delivered after the estimated delivery date are associated with a higher probability of low review scores (1–2 stars).
- **H2:** Orders with a higher freight-cost-to-item-price ratio are associated with a higher probability of low review scores.
- **H3:** The associations differ in magnitude when expressed as comparable predicted differences in low-rating probability. We will **not** compare raw model coefficients with different units.

## Data source
Olist Brazilian E-Commerce Public Dataset (Kaggle), 2016–2018 (~100,000 orders), with linked orders, order items, and reviews tables. Original source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## Unit of analysis and scope
One completed/delivered order with a nonmissing review score and sufficiently complete delivery and monetary data. Raw item-level data will be aggregated to the order level prior to merging; multiple reviews for an order will be inspected and handled consistently. We will report the number of records excluded at each step.

## Main variables
- **Outcome:** `low_rating` = 1 if review score is 1–2 stars; 0 if 3–5 stars. Alternative outcome: 1–5 review score.
- **Delivery predictor:** `late_delivery` = 1 if delivered AFTER the estimated calendar date; alternative: positive days late.
- **Freight predictor:** `freight_ratio` = (sum of freight fees in the order)/(sum of item prices in the order). Also test absolute freight value.
- **Controls:** item price, item count, purchase month; later add customer state/product category if clean merges are possible.

## Methodology
1. Audit raw data completeness, key uniqueness and join cardinality.
2. Aggregate item prices and freight to order level and construct indicators.
3. Visualize review-score distribution, low-rating share for late vs on-time deliveries, and low-rating share by freight-ratio groups.
4. Fit an interpretable baseline regression, optionally a logistic model for low-rating probability, with controls.
5. Report uncertainty, diagnostics, alternatives to the selected outcome/threshold, and limitations. Compare *standardized changes in predicted low-rating probability*, not different-unit coefficients.

## Cautions
- **Not causal:** Delivery and fees may be correlated with seller quality, product type and geography.
- **Selection:** Restricting to delivered orders with observed reviews changes the population being analyzed.
- **Data vintage:** Transactions were in 2016–2018, so relevance to current 2026 e-commerce is limited.
- **Endogenous reviews:** Review scores can reflect product quality and other experiences, not only delivery and freight.
- **Survey timing:** Confirm dates of reviews relative to delivery where possible; survey could be sent by estimated date even if goods weren't received.
- **Potential exposure confounding:** If we lack competitors/alternative fees, results reflect observed fees, not a randomized consumer choice.

## Portfolio output
A reproducible R repository and Quarto webpage explaining motivation, data pipeline, visuals, models, business implications, and research limitations.

## To verify before proposal submission
- [ ] Successfully import 3 CSVs in RStudio
- [ ] Identify whether each order has exactly one review; choose and justify duplicates policy
- [ ] Record delivered-order sample size and missingness by variable
- [ ] Inspect freight-ratio extremes and delivery-date logic
- [ ] Generate at least one descriptive visualization from actual data
- [ ] Verify interpretation of results; do not write invented findings
