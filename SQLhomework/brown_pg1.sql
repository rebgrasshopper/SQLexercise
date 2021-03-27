/*** Welcome to DA Bootcamp Homework 2. 
	Write SQL Statements beneath the PROBLEMS to satisfy all criteria.
	Update all instances of "brown" to be your last name, lower case. This includes the Schema and filenames.
	Your submission must be a zip file including all 4 files 

	Your homework will be graded by executing each statement one-by-one in the order 
	in which they occur. There should be no Errors; Warnings are permissible when using IF EXISTS/IF NOT EXISTS.
***/


/*** Initial Setup - only change lastname to your last name ***/ 
Select @@autocommit; -- 1 by default, all commands COMMIT immediately (no ROLLBACK)
Set @@autocommit = 0; -- ROLLBACK may be used to reverse DML changes not yet COMMIT.
Select @@SQL_SAFE_UPDATES; -- 1 by default
Set @@SQL_SAFE_UPDATES = 0; -- Lifts Warning on DELETE


DROP SCHEMA IF EXISTS da_bootcamp_brown; 
CREATE SCHEMA IF NOT EXISTS da_bootcamp_brown;
Use da_bootcamp_brown;

/*** PROBLEM 1 - Data Definition Language ***/
/* 
	There are 5 main DDL commands: CREATE, DROP, ALTER, TRUNCATE, and RENAME.
    You are tasked with creating a simple table, altering it, renaming it, selecting, then dropping it.
	1. Create a new table 'animals' with an ID column (type INT) and 2 additional columns (any name and datatype).
    2. Add a new column to the table, then DROP one of the other columns (other than ID).
    3. Rename the table to 'zoo_animals'
    4. Select all records from the (empty) zoo_animals table
    5. Drop the table - actually, to be on the safe side, use the "if exists" condition to 
		drop animals if it exists, and drop zoo_animals if it exists.
*/

-- 1. Create a new table 'animals' with an ID column (type INT) and 2 additional columns (any name and datatype).
CREATE TABLE IF NOT EXISTS animals (
	id INT AUTO_INCREMENT PRIMARY KEY,
	commonName VARCHAR(150) NOT NULL,
    scientificName VARCHAR(250) NOT NULL
);

-- 2. Add a new column to the table, then DROP one of the other columns (other than ID).
ALTER TABLE animals
	ADD COLUMN species VARCHAR(100) NOT NULL,
    DROP COLUMN scientificName;

-- 3. Rename the table to 'zoo_animals'
RENAME TABLE
	animals TO zoo_animals;

-- 4. Select all records from the (empty) zoo_animals table
SELECT * FROM zoo_animals;

 -- 5. Drop the table - actually, to be on the safe side, use the "if exists" condition to 
		-- drop animals if it exists, and drop zoo_animals if it exists.
DROP TABLE IF EXISTS animals;
DROP TABLE IF EXISTS zoo_animals;

/*** PROBLEM 2 - Data Manipulation Language ***/
/* 
	DML Statements make changes to the contents of tables - Insert, Delete, Update
    You will load the raw data provided, and using TCL commands ROLLBACK and COMMIT to make and undo changes.
    1. Create table item_details using field names (item_id, item_price, item_description), using sensible data types.
    2. INSERT all raw data provided into item_detail. COMMIT the change.
    3. SELECT * to confirm all 5 rows are present.
    4. DELETE all records for which the item price is greater-than-or-equal-to 2. 
    5. SELECT * to confirm deletions. ROLLBACK the change, and SELECT * once again to confirm 5 original rows present.
    6. Ah, the price for Apples was wrong. UPDATE that record to price 6 instead of 60.
    7. The price of Avocados and Broccoli have doubled. UPDATE those records to reflect the price doubling.
    8. SELECT * to confirm the records are correct. COMMIT. Table item_details is ready for use in PROBLEM 3.
    9. SUGGESTION: To make debugging PROBLEM 3 easier, 
		you may wish to make note of item_details record values as of Step 8, then 
        TRUNCATE item_details and INSERT records to match those recorded values to have a reliable starting point.

Raw data provided: 
('itm001',2,'Avocado (ind)'),
('itm002',60,'Apple Bag'),
('itm003',0.5,'Lemons (ind)'),
('itm004',2,'Banana (lb)'),
('itm005',3,'Broccoli (head)')
*/


DROP TABLE IF EXISTS item_details;

-- 1. Create table item_details using field names (item_id, item_price, item_description), using sensible data types.
CREATE TABLE item_details (	
    item_id VARCHAR(20) PRIMARY KEY,
    item_price DECIMAL(8,2) NOT NULL,
    item_description VARCHAR(250) NOT NULL
);

-- 2. INSERT all raw data provided into item_detail. COMMIT the change.
INSERT INTO item_details VALUES
('itm001',2,'Avocado (ind)'),
('itm002',60,'Apple Bag'),
('itm003',0.5,'Lemons (ind)'),
('itm004',2,'Banana (lb)'),
('itm005',3,'Broccoli (head)');

COMMIT;

-- 3. SELECT * to confirm all 5 rows are present.
SELECT * FROM item_details;

-- 4. DELETE all records for which the item price is greater-than-or-equal-to 2. 
DELETE FROM item_details
WHERE item_price >= 2;

-- 5. SELECT * to confirm deletions. ROLLBACK the change, and SELECT * once again to confirm 5 original rows present.
SELECT * FROM item_details;

ROLLBACK;

SELECT * FROM item_details;

--  6. Ah, the price for Apples was wrong. UPDATE that record to price 6 instead of 60.
UPDATE item_details
SET item_price = 6 WHERE item_id = 'itm002';

-- 7. The price of Avocados and Broccoli have doubled. UPDATE those records to reflect the price doubling.
UPDATE item_details
SET item_price = item_price * 2 WHERE item_id IN ('itm001', 'itm005');

--  8. SELECT * to confirm the records are correct. COMMIT. Table item_details is ready for use in PROBLEM 3.
SELECT * FROM item_details;

COMMIT;

/*** PROBLEM 3 - Data Querying Clauses and Joins ***/
/* 
	Big data! Well, relatively big. You will create table sales_orders and get to work analyzing. 
    You're encouraged to experiment with using TEMPORARY tables in your analysis, but your final queries must not 
    include them - you must only submit queries using the base sales_orders and item_details tables.
    1. Create table sales_orders with 5 columns: 
		a. record_id, a Big Integer Primary Key that auto-increments with each new record added.
        b. order_no, another Big Integer that cannot be NULL
        c. order_date, DATE
        d. item_id, formatted to match item_details.item_id from PROBLEM 2.
        e. quantity, Big Integer
	2. Load sales_orders with the raw data provided in pg2. You may write and leave the entire INSERT statement there.
    
    You will then write SQL queries answering the following (include the full question as a comment above your query). 
    It's always assumed that sales_orders joins item_details on item_id. 
    Line_item_total is the product of quantity and item_price.
    Order_Total is the sum of line_item_totals for a given Order_no.
    3. What is the total number of records in sales_orders? 
    4. What is the total number of records of sales_orders INNER JOIN item_details? LEFT JOIN?
    5. Return the order_no, order_date, and the order_total for the top 10 orders in August in descending order.
    6. Return the order_no, order_date, and the total quantity for orders HAVING a total quantity greater than 10.
    7. Create stored procedure "total_sales_on_date" that returns total sales (in $) given a date.
    
    item data
    ('itm001',4,'Avocado (ind)'),
	('itm002',6,'Apple Bag'),
	('itm003',0.5,'Lemons (ind)'),
	('itm004',2,'Banana (lb)'),
	('itm005',6,'Broccoli (head)')
*/

DROP TABLE IF EXISTS sales_orders;

-- 1. Create table sales_orders with 5 columns: record_id, order_no, order_date, item_id, quantity
CREATE TABLE sales_orders (
	record_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_no BIGINT NOT NULL,
    order_date DATE,
    item_id VARCHAR(20) NOT NULL,
    quantity BIGINT
    
);

SELECT * FROM sales_orders;

-- analysis questions


-- total number of records of sales_orders: 831
SELECT COUNT(*) FROM sales_orders; 


-- total number of records for sales_orders INNER JOIN item_details: 828
SELECT COUNT(*) FROM sales_orders s
INNER JOIN item_details i ON s.item_id = i.item_id; 


-- total number of records for sales_orders LEFT JOIN item_details: 831
SELECT COUNT(*) FROM sales_orders s
LEFT JOIN item_details i ON s.item_id = i.item_id; 


-- order_no, order_date, and the order_total for the top 10 orders in August in descending order.
-- used default INNER JOIN, becuase mystery itm006 has no price, and as such cannot compete for top orders by price.
-- after ordering by order_total I decided to also order by order_no just to make sure that orders with the same total display in a predictable and consistent order.
SELECT order_no, order_date, (item_price * quantity) as order_total FROM sales_orders
JOIN item_details on sales_orders.item_id = item_details.item_id
WHERE DATE_FORMAT(order_date, '%m') = 08
ORDER BY order_total DESC, order_no ASC LIMIT 10; 


-- order_no, order_date, and the total quantity for orders HAVING a total quantity greater than 10.
-- used LEFT JOIN to include mystery itm006, since focus is on order quantity rather than item price or description.
SELECT order_no, order_date, quantity FROM sales_orders
LEFT JOIN item_details on sales_orders.item_id = item_details.item_id
HAVING quantity > 10; 

-- stored procedure "total_sales_on_date" that returns total sales (in $) given a date
-- used default INNER JOIN becuase items not matched in either table will not add value to total sales calculations.
DELIMITER //
CREATE PROCEDURE total_sales_on_date(
	IN date DATE
    )
	BEGIN
		SELECT SUM(item_price * quantity) as total_sales FROM sales_orders
		JOIN item_details on sales_orders.item_id = item_details.item_id
		WHERE DATE(order_date) = DATE(date);
	END //

DELIMITER ;

CALL total_sales_on_date('2019-07-04');




/*** PROBLEM 4 - Expanding a Dimension Table ***/
/*
	On the brown_pg4 page you are provided the beginnings of a Date Dimension table named date_dim.
    
    1. You must create a list in Excel of all dates from 7/1/2019 to 12/31/2019, 
    in order to create the INSERT statement. Comment below with a description of what EXCEL
    functions you used to create the data, copy-pasting the entire functions including the = sign

    2. You must then UPDATE date_dim to populate all the columns. You can find date conversion
    functions for MySQL online.
    
    Write a query joining date_dim onto sales_orders & item_details to answer the questions: 
    3. Sales ($) for each item_description broken down by day of the week.
		Columns should be: Item Description, Day of Week, Sales Total
    4. Total Quantity Sold by Product by Quarter. Columns should be: Item_ID, Quarter YYYYMM, Total Quantity
*/

#1. Comment here with what Excel functions you used to generate the test dataset.
 --   =CONCAT("('", TEXT(B2,  "YYYY-MM-DD"), "'),")

#2. Occurs entirely on brown_pg4


#3. Please write query below. 
-- Default INNER JOIN selected, because focus is on price, and the myster itm006 has no associated price OR description, and as such I don't think it can add value to this query.
SELECT item_description AS "Item Description", TheDayOfWeek AS "Day Of Week", SUM(quantity * item_price) as "Sales Total" FROM sales_orders s
	JOIN item_details i ON s.item_id = i.item_id
	JOIN date_dim d ON DATE(s.order_date) = DATE(d.TheDate)  
	GROUP BY TheDayOfWeek, item_description
	ORDER BY item_description, TheDayOfWeek;

#4. Please write query below.
-- LEFT JOIN selected, becuase focus is on quantities sold, and there exist quantities for an item not in item_details table. 
SELECT s.item_id AS "Item ID", YYYYQQ AS "Quarter YYYYQQ", SUM(quantity) as "Total Quantity" FROM sales_orders s
	LEFT JOIN item_details i ON s.item_id = i.item_id
	LEFT JOIN date_dim d ON DATE(s.order_date) = DATE(d.TheDate)  
	GROUP BY YYYYQQ, s.item_id
	ORDER BY YYYYQQ, s.item_id;
