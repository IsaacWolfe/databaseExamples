SET ANSI_WARNINGS ON;
GO

use master;
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'iww15')
DROP DATABASE iww15;
GO

IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'iww15')
CREATE DATABASE iww15;
GO

use iww15;
GO

IF OBJECT_ID(N'dbo.person',N'U') IS NOT NULL
DROP TABLE dbo.person;
GO

CREATE TABLE dbo.person
(
    per_id SMALLINT NOT NULL IDENTITY(1,1),
    per_ssn BINARY(64) NULL,
    per_fname VARCHAR(15) NOT NULL,
    per_lname VARCHAR(30) NOT NULL,
    per_gender CHAR(1) NOT NULL CHECK(per_gender IN('m','f')),
    per_dob DATE NOT NULL,
    per_street VARCHAR(30) NOT NULL,
    per_city VARCHAR(30) NOT NULL,
    per_state CHAR(2) NOT NULL DEFAULT 'FL',
    per_zip INT NOT NULL CHECK(per_zip LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    per_email VARCHAR(100) NULL,
    per_type CHAR(1) NOT NULL CHECK(per_type IN ('c','s')),
    per_notes VARCHAR(45) NULL,
    PRIMARY KEY (per_id),

    CONSTRAINT ux_per_ssn unique nonclustered(per_ssn ASC)
);

IF OBJECT_ID (N'dbo.phone',N'U') IS NOT NULL
DROP TABLE dbo.phone;
GO

CREATE TABLE dbo.phone
(
    phn_id SMALLINT NOT NULL IDENTITY(1,1),
    per_id SMALLINT NOT NULL,
    phn_num BIGINT NOT NULL CHECK(phn_num LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    phn_type CHAR(1) NOT NULL CHECK(phn_type IN ('h','c','w','f')),
    phn_notes VARCHAR(255) NULL,
    PRIMARY KEY (phn_id),

    CONSTRAINT fk_phone_person
    FOREIGN KEY (per_id)
    REFERENCES dbo.person (per_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

IF OBJECT_ID (N'dbo.customer',N'U') IS NOT NULL
DROP TABLE dbo.customer;
GO

CREATE TABLE dbo.customer
(
    per_id SMALLINT NOT NULL,
    cus_balance DECIMAL(7,2) NOT NULL CHECK(cus_balance >= 0),
    cus_total_sales DECIMAL(7,2) NOT NULL CHECK(cus_total_sales >= 0),
    cus_notes VARCHAR(45) NULL,
    PRIMARY KEY (per_id),

    CONSTRAINT fk_customer_person
    FOREIGN KEY (per_id)
    REFERENCES dbo.person (per_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

IF OBJECT_ID (N'dbo.slsrep',N'U') IS NOT NULL
DROP TABLE dbo.slsrep;
GO

CREATE TABLE dbo.slsrep
(
    per_id SMALLINT NOT NULL,
    srp_yr_sales_goal DECIMAL(8,2) NOT NULL CHECK(srp_yr_sales_goal >= 0),
    srp_ytd_sales DECIMAL(8,2) NOT NULL CHECK(srp_ytd_sales >= 0),
    srp_ytd_comm DECIMAL(7,2) NOT NULL CHECK(srp_ytd_comm >= 0),
    srp_notes VARCHAR(45),
    PRIMARY KEY (per_id),

    CONSTRAINT fk_slsrep_person
    FOREIGN KEY (per_id) 
    REFERENCES dbo.person (per_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

IF OBJECT_ID(N'dbo.srp_hist',N'U') IS NOT NULL
DROP TABLE dbo.srp_hist;
GO

CREATE TABLE dbo.srp_hist
(
    sht_id SMALLINT NOT NULL IDENTITY(1,1),
    per_id SMALLINT NOT NULL,
    sht_type CHAR(1) NOT NULL CHECK(sht_type IN('i','u','d')),
    sht_modified DATETIME NOT NULL,
    sht_modifier VARCHAR(45) NOT NULL DEFAULT system_user,
    sht_date DATE NOT NULL DEFAULT getDate(),
    sht_yr_sales_goal DECIMAL(8,2) NOT NULL CHECK(sht_yr_sales_goal >= 0),
    sht_yr_total_sales DECIMAL(8,2) NOT NULL CHECK(sht_yr_total_sales >= 0),
    sht_yr_total_comm DECIMAL(7,2) NOT NULL CHECK(sht_yr_total_comm >= 0),
    sht_notes VARCHAR(45) NULL,
    PRIMARY KEY (sht_id),

    CONSTRAINT fk_srp_hist_slsrep
    FOREIGN KEY (per_id)
    REFERENCES dbo.slsrep (per_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

IF OBJECT_ID(N'dbo.contact',N'U') IS NOT NULL
DROP TABLE dbo.contact;
GO

CREATE TABLE dbo.contact
(
    cnt_id INT NOT NULL IDENTITY(1,1),
    per_cid SMALLINT NOT NULL,
    per_sid SMALLINT NOT NULL,
    cnt_date DATETIME NOT NULL,
    cnt_notes VARCHAR(255) NULL,
    PRIMARY KEY (cnt_id),

    CONSTRAINT fk_contact_customer
    FOREIGN KEY (per_cid)
    REFERENCES dbo.customer (per_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fk_contact_slsrep
    FOREIGN KEY (per_sid)
    REFERENCES dbo.slsrep (per_id)
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION

    /* This is due to having multiple persons with the per_id, it would delete multiple records and throw an error */
);

IF OBJECT_ID(N'dbo.[order]',N'U') IS NOT NULL
DROP TABLE dbo.[order];
GO

CREATE TABLE dbo.[order]
(
    ord_id INT NOT NULL IDENTITY(1,1),
    cnt_id INT NOT NULL,
    ord_placed_date DATETIME NOT NULL,
    ord_filled_date DATETIME NULL,
    ord_notes VARCHAR(255) NULL,
    PRIMARY KEY (ord_id),

    CONSTRAINT fk_order_contact
    FOREIGN KEY (cnt_id)
    REFERENCES dbo.contact (cnt_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

IF OBJECT_ID(N'dbo.store',N'U') IS NOT NULL
DROP TABLE dbo.store;
GO

CREATE TABLE dbo.store
(
    str_id SMALLINT NOT NULL IDENTITY(1,1),
    str_name VARCHAR(45) NOT NULL,
    str_street VARCHAR(30) NOT NULL,
    str_city VARCHAR(30) NOT NULL,
    str_state CHAR(2) NOT NULL DEFAULT'FL',
    str_zip INT NOT NULL CHECK(str_zip LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    str_phone BIGINT NOT NULL CHECK(str_phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    str_email VARCHAR(100) NOT NULL,
    str_url VARCHAR(100) NOT NULL,
    str_notes VARCHAR(255) NULL,
    PRIMARY KEY (str_id)
);

IF OBJECT_ID(N'dbo.invoice',N'U') IS NOT NULL
DROP TABLE dbo.invoice;
GO

CREATE TABLE dbo.invoice
(
    inv_id INT NOT NULL IDENTITY(1,1),
    ord_id INT NOT NULL,
    str_id SMALLINT NOT NULL,
    inv_date DATETIME NOT NULL,
    inv_total DECIMAL(8,2) NOT NULL CHECK(inv_total >= 0),
    inv_paid BIT NOT NULL,
    inv_notes VARCHAR(255) NULL,
    PRIMARY KEY (inv_id),

    /* creates 1:1 relationship with order by making ord_id unique */
    CONSTRAINT ux_ord_id UNIQUE NONCLUSTERED (ord_id ASC),

    CONSTRAINT fk_invoice_order
    FOREIGN KEY (ord_id)
    REFERENCES dbo.[order] (ord_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fk_invoice_store
    FOREIGN KEY (str_id)
    REFERENCES dbo.store (str_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

IF OBJECT_ID(N'dbo.payment',N'U') IS NOT NULL
DROP TABLE dbo.payment;
GO

CREATE TABLE dbo.payment
(
    pay_id INT NOT NULL IDENTITY(1,1),
    inv_id INT NOT NULL,
    pay_date DATETIME NOT NULL,
    pay_amt DECIMAL(7,2) NOT NULL CHECK(pay_amt >= 0),
    pay_notes VARCHAR(255) NULL,
    PRIMARY KEY (pay_id),

    CONSTRAINT fk_payment_invoice
    FOREIGN KEY (inv_id)
    REFERENCES dbo.invoice (inv_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

IF OBJECT_ID(N'dbo.vendor',N'U') IS NOT NULL
DROP TABLE dbo.vendor;
GO

CREATE TABLE dbo.vendor
(
    ven_id SMALLINT NOT NULL IDENTITY(1,1),
    ven_name VARCHAR(45) NOT NULL,
    ven_street VARCHAR(30) NOT NULL,
    ven_city VARCHAR(30) NOT NULL,
    ven_state CHAR(2) NOT NULL DEFAULT'FL',
    ven_zip INT NOT NULL CHECK(ven_zip LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    ven_phone BIGINT NOT NULL CHECK(ven_phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    ven_email VARCHAR(100) NULL,
    ven_url VARCHAR(100) NULL,
    ven_notes VARCHAR(255) NULL,
    PRIMARY KEY (ven_id)
);

IF OBJECT_ID(N'dbo.product',N'U') IS NOT NULL
DROP TABLE dbo.product;
GO

CREATE TABLE dbo.product
(
	pro_id SMALLINT NOT NULL IDENTITY(1,1),
	ven_id SMALLINT NOT NULL,
	pro_name VARCHAR(30) NOT NULL,
	pro_descript VARCHAR(45) NULL,
	pro_weight FLOAT NOT NULL CHECK(pro_weight >= 0),
	pro_qoh SMALLINT NOT NULL CHECK(pro_qoh >= 0),
	pro_cost DECIMAL(7,2) NOT NULL CHECK(pro_cost >= 0),
	pro_price DECIMAL(7,2) NOT NULL CHECK(pro_price >= 0),
	pro_discount DECIMAL(3,0) NULL,
	pro_notes VARCHAR(255) NULL,
	PRIMARY KEY (pro_id),

	CONSTRAINT fk_product_vendor
	FOREIGN KEY (ven_id)
	REFERENCES dbo.vendor (ven_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

IF OBJECT_ID(N'dbo.product_hist',N'U') IS NOT NULL
DROP TABLE dbo.product_hist;
GO

CREATE TABLE dbo.product_hist
(
	pht_id INT NOT NULL IDENTITY(1,1),
	pro_id SMALLINT NOT NULL,
	pht_date DATETIME NOT NULL,
	pht_cost DECIMAL(7,2) NOT NULL CHECK(pht_cost >= 0),
	pht_price DECIMAL(7,2) NOT NULL CHECK(pht_price >= 0),
	pht_discount DECIMAL(3,0) NULL,
	pht_notes VARCHAR(255) NULL,
	PRIMARY KEY (pht_id),

	CONSTRAINT fk_product_hist_product
	FOREIGN KEY (pro_id)
	REFERENCES dbo.product (pro_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

IF OBJECT_ID(N'dbo.order_line',N'U') IS NOT NULL
DROP TABLE dbo.order_line;
GO

CREATE TABLE dbo.order_line
(
	oln_id INT NOT NULL IDENTITY(1,1),
	ord_id INT NOT NULL,
	pro_id SMALLINT NOT NULL,
	oln_qty SMALLINT NOT NULL CHECK(oln_qty >= 0),
	oln_price DECIMAL(7,2) NOT NULL CHECK(oln_price >= 0),
	oln_notes VARCHAR(255) NULL,
	PRIMARY KEY (oln_id),

	CONSTRAINT fk_order_line_order
	FOREIGN KEY (ord_id)
	REFERENCES dbo.[order] (ord_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,

	CONSTRAINT fk_order_line_product
	FOREIGN KEY (pro_id)
	REFERENCES dbo.product (pro_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

SELECT * FROM information_schema.tables;

INSERT INTO dbo.person
(per_ssn,per_fname,per_lname,per_gender,per_dob,per_street,per_city,per_state,per_zip,per_email,per_type,per_notes)
VALUES
(HASHBYTES('SHA2_512','928733328'),'Steve','Rogers','m','1923-10-03','437 Southern Drive','Rochester','NY',839284751,'stever@gmail.com','s',NULL),
(HASHBYTES('SHA2_512','891249812'),'Bruce','Wayne','m','1968-07-21','1007 Mountain Drive','Gotham','NY',912985121,'brucew@gmail.com','s',NULL),
(HASHBYTES('SHA2_512','981241120'),'Peter','Parker','m','1988-06-17','20 Ingram Street','New York','NY',981241225,'peterp@gmail.com','s',NULL),
(HASHBYTES('SHA2_512','124891259'),'Jane','Thompson','f','1978-12-03','13635 Ocean View Drive','Seattle','WA',124981512,'janet@gmail.com','s',NULL),
(HASHBYTES('SHA2_512','891249125'),'Debra','Steele','f','1994-03-22','543 Oak Lane','Milwaukee','WI',129481252,'debras@gmail.com','s',NULL),
(HASHBYTES('SHA2_512','918259812'),'Tony','Stark','m','1972-04-15','332 Palm Avenue','Malibu','CA',149284121,'tonys@gmail.com','c',NULL),
(HASHBYTES('SHA2_512','124981241'),'Hank','Pym','m','1980-11-13','2355 Brown Street','Cleveland','OH',128952521,'hankp@gmail.com','c',NULL),
(HASHBYTES('SHA2_512','518277841'),'Bob','Best','m','1992-05-14','4902 Avendale Ave','Scottsdale','AZ',242389199,'bobb@gmail.com','c',NULL),
(HASHBYTES('SHA2_512','742991233'),'Sandra','Dole','f','1990-07-14','87912 Lawrence Avenue','Atlanta','GA',423828821,'sandrad@gmail.com','c',NULL),
(HASHBYTES('SHA2_512','230032192'),'Ben','Avery','m','1983-09-12','6432 Thunderbird Lane','Sioux Falls','SD',128481929,'bena@gmail.com','c',NULL),
(HASHBYTES('SHA2_512','478922912'),'Arthur','Curry','m','1975-02-25','3304 Euclid Avenue','Miami','FL',382948829,'arthurc@gmail.com','c',NULL),
(HASHBYTES('SHA2_512','392992011'),'Diana','Prince','f','1980-08-30','944 Green Street','Las Vegas','NV',389289124,'dianap@gmail.com','c',NULL),
(HASHBYTES('SHA2_512','138924911'),'Adam','Jurris','m','1995-05-01','98435 Valencia Drive','Gulf Shores','AL',388392101,'adamj@gmail.com','c',NULL),
(HASHBYTES('SHA2_512','742989122'),'Judy','Sleen','f','1970-11-06','56343 Rover Court','Billings','MT',489129244,'judys@gmail.com','c',NULL),
(HASHBYTES('SHA2_512','749829110'),'Bill','Neiderheim','m','1982-03-03','43567 Netherland Blvd','South Bend','IN',382924551,'billn@gmail.com','c',NULL);

SELECT * FROM dbo.person;

INSERT INTO dbo.slsrep
(per_id,srp_yr_sales_goal,srp_ytd_sales,srp_ytd_comm,srp_notes)
VALUES
(1,10000,60000,1800,NULL),
(2,80000,35000,3500,NULL),
(3,15000,84000,9650,NULL),
(4,12500,87000,15300,NULL),
(5,98000,43000,8750,NULL);

SELECT * FROM dbo.slsrep;

INSERT INTO dbo.customer
(per_id,cus_balance,cus_total_sales,cus_notes)
VALUES
(6,120,14789,NULL),
(7,98.46,234.92,NULL),
(8,0,4578,NULL),
(9,981.73,1672.38,NULL),
(10,541.23,782.57,NULL),
(11,251.02,13782.96,NULL),
(12,582.67,963.12,NULL),
(13,121.67,1057.45,NULL),
(14,765.43,6789.42,NULL),
(15,304.39,456.81,NULL);

SELECT * FROM dbo.customer;

INSERT INTO dbo.contact
(per_sid,per_cid,cnt_date,cnt_notes)
VALUES
(1,6,'1999-01-01',NULL),
(2,6,'2001-04-24',NULL),
(3,7,'2007-11-22',NULL),
(2,7,'2003-04-15',NULL),
(4,7,'2002-07-06',NULL),
(5,8,'2005-06-22',NULL),
(4,8,'2007-03-30',NULL),
(1,9,'2010-02-07',NULL),
(5,9,'2002-12-11',NULL),
(3,11,'2003-10-15',NULL),
(4,13,'2005-11-11',NULL),
(2,15,'2004-05-17',NULL);

SELECT * FROM dbo.contact;

INSERT INTO dbo.[order]
(cnt_id,ord_placed_date,ord_filled_date,ord_notes)
VALUES
(1,'2010-11-23','2010-12-24',NULL),
(2,'2005-12-15','2006-01-15',NULL),
(3,'2003-07-13','2003-08-14',NULL),
(4,'2011-08-10','2011-08-10',NULL),
(5,'2014-09-23','2014-10-15',NULL),
(6,'2012-10-02','2012-10-30',NULL),
(7,'2011-09-07','2011-10-13',NULL),
(8,'2012-12-19','2013-02-02',NULL),
(9,'2014-02-25','2014-04-01',NULL),
(10,'2012-07-16','2012-08-18',NULL);

SELECT * FROM dbo.[order];

INSERT INTO dbo.store
(str_name,str_street,str_city,str_state,str_zip,str_phone,str_email,str_url,str_notes)
VALUES
('Walgreens','14567 Walnut Ln','Aspen','IL','423125678','1258849182','info@walgreens.com','http://www.walgreens.com/',NULL),
('CVS','572 Casper Rd','Chicago','IL','542642456','5028172781','info@cvs.com','http://www.cvs.com/',NULL),
('Lowes','81309 Catapult Ave','Clover','WA','164336091','1728781800','info@lowes.com','http://www.lowes.com/',NULL),
('Walmart','14567 Walnut Ln','St. Louis','FL','223412664','3617881209','info@walmart.com','http://www.walmart.com/',NULL),
('Dollar General','47583 Davison Rd','Detroit','MI','643223871','8912877178','info@dollargeneral.com','http://www.dollargeneral.com/',NULL);

SELECT * FROM dbo.store;

INSERT INTO dbo.invoice
(ord_id,str_id,inv_date,inv_total,inv_paid,inv_notes)
VALUES
(5,1,'2001-05-03',58.32,0,NULL),
(4,1,'2006-11-11',100.59,0,NULL),
(1,1,'2010-09-16',57.34,0,NULL),
(3,2,'2011-01-10',99.32,1,NULL),
(2,3,'2008-06-24',1109.67,0,NULL),
(6,4,'2009-04-20',239.83,0,NULL),
(7,5,'2010-06-05',537.29,0,NULL),
(8,2,'2007-06-05',644.21,1,NULL),
(9,3,'2011-12-17',934.12,1,NULL),
(10,4,'2012-03-18',27.45,0,NULL);

SELECT * FROM dbo.invoice;

INSERT INTO dbo.vendor
(ven_name,ven_street,ven_city,ven_state,ven_zip,ven_phone,ven_email,ven_url,ven_notes)
VALUES
('Sysco','531 Dolphin Run','Orlando','FL','382994010','3448198822','sales@sysco.com','http://www.sysco.com',NULL),
('General Electronics','100 Happy Trails Dr','Boston','MA','124981250','8959292241','sales@generalelectronics.com','http://www.generalelectronics.com',NULL),
('Cisco','300 Cisco Dr','Stanford','OR','124891519','1589159002','sales@cisco.com','http://www.cisco.com',NULL),
('Goodyear','100 Goodyear Dr','Gary','IN','189248159','1284941925','sales@goodyear.com','http://www.goodyear.com',NULL),
('Snap-on','42185 Magenta Ave','Lake Falls','ND','124891250','1772585912','sales@snapon.com','http://www.snapon.com',NULL);

SELECT * FROM dbo.vendor;

INSERT INTO dbo.product
(ven_id,pro_name,pro_descript,pro_weight,pro_qoh,pro_cost,pro_price,pro_discount,pro_notes)
VALUES
(1,'hammer','',2.5,45,4.99,7.99,30,NULL),
(2,'screwdriver','',1.8,120,1.99,3.49,NULL,NULL),
(4,'pail','Gallon',2.8,48,3.89,7.99,40,NULL),
(5,'Cooking Oil','Peanut Oil',15,19,19.99,28.99,NULL,NULL),
(3,'hammer','',3.5,178,8.99,13.99,50,NULL);

SELECT * FROM dbo.product;

INSERT INTO dbo.order_line
(ord_id,pro_id,oln_qty,oln_price,oln_notes)
VALUES
(1,2,10,8.0,NULL),
(2,3,7,9.88,NULL),
(3,4,3,6.99,NULL),
(5,1,2,12.76,NULL),
(4,5,13,58.99,NULL);

SELECT * FROM dbo.order_line;

INSERT INTO dbo.payment
(inv_id,pay_date,pay_amt,pay_notes)
VALUES
(5,'2008-07-01',5.99,NULL),
(4,'2010-09-28',4.99,NULL),
(1,'2008-07-23',8.99,NULL),
(3,'2010-10-31',19.99,NULL),
(2,'2011-03-29',32.99,NULL),
(6,'2010-10-03',20.00,NULL),
(8,'2008-08-09',1000.99,NULL),
(9,'2009-01-10',103.99,NULL),
(7,'2007-05-12',40.00,NULL),
(10,'2007-05-22',9.99,NULL);

SELECT * FROM dbo.payment;

INSERT INTO dbo.product_hist
(pro_id,pht_date,pht_cost,pht_price,pht_discount,pht_notes)
VALUES
(1,'2005-01-02 11:53:34',4.99,7.99,30,NULL),
(2,'2005-02-03 09:13:34',1.99,3.99,NULL,NULL),
(3,'2005-03-04 23:21:34',3.99,7.99,40,NULL),
(4,'2006-05-06 18:09:34',19.99,28.99,NULL,NULL),
(5,'2006-05-07 15:07:34',8.99,13.99,50,NULL);

SELECT * FROM dbo.product_hist;

INSERT INTO dbo.srp_hist
(per_id,sht_type,sht_modified,sht_modifier,sht_date,sht_yr_sales_goal,sht_yr_total_sales,sht_yr_total_comm,sht_notes)
VALUES
(1,'i',getDate(),SYSTEM_USER,getDate(),100000,110000,11000,NULL),
(4,'i',getDate(),SYSTEM_USER,getDate(),150000,175000,17500,NULL),
(3,'u',getDate(),SYSTEM_USER,getDate(),200000,185000,18500,NULL),
(2,'u',getDate(),ORIGINAL_LOGIN(),getDate(),210000,220000,22000,NULL),
(5,'i',getDate(),ORIGINAL_LOGIN(),getDate(),225000,230000,23000,NULL);

SELECT * FROM dbo.srp_hist;

-- Begin Reports
-- 1
SELECT * FROM [iww15].information_schema.tables;
GO

SELECT * FROM [iww15].information_schema.columns;
GO

sp_help 'dbo.srp_hist';
GO

use iww15;
GO

SELECT * FROM dbo.invoice;
SELECT inv_id, inv_total AS paid_invoice_total FROM dbo.invoice WHERE inv_paid != 0;

PRINT'#1 Solution: create view (sum of each customer''s *paid* invoices, in desc order):

';

IF OBJECT_ID(N'dbo.v_paid_invoice_total',N'V') IS NOT NULL
DROP VIEW dbo.v_paid_invoice_total;
GO

CREATE VIEW dbo.v_paid_invoice_total AS
SELECT p.per_id,per_fname,per_lname,sum(inv_total) AS sum_total, FORMAT(sum(inv_total)),'C','en-us') AS paid_invoice_total
FROM dbo.person p
JOIN dbo.customer c ON p.per_id=c.per_id
JOIN dbo.contact ct ON c.per_id=ct.per_cid
JOIN dbo.[order] o ON ct.cnt_id=o.cnt_id
JOIN dbo.invoice i ON o.ord_id=i.ord_id
WHERE inv_paid != 0
GROUP BY p.per_id, per_fname, per_lname
GO

SELECT per_id, per_fname, per_lname,paid_invoice_total FROM dbo.v_paid_invoice_total ORDER BY sum_total DESC;
GO

SELECT * FROM information_schema.tables;
GO

sp_helptext'dbo.v_paid_invoice_total'
GO

DROP VIEW dbo.v_paid_invoice_total;

-- 2
SELECT p.per_id, per_fname, per_lname, sum(pay_amt) AS total_paid, (inv_total - sum(pay_amt)) invoice_diff
FROM person p
JOIN dbo.customer c ON p.per_id=c.per_id
JOIN dbo.contact ct ON c.per_id=ct.per_cid
JOIN dbo.[order] o ON ct.cnt_id=o.cnt_id
JOIN dbo.invoice i ON o.ord_id=i.ord_id
WHERE p.per_id=7
GROUP BY p.per_id, per_fname, per_lname, inv_total;

print'#2 Solution: create procedure (displays all customer'' outstanding balances):

';

IF OBJECT_ID(N'dbo.sp_all_customers_outstanding_balances',N'P') IS NOT NULL
DROP PROC dbo.sp_all_customers_outstanding_balances
GO

CREATE PROC dbo.sp_all_customers_outstanding_balances AS 
BEGIN
    SELECT p.per_id,per_fname,per_lname, sum(pay_amt) AS total_paid, (inv_total - sum(pay_amt)) invoice_diff
    FROM person p
    JOIN dbo.customer c ON p.per_id=c.per_id
    JOIN dbo.contact ct ON c.per_id=ct.per_cid
    JOIN dbo.[order] o ON ct.cnt_id=o.cnt_id
    JOIN dbo.invoice i ON o.ord_id=i.ord_id
    JOIN dbo.payment pt ON i.inv_id=pt.int_id
    GROUP BY p.per_id, per_fname, per_lname, inv_total
    ORDER BY invoice_diff DESC;
END
GO

EXEC dbo.sp_all_customers_outstanding_balances;

SELECT * FROM iww15.information_schema.routines
WHERE routine_type='PROCEDURE';
GO

sp_helptext'dbo.sp_all_customers_outstanding_balances'
GO

DROP PROC dbo.sp_all_customers_outstanding_balances;

-- 3
print'#3 Solution: create stored procedure to populate history table w/sales reps'' data when called

';

IF OBJECT_ID(N'dbo.sp_populate_srp_hist_table',N'P') IS NOT NULL
DROP PROC dbo.sp_populate_srp_hist_table
GO

CREATE PROC dbo.sp_populate_srp_hist_table AS
BEGIN
    INSERT INTO dbo.srp_hist
    (sht_id,per_id,sht_type,sht_modified,sht_modifier,sht_date,sht_yr_sales_goal,sht_yr_total_sales,sht_yr_total_comm,sht_notes)
    SELECT per_id, 'i', getDate(), SYSTEM_USER,getDate(), srp_yr_sales_goal,srp_ytd_comm,srp_notes FROM dbo.slsrep;
END
GO

print 'list table data before call:

';
SELECT * FROM dbo.slsrep;
SELECT * FROM dbo.srp_hist;

DELETE FROM dbo.srp_hist;

EXEC dbo.sp_populate_srp_hist_table;

print 'list table data after call:

';
SELECT * FROM dbo.slsrep;
SELECT * FROM dbo.srp_hist;

SELECT * FROM iww15.information_schema.routines
WHERE routine_type='PROCEDURE';
GO

sp_helptext'dbo.sp_populate_srp_hist_table'
GO

DROP PROC dbo.sp_populate_srp_hist_table;
GO

-- 4
print'#4 Solution: create a trigger that automatically adds a record to the sales reps'' history table for every record added to the sales rep table.

';

IF OBJECT_ID(N'dbo.trg_sales_history_insert',N'TR') IS NOT NULL
DROP TRIGGER dbo.trg_sales_history_insert
GO

CREATE TRIGGER dbo.trg_sales_history_insert
ON dbo.slsrep
AFTER INSERT AS 
BEGIN
    DECLARE
    @per_id_v SMALLINT,
    @sht_type_v CHAR(1),
    @sht_modified_v DATE,
    @sht_modifier_v VARCHAR(45),
    @sht_date_v DATE,
    @sht_yr_sales_goal_v DECIMAL(8,2),
    @sht_yr_total_sales_v DECIMAL(8,2),
    @sht_yr_total_comm_v DECIMAL(7,2),
    @sht_notes_v VARCHAR(255);

    SELECT
    @per_id_v = per_id,
    @sht_type_v = 'i',
    @sht_modified_v = getDate(),
    @sht_modifier_v = SYSTEM_USER,
    @sht_date_v = getDate(),
    @sht_yr_sales_goal_v = srp_yr_sales_goal,
    @sht_yr_total_sales_v = srp_ytd_sales,
    @sht_yr_total_comm_v = srp_ytd_comm,
    @sht_notes_v = srp_notes
    FROM INSERTED;

    INSERT INTO dbo.srp_hist
    (sht_id,per_id,sht_type,sht_modified,sht_modifier,sht_date,sht_yr_sales_goal,sht_yr_total_sales,sht_yr_total_comm,sht_notes)
    VALUES
    (@per_id_v,@sht_type_v,@sht_modified_v,@sht_modifier_v,@sht_date_v,@sht_yr_sales_goal_v,@sht_yr_total_sales_v,@sht_yr_total_comm_v,@sht_notes_v);
END
GO

print 'list table data after trigger fires:

';
SELECT * FROM slsrep;
SELECT * FROM srp_hist;

SELECT * FROM sys.triggers;
GO

DROP TRIGGER dbo.trg_sales_history_insert;
GO

print'#5 Solution: create a trigger that automatically adds a record to the product history table for every record added to the product table.

';

if OBJECT_ID(N'dbo.trg_product_history_insert',N'TR') IS NOT NULL
DROP TRIGGER dbo.trg_product_history_insert
GO

CREATE TRIGGER dbo.trg_product_history_insert
ON dbo.product
AFTER INSERT AS
BEGIN
    DECLARE
    @pro_id_v SMALLINT,
    @pht_modified_v DATE,
    @pht_cost_v DECIMAL(7,2),
    @pht_price_v DECIMAL(7,2),
    @pht_discount_v DECIMAL(3,0),
    @pht_notes_v VARCHAR(255);

    SELECT
    @pro_id_v = pro_id,
    @pht_modified_v = getDate(),
    @pht_cost_v = pro_cost,
    @pht_price_v = pro_price,
    @pht_discount_v = pro_discount,
    @pht_notes_v = pro_notes
    FROM INSERTED;

    INSERT INTO dbo.product_hist
    (pht_id,pro_id,pht_date,pht_cost,pht_price,pht_discount,pht_notes)
    VALUES
    (@pro_id_v,@pht_modified_v,@pht_cost_v,@pht_price_v,@pht_discount_v,@pht_notes_v);
END
GO

print'list table data before trigger fires:

';
SELECT * FROM product;
SELECT * FROM product_hist;

INSERT INTO dbo.product
(ven_id,pro_name,pro_descript,pro_weight,pro_qoh,pro_cost,pro_price,pro_discount,pro_notes)
VALUES
(3,'desk lamp','small desk lamp with red lights',3.6,14,5.98,11.99,15,'No discounts after sale.');

print'list table data after trigger fires:

';
SELECT * FROM product;
SELECT * FROM product_hist;

SELECT * FROM sys.triggers;
GO

sp_helptext'dbo.trg_product_history_insert'
GO

DROP TRIGGER dbo.trg_product_history_insert;
GO
