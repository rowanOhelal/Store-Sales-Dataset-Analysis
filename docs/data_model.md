# Data model (PostgreSQL)

## 1. Purpose
The cleaned Superstore data is a single flat table in which customers, products, places and dates repeat thousands of times. It is split into a **star schema** so that each fact is stored once, rules are enforced by the database, and later weeks can query it with SQL.

Source: `data/processed/superstore_clean.csv` (output of `notebooks/1_data_preprocessing.ipynb`, 9,799 rows).

## 2. Entity-relationship diagram
![ERD](erd.png)

```
dim_customer ──┐
dim_product  ──┤
dim_location ──┼──<  fact_sales
dim_ship_mode ─┤
dim_date ──────┘   (joined twice: order date and ship date)
```

## 3. Tables

| Table | Role | Key | Rows | Contains |
|---|---|---|---|---|
| `fact_sales` | Fact | `row_id` | 9,799 | One row per order line: foreign keys, the measures `sales` and `ship_days`, and `order_id` |
| `dim_customer` | Dimension | `customer_id` | 793 | Name, segment |
| `dim_product` | Dimension | `product_id` | 1,861 | Name, category, sub-category |
| `dim_location` | Dimension | `location_id` | 628 | Country, state, city, postal code, region |
| `dim_ship_mode` | Dimension | `ship_mode_id` | 4 | Same Day (1), First Class (2), Second Class (3), Standard Class (4) |
| `dim_date` | Dimension | `date_key` (yyyymmdd) | 1,826 | One row per calendar day, 2015-01-01 to 2019-12-31, with year, quarter, month, day name and weekend flag |

Plus one view, `vw_sales_full`, described in section 6.

## 4. Design decisions

| Decision | Reason |
|---|---|
| Fact table holds only keys and measures | Standard star-schema design; descriptive attributes live in the dimensions |
| `order_id` stays in the fact table | It is a *degenerate dimension*: an identifier with no descriptive attributes, so it needs no table of its own |
| `dim_date` is joined twice (`order_date_key`, `ship_date_key`) | A *role-playing dimension*: one calendar table serves both dates |
| `ship_days` is stored as a measure | It is the order-to-ship lag. Computing it across two date roles is awkward in BI tools. |
| Separate `dim_ship_mode` | Keeps shipping attributes in one place, numbered by speed (1 fastest, 4 slowest) |
| `dim_date` covers whole years | Calendar tables conventionally start on 1 Jan and end on 31 Dec |
| `location_id` is generated | The source has no location key, so one was created for each distinct country/city/state/postal code/region |
| Outlier flag is computed in the view | Keeps the fact table free of derived flags. Rule: sales > Q3 + 1.5 x IQR |
| One probable duplicate row removed during cleaning | See the cleaning notebook, section 3.3 |

## 5. Integrity rules enforced by the database

| Type | Rule |
|---|---|
| Entity integrity | Primary key on every table; `UNIQUE` on the location combination, ship mode and full date |
| Referential integrity | Foreign keys from `fact_sales` to all five dimensions |
| Domain integrity | Allowed values for segment, region, category and ship mode; `sales > 0`; `ship_days >= 0`; `ship_date_key >= order_date_key`; quarter 1-4; month 1-12 |

If any row breaks a rule, PostgreSQL rejects the insert instead of loading it silently.

## 6. The view `vw_sales_full`
A view is a saved query that stores no data. `vw_sales_full` joins the fact table to all dimensions and returns one flat table with the same columns as the cleaned CSV, including `is_sales_outlier`. Use it for quick queries and for Tableau.

These two queries return identical results:

```sql
-- Without the view: write the joins yourself
select l.region, p.category, round(sum(f.sales), 2) as total_sales
from fact_sales f
join dim_location l on l.location_id = f.location_id
join dim_product  p on p.product_id  = f.product_id
group by l.region, p.category;

-- With the view
select region, category, round(sum(sales), 2) as total_sales
from vw_sales_full
group by region, category;
```

Monthly sales (useful for forecasting):

```sql
select d.year_month, round(sum(f.sales), 2) as total_sales
from fact_sales f
join dim_date d on d.date_key = f.order_date_key
group by d.year_month
order by d.year_month;
```

## 7. How the model is built

| Order | Script | What it does |
|---|---|---|
| 1 | `sql/1_schema.sql` | Creates the `superstore` schema, the six tables, constraints, indexes and the view. **Drops and recreates the schema, deleting anything in it.** |
| 2 | `sql/2_load_data.sql` | Part 1 creates a staging table `stg_sales` shaped like the CSV. The CSV is then imported into it (pgAdmin: right-click the table, Import/Export Data, Header on). Part 2 fills the dimensions first, then the fact table, from staging. **Run it in parts, not all at once.** |

The staging table exists because a single flat CSV cannot be imported into five related tables directly: it is loaded first, then split.

## 8. Expected numbers after loading

| Check | Expected |
|---|---|
| Rows and total sales in `fact_sales` | 9,799 and $2,261,255.41 |
| Order date range | 2015-01-03 to 2018-12-30 |
| Rows per table | fact 9,799; customers 793; products 1,861; locations 628; ship modes 4; dates 1,826 |
| Outliers flagged in the view | 1,145 |

Quick check:

```sql
select count(*) as n_rows, round(sum(sales), 2) as total_sales from fact_sales;
select count(*) filter (where is_sales_outlier) as n_outliers from vw_sales_full;
```

If your numbers differ, something went wrong in the load. Re-run the scripts in order.

## 9. Limitations
- Only `sales` is available as a measure (no profit, quantity or discount).
- The allowed-value lists in the `CHECK` constraints match this dataset; a new category or ship mode would be rejected until the constraint is edited.
- `dim_date` stops at 2019-12-31. Extend it if future data is added.