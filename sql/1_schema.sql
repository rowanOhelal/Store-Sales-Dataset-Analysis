drop schema if exists superstore cascade;
create schema superstore;
set search_path to superstore, public;

-- Dimensions
create table dim_customer(
	customer_id varchar(20) primary key,
	customer_name varchar(100) not null,
	segment varchar(20) not null check(segment in ('Consumer', 'Corporate', 'Home Office'))
);

create table dim_product(
	product_id varchar(20) primary key,
	product_name varchar(255) not null,
	category varchar(50) not null check(category in ('Furniture', 'Office Supplies', 'Technology')),
	sub_category varchar(50) not null
);

create table dim_location(
	location_id integer primary key,
	country varchar(50) not null,
	city varchar(100) not null,
	state varchar(50) not null,
	postal_code char(5) not null,
	region varchar(20) not null check(region in ('Central', 'East', 'South', 'West')),
	unique(country, city, state, postal_code, region)
);

create table dim_ship_mode(
	ship_mode_id smallint primary key,
	ship_mode varchar(20) not null unique check(ship_mode in ('Same Day', 'First Class', 'Second Class', 'Standard Class'))
);

create table dim_date(
	date_key integer primary key, -- yyyymmdd
	full_date date not null unique,
	year smallint not null,
	quarter smallint not null check(quarter between 1 and 4),
	month smallint not null check(month between 1 and 12),
	month_name varchar(9) not null,
	year_month char(7) not null, -- yyyy-mm
	day smallint not null,
	day_of_week smallint not null check(day_of_week between 1 and 7), -- 1 = Monday
	day_name varchar(9) not null,
	is_weekend boolean not null
);

-- Fact table
create table fact_sales(
	row_id integer primary key,
	order_id varchar(20) not null,
	order_date_key integer not null references dim_date(date_key),
	ship_date_key integer not null references dim_date(date_key),
	customer_id varchar(20) not null references dim_customer(customer_id),
	product_id varchar(20) not null references dim_product(product_id),
	location_id integer not null references dim_location(location_id),
	ship_mode_id smallint not null references dim_ship_mode(ship_mode_id),
	sales numeric(12,4) not null check(sales > 0),
	ship_days smallint not null check(ship_days >=0),
	check(ship_date_key >= order_date_key)
);

-- Indexes
create index idx_fact_order_date on fact_sales(order_date_key);
create index idx_fact_ship_date  on fact_sales(ship_date_key);
create index idx_fact_customer   on fact_sales(customer_id);
create index idx_fact_product    on fact_sales(product_id);
create index idx_fact_location   on fact_sales(location_id);
create index idx_fact_ship_mode  on fact_sales(ship_mode_id);
create index idx_fact_order_id   on fact_sales(order_id);

-- Reporting view
create or replace view vw_sales_full as
with q as(
	select 
		percentile_cont(0.25) within group (order by sales) as q1,
		percentile_cont(0.75) within group (order by sales) as q3
	from fact_sales
)
select
	f.row_id,
	f.order_id,
	od.full_date as order_date,
	sd.full_date as ship_date,
	f.ship_days,
	sm.ship_mode,
	od.year as order_year,
	od.quarter as order_quarter,
	od.month as order_month,
	od.year_month as year_month,
	c.customer_id,
	c.customer_name,
	c.segment,
	l.country,
	l.state,
	l.city,
	l.postal_code,
	l.region,
	p.product_id,
	p.category,
	p.sub_category,
	p.product_name,
	f.sales,
	(f.sales > q.q3 + 1.5 * (q.q3 - q.q1)) as is_sales_outlier
from fact_sales f
cross join q
join dim_date od on od.date_key = f.order_date_key
join dim_date sd on sd.date_key = f.ship_date_key
join dim_ship_mode sm on sm.ship_mode_id = f.ship_mode_id
join dim_customer c on c.customer_id = f.customer_id
join dim_product p on p.product_id = f.product_id
join dim_location l on l.location_id = f.location_id;

COMMENT ON TABLE fact_sales    IS 'One row per order line (grain = Row ID in the source file). Keys and measures only.';
COMMENT ON TABLE dim_customer  IS 'One row per customer.';
COMMENT ON TABLE dim_product   IS 'One row per product ID (conflicting names resolved to the most frequent).';
COMMENT ON TABLE dim_location  IS 'One row per distinct country/city/state/postal code/region.';
COMMENT ON TABLE dim_ship_mode IS 'One row per shipping mode, numbered fastest to slowest.';
COMMENT ON TABLE dim_date      IS 'One row per calendar day, covering whole years; used for both order and ship dates.';
COMMENT ON VIEW  vw_sales_full IS 'Denormalised view joining the fact table to all dimensions.';