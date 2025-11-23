CREATE TABLE customer (
    customer_id int PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    gender VARCHAR(100),
    DOB text,
    job_title VARCHAR(100),
    job_industry_category VARCHAR(100),
    wealth_segment VARCHAR(100),
    deceased_indicator VARCHAR(10),
    owns_car VARCHAR(10),
    address VARCHAR(100),
    postcode VARCHAR(20),
    state VARCHAR(100),
    country VARCHAR(100),
    property_valuation INT
);

create table product (
	product_id int,
	brand VARCHAR(100),
	product_line VARCHAR(100),
	product_class VARCHAR(100),
	product_size VARCHAR(100),
	list_price float,
	standard_cost float
);


CREATE TABLE orders (
    order_id int PRIMARY KEY,
    customer_id int not null,
    order_date varchar(100),
    online_order varchar(100),
    order_status varchar(100),
    		FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE CASCADE
);


drop table customer, orders;