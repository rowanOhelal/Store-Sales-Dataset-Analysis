SET search_path TO superstore, public;

SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(row_id) AS total_order_lines,
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(AVG(sales), 2) AS average_order_line_value,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value_aov,
    ROUND(AVG(ship_days), 2) AS avg_delivery_days,
    COUNT(DISTINCT customer_id) AS active_customer_base,
    COUNT(DISTINCT product_id) AS active_products_sold
FROM vw_sales_full;

SELECT 
    category,
    COUNT(row_id) AS total_transactions,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS avg_sale_per_item,
    ROUND(100.0 * SUM(sales) / (SELECT SUM(sales) FROM vw_sales_full), 2) AS pct_revenue_contribution
FROM vw_sales_full
GROUP BY category
ORDER BY total_sales DESC;

WITH subcat_summary AS (
    SELECT 
        p.category,
        p.sub_category,
        COUNT(f.row_id) AS order_lines_count,
        ROUND(SUM(f.sales), 2) AS total_sales,
        ROUND(AVG(f.sales), 2) AS avg_ticket_size,
        DENSE_RANK() OVER (PARTITION BY p.category ORDER BY SUM(f.sales) DESC) AS rank_within_category
    FROM fact_sales f
    JOIN dim_product p ON p.product_id = f.product_id
    GROUP BY p.category, p.sub_category
)
SELECT 
    category,
    sub_category,
    order_lines_count,
    total_sales,
    avg_ticket_size,
    rank_within_category,
    ROUND(100.0 * total_sales / (SELECT SUM(sales) FROM fact_sales), 2) AS pct_total_business
FROM subcat_summary
ORDER BY category, total_sales DESC;

SELECT 
    l.region,
    COUNT(DISTINCT f.order_id) AS unique_orders,
    ROUND(SUM(f.sales), 2) AS total_sales,
    ROUND(AVG(f.sales), 2) AS avg_order_line,
    ROUND(AVG(f.ship_days), 2) AS avg_regional_shipping_days,
    ROUND(100.0 * SUM(f.sales) / (SELECT SUM(sales) FROM fact_sales), 2) AS pct_of_total_sales
FROM fact_sales f
JOIN dim_location l ON l.location_id = f.location_id
GROUP BY l.region
ORDER BY total_sales DESC;

SELECT 
    region,
    ROUND(SUM(CASE WHEN category = 'Technology' THEN sales ELSE 0 END), 2) AS technology_sales,
    ROUND(SUM(CASE WHEN category = 'Furniture' THEN sales ELSE 0 END), 2) AS furniture_sales,
    ROUND(SUM(CASE WHEN category = 'Office Supplies' THEN sales ELSE 0 END), 2) AS office_supplies_sales,
    ROUND(SUM(sales), 2) AS total_regional_sales,
    ROUND(100.0 * SUM(CASE WHEN category = 'Technology' THEN sales ELSE 0 END) / SUM(sales), 1) AS tech_share_pct
FROM vw_sales_full
GROUP BY region
ORDER BY total_regional_sales DESC;

SELECT 
    state,
    region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(100.0 * SUM(sales) / (SELECT SUM(sales) FROM vw_sales_full), 2) AS national_sales_share_pct
FROM vw_sales_full
GROUP BY state, region
ORDER BY total_sales DESC
LIMIT 10;

SELECT 
    state,
    region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales
FROM vw_sales_full
GROUP BY state, region
ORDER BY total_sales ASC
LIMIT 10;

SELECT 
    segment,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(sales) / COUNT(DISTINCT customer_id), 2) AS revenue_per_customer,
    ROUND(100.0 * SUM(sales) / (SELECT SUM(sales) FROM vw_sales_full), 2) AS revenue_share_pct
FROM vw_sales_full
GROUP BY segment
ORDER BY total_revenue DESC;

SELECT 
    c.customer_id,
    c.customer_name,
    c.segment,
    COUNT(DISTINCT f.order_id) AS order_frequency,
    COUNT(f.row_id) AS total_items_purchased,
    ROUND(SUM(f.sales), 2) AS lifetime_value_sales,
    ROUND(AVG(f.sales), 2) AS avg_item_price
FROM fact_sales f
JOIN dim_customer c ON c.customer_id = f.customer_id
GROUP BY c.customer_id, c.customer_name, c.segment
ORDER BY lifetime_value_sales DESC
LIMIT 10;

WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(sales) AS total_spend
    FROM fact_sales
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN '1 Order (One-Time)'
        WHEN order_count BETWEEN 2 AND 5 THEN '2-5 Orders (Occasional)'
        WHEN order_count BETWEEN 6 AND 10 THEN '6-10 Orders (Frequent)'
        ELSE '11+ Orders (Loyal VIP)'
    END AS purchase_frequency_tier,
    COUNT(customer_id) AS customer_count,
    ROUND(SUM(total_spend), 2) AS total_revenue,
    ROUND(100.0 * COUNT(customer_id) / (SELECT COUNT(*) FROM customer_orders), 1) AS pct_of_customers,
    ROUND(100.0 * SUM(total_spend) / (SELECT SUM(sales) FROM fact_sales), 1) AS pct_of_revenue
FROM customer_orders
GROUP BY 1
ORDER BY total_revenue DESC;

SELECT 
    sm.ship_mode,
    COUNT(f.row_id) AS packages_shipped,
    ROUND(SUM(f.sales), 2) AS total_revenue_handled,
    ROUND(AVG(f.sales), 2) AS avg_shipment_value,
    ROUND(AVG(f.ship_days), 2) AS avg_delivery_days,
    MIN(f.ship_days) AS min_days,
    MAX(f.ship_days) AS max_days,
    ROUND(100.0 * SUM(CASE WHEN f.ship_days > 5 THEN 1 ELSE 0 END) / COUNT(f.row_id), 2) AS delayed_orders_rate_pct
FROM fact_sales f
JOIN dim_ship_mode sm ON sm.ship_mode_id = f.ship_mode_id
GROUP BY sm.ship_mode
ORDER BY avg_delivery_days ASC;

WITH annual_sales AS (
    SELECT 
        d.year,
        COUNT(DISTINCT f.order_id) AS total_orders,
        ROUND(SUM(f.sales), 2) AS total_sales
    FROM fact_sales f
    JOIN dim_date d ON d.date_key = f.order_date_key
    GROUP BY d.year
)
SELECT 
    year,
    total_orders,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year) AS prior_year_sales,
    ROUND(100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY year)) / 
          NULLIF(LAG(total_sales) OVER (ORDER BY year), 0), 2) AS yoy_growth_rate_pct
FROM annual_sales
ORDER BY year;

SELECT 
    d.quarter,
    COUNT(f.row_id) AS order_lines,
    ROUND(SUM(f.sales), 2) AS total_sales,
    ROUND(100.0 * SUM(f.sales) / (SELECT SUM(sales) FROM fact_sales), 2) AS quarterly_share_pct,
    ROUND(AVG(f.sales), 2) AS avg_sale_per_item
FROM fact_sales f
JOIN dim_date d ON d.date_key = f.order_date_key
GROUP BY d.quarter
ORDER BY d.quarter;

SELECT 
    d.month,
    d.month_name,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(SUM(f.sales), 2) AS cumulative_monthly_sales,
    ROUND(100.0 * SUM(f.sales) / (SELECT SUM(sales) FROM fact_sales), 2) AS pct_of_annual_sales
FROM fact_sales f
JOIN dim_date d ON d.date_key = f.order_date_key
GROUP BY d.month, d.month_name
ORDER BY d.month;

WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        ROUND(SUM(f.sales), 2) AS total_product_sales,
        ROW_NUMBER() OVER (ORDER BY SUM(f.sales) DESC) AS product_rank,
        COUNT(*) OVER () AS total_products_count
    FROM fact_sales f
    JOIN dim_product p ON p.product_id = f.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
running_totals AS (
    SELECT 
        product_id,
        product_name,
        category,
        total_product_sales,
        product_rank,
        total_products_count,
        ROUND(100.0 * product_rank / total_products_count, 2) AS cumulative_product_pct,
        ROUND(SUM(total_product_sales) OVER (ORDER BY product_rank ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_sales,
        ROUND(100.0 * SUM(total_product_sales) OVER (ORDER BY product_rank ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / 
              (SELECT SUM(sales) FROM fact_sales), 2) AS cumulative_sales_pct
    FROM product_sales
)
SELECT 
    product_rank,
    product_name,
    category,
    total_product_sales,
    cumulative_product_pct,
    cumulative_sales_pct
FROM running_totals
WHERE product_rank <= 10 OR (cumulative_sales_pct >= 79.9 AND cumulative_sales_pct <= 80.5)
ORDER BY product_rank;

SELECT 
    is_sales_outlier,
    COUNT(row_id) AS transaction_count,
    ROUND(100.0 * COUNT(row_id) / (SELECT COUNT(*) FROM vw_sales_full), 2) AS pct_of_transactions,
    ROUND(SUM(sales), 2) AS total_sales_volume,
    ROUND(100.0 * SUM(sales) / (SELECT SUM(sales) FROM vw_sales_full), 2) AS pct_of_total_revenue,
    ROUND(AVG(sales), 2) AS avg_ticket_size,
    ROUND(MIN(sales), 2) AS min_ticket_size,
    ROUND(MAX(sales), 2) AS max_ticket_size
FROM vw_sales_full
GROUP BY is_sales_outlier
ORDER BY is_sales_outlier DESC;
