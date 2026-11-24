# Week 2: Analysis Questions Phase

## 1. Executive Summary & Purpose

The objective of **Week 2** is to transition from data preparation to strategic business intelligence. By interrogating the cleaned Superstore sales dataset (9,799 transactions across 2015–2018), we formulate and answer critical questions that executive leaders, category managers, regional sales heads, and logistics planners need to optimize revenue, streamline operations, and enhance customer lifetime value.

The analysis is performed using:
- **SQL (PostgreSQL):** Scripts in `sql/3_analysis_questions.sql` targeting both the consolidated analytical view `vw_sales_full` and normalized star-schema tables (`fact_sales`, `dim_*`).
- **Python (pandas, seaborn, matplotlib):** Documented comprehensively in `notebooks/2_exploratory_data_analysis.ipynb`.
- **Visual Evidence:** High-resolution charts saved in `reports/figures/`.

---

## 2. Core Business Analysis Questions

### Category 1: Executive Financial & Operational KPIs
* **Question 1.1:** What is the overall macro performance of the Superstore across the 4-year lifecycle?
* **Business Stakeholder:** Chief Executive Officer (CEO), Chief Financial Officer (CFO).
* **Key Metrics:** Total Revenue, Total Distinct Orders, Total Line Items Sold, Average Order Value (AOV), Average Order-to-Ship Delivery Lag, Active Customers, Active Catalog Products.
* **Findings:**
  - Total Revenue: **\$2,261,255.41** across **4,922 unique orders** and 9,799 line items.
  - Average Order Value (AOV): **\$459.42** per order basket (Average single-line item value: **\$230.76**).
  - Average Shipping Time: **3.96 days** (Median 4 days).
  - Active Customer Base: **793 unique enterprise/retail clients** buying across **1,861 catalog SKUs**.

---

### Category 2: Product Category & Sub-Category Performance
* **Question 2.1:** Which product categories generate the highest total revenue, and how does item volume compare to gross dollars?
* **Question 2.2:** What are the top and bottom performing sub-categories within each category?
* **Business Stakeholder:** VP of Merchandising, Category Portfolio Managers.
* **Findings:**
  - **Technology:** Generates **\$827,455.87 (36.59% of total revenue)** with only 1,813 transactions. It carries the highest average ticket size (\$456.40), making it the most capital-efficient category.
  - **Furniture:** Generates **\$728,658.48 (32.22% of revenue)** from 2,077 transactions.
  - **Office Supplies:** Generates **\$705,141.06 (31.18% of revenue)** from 5,909 transactions (over 60% of total company unit volume). It is the high-velocity "traffic driver" with a lower ticket size (\$119.33).
  - **Top Sub-Categories:** **Phones** (\$327,782.45), **Chairs** (\$322,822.76), and **Storage** (\$219,343.39) collectively account for **38.5%** of all company revenue.
  - **Underperforming Sub-Categories:** **Fasteners** (\$3,001.96), **Envelopes** (\$16,354.20), and **Labels** (\$12,347.73) generate negligible sales volume.

---

### Category 3: Geographic & Regional Territory Dominance
* **Question 3.1:** How do sales and shipping speeds vary across geographic regions (West, East, Central, South)?
* **Question 3.2:** Which states drive 50%+ of all revenue, and which states show market underperformance?
* **Business Stakeholder:** VP of Sales, Regional Directors.
* **Findings:**
  - **West Region:** Top performer generating **\$710,219.68 (31.41%)** with an average fulfillment of 3.93 days.
  - **East Region:** Close second generating **\$669,520.89 (29.61%)** with 3.92 days delivery.
  - **Central Region:** Generated **\$492,646.91 (21.79%)** with 4.04 days delivery.
  - **South Region:** Lowest volume at **\$388,867.92 (17.20%)** with 3.98 days delivery.
  - **State Concentration:** **California** (\$446,306.46 / 19.74%) and **New York** (\$306,345.41 / 13.55%) alone generate **one-third (33.3%)** of national revenue. The top 5 states (CA, NY, TX, WA, PA) generate **52.6%** of all revenue.
  - **Cold Spots:** Wyoming (\$1,603.14), West Virginia (\$1,209.82), North Dakota (\$919.91) represent underpenetrated markets.

---

### Category 4: Customer Segmentation & VIP Accounts
* **Question 4.1:** How do sales distribute among Consumer, Corporate, and Home Office segments?
* **Question 4.2:** Who are the top 10 VIP accounts, and what is the rate of repeat business?
* **Business Stakeholder:** Chief Marketing Officer (CMO), Head of B2B Relationships.
* **Findings:**
  - **Consumer Segment:** Drives **50.6%** of revenue (\$1,144,733.91) across 409 customers.
  - **Corporate Segment:** Contributes **30.7%** (\$694,008.01) across 236 customers with higher basket stability.
  - **Home Office:** Contributes **18.7%** (\$422,513.48) across 148 accounts.
  - **Repeat Purchasing:** **98.2%** of customers placed multiple orders over the 4-year period. Customers placing 6+ orders generate **88.4%** of company revenue, indicating exceptional account stickiness.
  - **Top VIP Customer:** Sean Miller (\$25,043.05 across 15 orders), followed by Tamara Chand (\$19,052.22 across 12 orders).

---

### Category 5: Logistics & Fulfillment Performance
* **Question 5.1:** How are order volumes split among delivery tiers, and are shipping SLA commitments met?
* **Business Stakeholder:** VP of Supply Chain & Fulfillment.
* **Findings:**
  - **Standard Class:** Dominates with **59.7% of volume** (5,859 shipments); average transit: **5.01 days** (min 3, max 7).
  - **Second Class:** **19.4% of volume** (1,902 shipments); average transit: **3.24 days** (min 1, max 5).
  - **First Class:** **15.4% of volume** (1,501 shipments); average transit: **2.18 days** (min 1, max 4).
  - **Same Day:** **5.5% of volume** (537 shipments); average transit: **0.04 days** (96% delivered day 0, 4% delivered day 1).
  - **Bottlenecks:** Over 38% of Standard Class shipments experience 6 to 7 day delivery times.

---

### Category 6: Temporal Trends, Seasonality & Growth
* **Question 6.1:** Has the Superstore achieved sustained Year-over-Year (YoY) revenue growth?
* **Question 6.2:** Which quarters and months experience the sharpest seasonal demand spikes?
* **Business Stakeholder:** Financial Planning & Analysis (FP&A), Inventory Planning.
* **Findings:**
  - **Annual Revenue Trajectory:**
    - 2015: \$479,856.21
    - 2016: \$459,436.01 (-4.26% dip)
    - 2017: \$600,192.55 (+30.64% surge)
    - 2018: \$721,770.64 (+20.26% expansion)
  - Overall 4-year compound expansion represents **+50.4% revenue growth** from 2015 to 2018.
  - **Quarterly Seasonality:** **Q4 consistently accounts for 33.8% of annual sales**, whereas Q1 represents only 17.5%.
  - **Peak Months:** **November** (\$350,641 cumulative) and **December** (\$323,799 cumulative) represent the annual peak driven by holiday procurement and enterprise budget flush.

---

### Category 7: Revenue Concentration & Outlier Analysis (Pareto Principle)
* **Question 7.1:** Does the Pareto 80/20 rule hold true for the product catalog?
* **Question 7.2:** How much revenue is driven by high-value outlier transactions?
* **Business Stakeholder:** Commercial Operations & Risk Management.
* **Findings:**
  - **Product Pareto:** The top **22.4% of catalog SKUs** generate **79.9% of total cumulative sales**, confirming a classic 80/20 distribution.
  - **Outlier Impact:** While outliers (`is_sales_outlier = true`, sales > \$499.00) represent only **11.8% of transaction lines** (1,154 lines), they contribute **53.2% (\$1,203,721.40) of all company revenue**.

---

## 3. Actionable Strategic Recommendations

1. **Protect Technology and Core Sub-Categories:** Prioritize supplier contracts and safety stock for Phones, Chairs, and Storage to prevent stockouts during peak Q4.
2. **Rationalize Low-Performing SKUs:** Bundle low-velocity office supplies (Fasteners, Envelopes) into multi-packs or cross-sell bundles rather than standalone listings.
3. **Regional Fleet Hubs in California and New York:** Establish dedicated regional fulfillment hubs in CA and NY to decrease delivery lag on the top 33% of national volume.
4. **VIP Retention Program:** Establish dedicated account representatives for the top 50 corporate and consumer VIP accounts to secure contract renewals.
5. **Q4 Inventory Ramp-Up:** Build working capital and inventory buffers starting in August/September to capture the anticipated 45%+ surge during Q4.
