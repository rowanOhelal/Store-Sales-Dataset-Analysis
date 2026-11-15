-- Part 1: staging table (shaped exactly like superstore_clean.csv, same columns, same order)

set search_path to superstore, public;

drop table if exists stg_sales;
create table stg_sales(
	row_id integer,
	order_id varchar(20),
	order_date date,
	ship_date date,
	ship_mode varchar(20),
	customer_id varchar(20),
	customer_name varchar(100),
	segment varchar(20),
	country varchar(50),
	city varchar(100),
	state varchar(50),
	postal_code varchar(5),
	region varchar(20),
	product_id varchar(20),
	category varchar(20),
	sub_category varchar(50),
	product_name varchar(255),
	sales numeric(12,4),
	ship_days smallint,
	order_year integer,
	order_quarter integer,
	order_month integer,
	year_month varchar(7),
	is_sales_outlier boolean
);

-- IMPORT THE CSV NOW: run Part 1 first, then import, then run Part 2
-- pgAdmin: Schemas > superstore > Tables > stg_sales > right-click
--          > Import/Export Data > Import, pick superstore_clean.csv,
--          format = csv, Header = on, delimiter = ',', escape = '"'.

-- check (expect 9799)
select count(*) from stg_sales;

-- Part 2: fill the model tables from staging
set search_path to superstore, public;

truncate fact_sales, dim_customer, dim_product, dim_location, dim_ship_mode, dim_date;

insert into dim_customer(customer_id, customer_name, segment)
select distinct customer_id, customer_name, segment
from stg_sales;

insert into dim_product(product_id, product_name, category, sub_category)
select distinct product_id, product_name, category, sub_category
from stg_sales;

insert into dim_location(location_id, country, city, state, postal_code, region)
select row_number() over (order by state, city, postal_code),
	country, city, state, postal_code, region
from (select distinct country, city, state, postal_code, region from stg_sales) as x;

insert into dim_ship_mode(ship_mode_id, ship_mode)
select row_number() over (order by case ship_mode
									when 'Same Day' then 1
									when 'First Class' then 2
									when 'Second Class' then 3
									else 4 end),
	ship_mode
from (select distinct ship_mode from stg_sales) as x;

-- Calendar: every day from 1 Jan of the first order year to 31 Dec of the last ship year
with bounds as(
	select 
		make_date(extract(year from min(order_date))::int, 1, 1) as start_date,
		make_date(extract(year from max(ship_date))::int, 12, 31) as end_date
	from stg_sales
),
days as(
	select b.start_date + g as d
	from bounds b, generate_series(0, b.end_date - b.start_date) as g
)
insert into dim_date(date_key, full_date, year, quarter, month, month_name, year_month, day, day_of_week, day_name, is_weekend)
select to_char(d, 'YYYYMMDD')::int,
	d,
	extract(year from d)::int,
	extract(quarter from d)::int,
	extract(month from d)::int,
	trim(to_char(d, 'Month')),
	to_char(d, 'YYYY-MM'),
	extract(day from d)::int,
	extract(isodow from d)::int,
	trim(to_char(d, 'Day')),
	extract(isodow from d) in (6,7)
from days;

-- fact table
insert into fact_sales(row_id, order_id, order_date_key, ship_date_key, customer_id, product_id, location_id, ship_mode_id, sales, ship_days)
select 
	s.row_id,
	s.order_id,
	to_char(s.order_date, 'YYYYMMDD')::int,
	to_char(s.ship_date, 'YYYYMMDD')::int,
	s.customer_id,
	s.product_id,
	l.location_id,
	sm.ship_mode_id,
	s.sales,
	s.ship_days
from stg_sales s
join dim_location l on l.country = s.country and l.city = s.city and l.state = s.state and l.postal_code = s.postal_code and l.region = s.region
join dim_ship_mode sm on sm.ship_mode = s.ship_mode;

-- check: staging rows and fact rows must be equal
select(select count(*) from stg_sales) as staging_rows, (select count(*) from fact_sales) as fact_rows;

-- cleanup once validation passes:
-- DROP TABLE stg_sales;