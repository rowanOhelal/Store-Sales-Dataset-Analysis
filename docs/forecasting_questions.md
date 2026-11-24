# Week 3: Forecasting Questions Phase

## 1. Executive Summary & Purpose

The objective of **Week 3** is to transition from retrospective historical analytics (Weeks 1 & 2) into prospective predictive modeling. Utilizing the 48 months of cleaned transaction data (2015–2018), we formulate targeted forecasting questions and construct predictive models to forecast future sales trajectories, quantify demand uncertainty, and inform executive supply chain and procurement decisions.

Tools utilized:
- **Python (scikit-learn, pandas, numpy, matplotlib, seaborn)**
- Notebook: `notebooks/3_sales_forecasting.ipynb`
- Graphical Deliverables: Publication-quality visualizations saved to `reports/figures/`.

---

## 2. Core Business Forecasting Questions

### Question 3.1: Macro Sales Trajectory (Next 12-Month Horizon)
* **Question:** What is the projected monthly sales trajectory for the Superstore across the upcoming 12-month period (2019), and what is the expected full-year revenue?
* **Business Stakeholder:** Chief Financial Officer (CFO), Board of Directors, Executive Leadership.
* **Why It Matters:** Enables accurate annual budgeting, operational expense allocation, and top-line financial guidance for investors.
* **Key Methodology:**
  - Construct an out-of-sample recursive time-series forecasting pipeline using the best-performing model trained on 2015–2018 data.
  - Predict monthly sales for Jan 2019 through Dec 2019.

---

### Question 3.2: Category-Level Demand & Volatility Divergence
* **Question:** How do future sales trajectories differ across Technology, Furniture, and Office Supplies? Which categories exhibit stable baseline demand versus severe seasonal volatility?
* **Business Stakeholder:** VP of Merchandising, Supply Chain Inventory Managers.
* **Why It Matters:** Different categories have vastly different lead times and inventory carrying costs. Technology components require international procurement lead times of 3–5 months, whereas Office Supplies can be replenished in weeks.
* **Key Methodology:**
  - Separate monthly series by Category.
  - Model category-specific trends, seasonal indices, and forecast intervals.

---

### Question 3.3: Model Architecture Benchmark & Selection
* **Question:** Which machine learning architecture achieves the best predictive accuracy on held-out test data (2018 test period)?
  - Models evaluated:
    1. **Seasonal Naïve Baseline:** Uses exact same month of prior year ($Y_{t-12}$).
    2. **Ridge Regression:** Linear model with L2 regularization and polynomial/cyclical features.
    3. **Random Forest Regressor:** Non-linear ensemble of decision trees capturing interactions.
    4. **Gradient Boosting Regressor:** Sequential boosting optimizing residual errors.
* **Evaluation Metrics:**
  - **MAE (Mean Absolute Error):** Average magnitude of forecasting errors in dollars.
  - **RMSE (Root Mean Squared Error):** Penalizes large deviations heavily.
  - **MAPE (Mean Absolute Percentage Error):** Relative percentage deviation.
  - **$R^2$ (Coefficient of Determination):** Proportion of variance explained by the model.

---

### Question 3.4: Temporal Drivers & Feature Attribution
* **Question:** What are the dominant drivers of monthly sales variance? Is demand primarily dictated by long-term secular growth, annual seasonality, or short-term trailing momentum?
* **Business Stakeholder:** Demand Planners, Marketing Campaign Leads.
* **Feature Engineering:**
  - **Lag Features:** $t-1$, $t-2$, $t-3$ (short-term momentum), and $t-12$ (year-over-year seasonal lag).
  - **Rolling Window Statistics:** 3-month rolling mean and 3-month rolling standard deviation.
  - **Calendar & Cyclical Signals:** Month of year, Quarter, Cyclical Sine/Cosine transformations ($\sin(2\pi m / 12)$, $\cos(2\pi m / 12)$).
  - **Deterministic Trend Index:** Continuous time step $t \in [1, 48]$ modeling business expansion.

---

### Question 3.5: Supply Chain Buffers & Risk Management
* **Question:** What safety stock buffers and fulfillment capacity adjustments are required during peak Q4 surges to guarantee a 98%+ order fulfillment rate without stockouts?
* **Business Stakeholder:** VP of Supply Chain & Logistics Operations.
* **Why It Matters:** Peak sales in November and December are 2.5x to 3x higher than trough months in January and February. Misforecasting Q4 leads to either lost customer orders or costly emergency express shipping.

---

## 3. Modeling Methodology & Validation Strategy

1. **Aggregation & Preprocessing:**
   - Transactional fact records aggregated by `year_month` into monthly totals.
   - Complete 48 continuous months (Jan 2015 to Dec 2018).
2. **Strict Temporal Split (No Lookahead Bias):**
   - **Training Set:** Jan 2015 – Dec 2017 (36 months, 75% of data).
   - **Test Set (Held-Out Evaluation):** Jan 2018 – Dec 2018 (12 months, 25% of data).
   - Models are fitted strictly on the training set and evaluated on the out-of-sample 2018 test set.
3. **Recursive Out-of-Sample Forecasting (2019):**
   - The selected champion model is retrained on the full 2015–2018 dataset and used to recursively generate 12 monthly step forecasts for 2019.

---

## 4. Deliverables Index

| Deliverable | Location | Description |
|---|---|---|
| **Forecasting Notebook** | `notebooks/3_sales_forecasting.ipynb` | Complete end-to-end Python pipeline from feature extraction to model training, benchmarking, and 2019 forecast generation |
| **Forecasting Documentation** | `docs/forecasting_questions.md` | Strategic report outlining questions, methodology, model scores, and recommendations |
| **Time Series Decomposition Plot** | `reports/figures/12_sales_time_series_decomposition.png` | Historical sales, trend line, and seasonal cycle visualization |
| **Model Comparison Plot** | `reports/figures/13_model_predictions_vs_actual.png` | Test set actuals vs. predictions for all candidate models |
| **Feature Importance Plot** | `reports/figures/14_feature_importance_forecasting.png` | Top predictive drivers of monthly store revenue |
| **12-Month Future Forecast Plot** | `reports/figures/15_future_12_month_sales_forecast.png` | Projected 2019 monthly revenue with confidence / prediction intervals |
| **Category Forecast Plot** | `reports/figures/16_category_level_sales_forecast.png` | Projected trajectory breakdown for Technology, Furniture, and Office Supplies |
