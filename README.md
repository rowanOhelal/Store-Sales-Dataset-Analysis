# Store Sales Dataset Analysis - Graduation Project

Comprehensive end-to-end data analytics and predictive modeling project analyzing four years of retail store transactional data (2015–2018). The repository covers dimensional data modeling (Star Schema in PostgreSQL), data preprocessing, strategic exploratory data analysis, and machine learning time-series sales forecasting.

---

## Project Structure

```
Store-Sales-Dataset-Analysis/
├── data/
│   ├── raw/
│   │   └── Superstore Sales Dataset.csv       # Original raw dataset
│   └── processed/
│       └── superstore_clean.csv               # Cleaned & preprocessed dataset (9,799 rows)
├── docs/
│   ├── data_model.md                          # Week 1: Star Schema ERD & relational design
│   ├── analysis_questions.md                  # Week 2: Strategic business questions & findings
│   └── forecasting_questions.md               # Week 3: Predictive modeling & 2019 horizon forecast
├── notebooks/
│   ├── 1_data_preprocessing.ipynb             # Week 1: Cleaning, outlier detection, data export
│   ├── 2_exploratory_data_analysis.ipynb      # Week 2: EDA, business KPIs & Pareto analysis
│   └── 3_sales_forecasting.ipynb              # Week 3: Time-series modeling & ML forecasting
├── reports/
│   ├── cleaning_log.csv                       # Data cleaning audit log
│   └── figures/                               # Publication-quality visual artifacts
│       ├── 01_sales_distribution.png
│       ├── 02_sales_boxplot_by_category.png
│       ├── 03_ship_days_by_mode.png
│       ├── 04_monthly_sales.png
│       ├── 05_sales_by_category_and_subcategory.png
│       ├── 06_regional_sales_performance.png
│       ├── 07_top_and_bottom_states.png
│       ├── 08_customer_segmentation_analysis.png
│       ├── 09_shipping_mode_lead_times.png
│       ├── 10_annual_sales_and_yoy_growth.png
│       ├── 11_monthly_seasonality_patterns.png
│       ├── 12_product_pareto_curve.png
│       ├── 13_sales_time_series_decomposition.png
│       ├── 14_model_evaluation_actual_vs_predicted.png
│       ├── 15_feature_importance_forecasting.png
│       ├── 16_future_12_month_sales_forecast_2019.png
│       └── 17_category_level_sales_forecast_2019.png
├── sql/
│   ├── 1_schema.sql                           # Week 1: Star schema DDL, constraints & view
│   ├── 2_load_data.sql                        # Week 1: Staging table & dimension/fact loading
│   └── 3_analysis_questions.sql               # Week 2: Analytical SQL queries for decision makers
├── requirements.txt                           # Project dependencies
└── README.md
```

---

## Phase Breakdown

### Week 1: Data Model, Cleaning & Preprocessing
* **Status:** Completed (Intact, original files preserved).
* **Scope:** 
  - Automated cleaning and validation of 9,800 raw transactions down to 9,799 verified rows.
  - Designing a PostgreSQL Star Schema with `fact_sales` and 5 dimensions (`dim_customer`, `dim_product`, `dim_location`, `dim_ship_mode`, `dim_date`).
  - Creation of analytical reporting view `vw_sales_full`.

### Week 2: Analysis Questions Phase
* **Deliverables:**
  - `sql/3_analysis_questions.sql`: Comprehensive SQL queries answering key executive and operational questions.
  - `notebooks/2_exploratory_data_analysis.ipynb`: Complete Python EDA notebook with visualizations and statistical calculations.
  - `docs/analysis_questions.md`: Strategic report mapping business questions to analytical insights and recommendations.
  - Figures `05` through `12` in `reports/figures/`.
* **Key Findings:**
  - **Macro Benchmarks:** $2,261,255.41 total revenue across 4,922 orders; Average Order Value (AOV) of $459.42; average delivery lag of 3.96 days.
  - **Category Dominance:** Technology leads in dollar volume ($827.5K, 36.6% share) and highest average ticket size ($456.40). Office Supplies drives 60%+ of unit volume.
  - **Geographic Concentration:** California ($446.3K) and New York ($306.3K) generate 33.3% of national sales.
  - **Pareto Principle (80/20):** Top 22.4% of product SKUs generate 79.9% of total cumulative revenue.
  - **Customer Stickiness:** Repeat customers placing 6+ orders drive 88.4% of all revenue.

### Week 3: Forecasting Questions Phase
* **Deliverables:**
  - `notebooks/3_sales_forecasting.ipynb`: Time-series feature engineering, model training, evaluation, and recursive multi-step forecasting.
  - `docs/forecasting_questions.md`: Documentation of forecasting methodology, metric benchmarks, and demand planning guidelines.
  - Figures `13` through `17` in `reports/figures/`.
* **Methodology & Results:**
  - **Feature Pipeline:** 12-month seasonal lag (`lag_12`), short-term momentum lags (`lag_1`, `lag_2`, `lag_3`), 3-month rolling statistics, cyclical month encoding ($\sin$/$\cos$), and secular trend index.
  - **Model Benchmark (Held-Out 2018 Test Period):**
    - Gradient Boosting Regressor achieved the highest accuracy ($R^2 = 0.81$, MAE = $6,850$).
    - Random Forest Regressor ($R^2 = 0.77$, MAE = $7,420$).
    - Ridge Regression ($R^2 = 0.74$, MAE = $7,980$).
  - **Driver Attribution:** The 12-month seasonal lag (`lag_12`) accounts for over 42% of model feature importance.
  - **2019 Forecast Horizon:** Full-year 2019 projected sales reach ~$834,000 (+15.6% YoY growth), with November and December projected to exceed $115,000/month.

---

## Getting Started

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Run Database Scripts (PostgreSQL)
Execute in order:
1. `sql/1_schema.sql` (Creates schema and star schema tables)
2. `sql/2_load_data.sql` (Loads staging data and populates dimensions and fact table)
3. `sql/3_analysis_questions.sql` (Runs analytical queries)

### 3. Run Jupyter Notebooks
```bash
jupyter lab
```
Navigate to `notebooks/` and run:
- `1_data_preprocessing.ipynb`
- `2_exploratory_data_analysis.ipynb`
- `3_sales_forecasting.ipynb`
