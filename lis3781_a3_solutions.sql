-- TODO Pull csv's from data
DROP DATABASE IF EXISTS iww15;
CREATE DATABASE iww15;
USE iww15;

/* USE iww15; */

set foreign_key_checks=0;

DROP TABLE IF EXISTS customer;
CREATE TABLE customer
(
    cus_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    srp_id SMALLINT UNSIGNED NOT NULL COMMENT 'fk to slsrep',
    cus_ssn INT(9) UNSIGNED ZEROFILL NOT NULL,
    cus_fname VARCHAR(15) NOT NULL,
    cus_lname VARCHAR(30) NOT NULL,
    cus_street VARCHAR(30) NOT NULL,
    cus_city VARCHAR(30) NOT NULL,
    cus_state CHAR(2) NOT NULL,
    cus_zip INT(9) UNSIGNED ZEROFILL NOT NULL,
    cus_phone BIGINT UNSIGNED NOT NULL,
    cus_email VARCHAR(100) DEFAULT NULL,
    cus_balance DECIMAL(9,2) UNSIGNED NOT NULL,
    cus_total_sales DECIMAL(9,2) UNSIGNED NOT NULL,
    cus_notes VARCHAR(255) NULL,
    PRIMARY KEY (cus_id),

    INDEX idx_srp_id (srp_id ASC),
    INDEX idx_cus_ssn (cus_ssn ASC),
    INDEX idx_cus_lname (cus_lname ASC),

    CONSTRAINT fk_customer_slsrep
    FOREIGN KEY (srp_id)
    REFERENCES slsrep (srp_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
)
ENGINE=InnoDB
DEFAULT CHARACTER SET utf8
COLLATE utf8_general_ci;

SHOW WARNINGS;

INSERT INTO customer
(cus_id, srp_id, cus_ssn, cus_fname, cus_lname, cus_street, cus_city, cus_state, cus_zip, cus_phone, cus_email, cus_balance, cus_total_sales, cus_notes)
VALUES
(NULL,1,928884123, 'Christian','Bennings','3124 Tennessee St','Tallahassee','FL','414890042','8509418827','christianb@gmail.com','49814.00','98243.00',NULL),
(NULL,2,984122499, 'Terry','Crews','9898 W Michigan St','Tallahassee','FL','918499127','8509849112','terryc@gmail.com','8412.00','74823.00',NULL),
(NULL,3,478244591, 'Samantha','Miller','941 Farrier Trail Dr','Clearwater','FL','512598221','8504119125','samantham@gmail.com','38944.00','78890.00',NULL),
(NULL,4,192500424,'Ronald','Williams','498 Tarpon Woods Blvd','Clearwater','FL','827840012','8509814470','ronaldw@gmail.com','88219.00','75192.00',NULL),
(NULL,5,729849401, 'Micheal','Wheeler','4891 Landmark Blvd','Clearwater','FL','194102412','8509840100','michealw@gmail.com','98420.00','89124.00',NULL); 

SHOW WARNINGS;

DROP TABLE IF EXISTS dealership;
CREATE TABLE IF NOT EXISTS dealership
(
    dlr_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    dlr_name VARCHAR(30) NOT NULL,
    dlr_street VARCHAR(30) NOT NULL,
    dlr_city VARCHAR(30) NOT NULL,
    dlr_state CHAR(2) NOT NULL,
    dlr_zip INT(9) UNSIGNED ZEROFILL NOT NULL,
    dlr_phone BIGINT UNSIGNED NOT NULL, 
    dlr_ytd_sales DECIMAL(10,2) UNSIGNED NOT NULL,
    dlr_email VARCHAR(100) NOT NULL DEFAULT 'info@mydealership.com',
    dlr_url VARCHAR(100) NOT NULL,
    dlr_notes VARCHAR(255) NULL,
    PRIMARY KEY (dlr_id),

    INDEX idx_dlr_name (dlr_name ASC)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET utf8
COLLATE utf8_general_ci;

SHOW WARNINGS;

INSERT INTO dealership
(dlr_id, dlr_name, dlr_street, dlr_city, dlr_state, dlr_zip, dlr_phone, dlr_ytd_sales, dlr_email, dlr_url, dlr_notes)
VALUES
(NULL, 'Chevy of Tallahassee', '421 Mahan St', 'Tallahassee', 'FL', 482918115, 8505128491, 84212201.00, 'tallahassee@chevy.com', 'https://chevyoftallahassee.com', NULL),
(NULL, 'Chrysler of Tallahassee', '3921 W Tennessee St', 'Tallahassee', 'FL', 491298459, 8501894941, 76000125.00, 'tallahassee@chrysler.com', 'https://chrysleroftallahassee.com', NULL),
(NULL, 'Toyota of Tampa', '4819 US 19', 'Tampa', 'FL', 984918140, 7279149812, 40109242.00, 'tampa@toyota.com', 'https://toyotaoftampa.com', NULL),
(NULL, 'Toyota of Tallahassee', '8482 Gaines St', 'Tallahassee', 'FL', 844901240, 8508201400, 47551000.00, 'tallahassee@toyota.com', 'https://toyotaoftallahassee.com', NULL),
(NULL, 'Honda of Tallahassee', '801 Duval St', 'Tallahassee', 'FL', 894198241, 8500924121, 75190124.00, 'tallahassee@honda.com', 'https://hondaoftallahassee.com', NULL);

SHOW WARNINGS;

DROP TABLE IF EXISTS slsrep;
CREATE TABLE slsrep
(
    srp_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT, 
    dlr_id SMALLINT UNSIGNED NOT NULL,
    srp_ssn INT(9) UNSIGNED ZEROFILL NOT NULL,
    srp_fname VARCHAR(15) NOT NULL,
    srp_lname VARCHAR(30) NOT NULL,
    srp_dob DATE NOT NULL,
    srp_street VARCHAR(30) NOT NULL,
    srp_city VARCHAR(30) NOT NULL,
    srp_state CHAR(2) NOT NULL,
    srp_zip INT(9) UNSIGNED ZEROFILL NOT NULL,
    srp_phone BIGINT UNSIGNED NOT NULL,
    srp_email VARCHAR(100) NOT NULL,
    srp_total_sales DECIMAL(10,2) UNSIGNED NOT NULL,
    srp_comm DECIMAL(7,2) NOT NULL,
    srp_notes VARCHAR(255) NULL,
    PRIMARY KEY (srp_id),

    INDEX idx_dlr_id (dlr_id ASC),
    INDEX idx_srp_ssn (srp_ssn ASC),
    INDEX idx_srp_lname (srp_lname ASC),

    CONSTRAINT fk_slsrep_dealership
    FOREIGN KEY (dlr_id)
    REFERENCES dealership (dlr_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET utf8
COLLATE utf8_general_ci;

SHOW WARNINGS;

INSERT INTO slsrep
(srp_id, dlr_id, srp_ssn, srp_fname, srp_lname, srp_dob, srp_street, srp_city, srp_state, srp_zip, srp_phone, srp_email, srp_total_sales, srp_comm, srp_notes)
VALUES
(NULL, 1, 412518221, 'Sally', 'Louise', '1958-10-22', '3219 Sandy Ridge Dr', 'Clearwater', 'FL', 389018492, 7279428323, 'sallyl@gmail.com', 57848291.00, 34185.00, NULL),
(NULL, 2, 489129842, 'Mike', 'Lopaz', '1988-02-05', '4892 W College Ave', 'Tallahassee', 'FL', 841928940, 8509182841, 'mikel@gmail.com', 30194221.00, 50124.00, NULL),
(NULL, 3, 918498251, 'Miguel', 'Sanchez', '1990-05-13', '8419 N Copeland St', 'Tallahassee', 'FL', 821494155, 8508124981, 'miguels@gmail.com', 98419242.00, 87992.00, NULL),
(NULL, 4, 918249814, 'Diane', 'Smith', '1983-09-06', 'W Carolina St', 'Tallahassee', 'FL', 918249814, 8508912844, 'dianes@gmail.com', 49124895.00, 22843.00, NULL),
(NULL, 5, 891248942, 'Timothy', 'Howze', '1978-11-30', '9841 W Call St', 'Tallahassee', 'FL', 912498451, 8500124091, 'timothyh@gmail.com', 98419820.00, 49020.00, NULL);

SHOW WARNINGS;

DROP TABLE IF EXISTS vehicle;
CREATE TABLE vehicle
(
    veh_vin CHAR(17) NOT NULL,
    dlr_id SMALLINT UNSIGNED NOT NULL,
    cus_id SMALLINT UNSIGNED DEFAULT NULL,
    veh_type VARCHAR(5) NOT NULL DEFAULT 'auto' COMMENT 'auto, suv, truck, van',
    veh_make VARCHAR(20) NOT NULL,
    veh_model VARCHAR(25) NOT NULL,
    veh_year YEAR(4) NOT NULL,
    veh_price DECIMAL(8,2) UNSIGNED NOT NULL,
    veh_notes VARCHAR(255) NULL,
    PRIMARY KEY (veh_vin),

    INDEX idx_dlr_id (dlr_id ASC),
    INDEX idx_cus_id (cus_id ASC),

    CONSTRAINT fk_vehicle_dealership
    FOREIGN KEY (dlr_id)
    REFERENCES dealership (dlr_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_vehicle_customer
    FOREIGN KEY (cus_id)
    REFERENCES customer (cus_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET utf8
COLLATE utf8_general_ci;

SHOW WARNINGS;

INSERT INTO vehicle
(veh_vin, dlr_id, cus_id, veh_type, veh_make, veh_model, veh_year, veh_price, veh_notes)
VALUES
('82hnk280sk0a9kcjs', 1, 1, 'truck', 'Ford', 'Ranger', 2008, 15500.00, null),
('89124h2h3ir9osa9a', 2, 2, 'van', 'Honda', 'Element', 2008, 20060.00, null),
('KJAS9892BK3415L12', 3, NULL, 'suv', 'Toyota', '4Runner', 2004, 10000.00, NULL),
('9AOHC124981B1451L', 4, 4, 'truck', 'GMC', 'Sierra', 2018, 60493.00, NULL),
('12KJB5189124L2140', 5, NULL, 'auto', 'Porsche', 'Cayan', 2016, 90500.00, NULL);

SHOW WARNINGS;

SET foreign_key_checks=1;

/* tee /home/iwolfe/Documents/lis3781/a3/lis3781_a3_reports.txt */
/* tee /home/iww15/db/lis3781_a3_reports.sql -- use to create report on remote cci server */

-- question 9
SELECT fk.table_schema as 'schema', fk.table_name as 'table', fk.column_name as 'column', fk.constraint_name as 'constraint_name' FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE_fk WHERE fk.referenced_column_name IS NOT NULL AND fk.table_schema LIKE 'iww15'; -- TODO change username 

-- question 10
SELECT * FROM dealership;
SELECT * FROM vehicle;

UPDATE dealership SET dlr_id=6 WHERE dlr_id=1;

SELECT * FROM dealership;
SELECT * FROM vehicle;

-- question 11
DELETE FROM slsrep WHERE srp_id=1;

-- question 12
DROP VIEW IF EXISTS v_cus_balance;
CREATE VIEW v_cus_balance as 
SELECT cus_fname, cus_lname, CONCAT('$',FORMAT(cus_balance, 2)) as `customer_balance` 
FROM customer
ORDER BY cus_balance DESC;

SELECT * FROM v_cus_balance;
DROP VIEW IF EXISTS v_cus_balance;

-- question 13
SELECT veh_year, veh_price FROM vehicle;

DROP VIEW IF EXISTS v_veh_discount;
CREATE VIEW v_veh_discount as 
SELECT veh_year, CONCAT('$', FORMAT(veh_price * .95, 2)) as `5% discount 2yr old vehicles`
FROM vehicle
WHERE veh_year < date_sub(curdate(), interval 2 year);

SELECT * FROM v_veh_discount;
DROP VIEW IF EXISTS v_veh_discount;

-- question 14
SELECT * FROM vehicle;

DROP PROCEDURE IF EXISTS sp_total_stock_value_year_range;
DELIMITER //
CREATE PROCEDURE sp_total_stock_value_year_range(IN beginDate year, IN endDate year)
BEGIN
    SELECT veh_year, sum(veh_price) as tot_sold_vehicles
    FROM vehicle
    WHERE cus_id IS NOT NULL
    AND veh_year between beginDate AND endDate
    GROUP BY veh_year;

    SELECT veh_year, sum(veh_price) as tot_unsold_vehicles
    FROM vehicle
    WHERE cus_id IS NULL 
    AND veh_year BETWEEN beginDate AND endDate
    GROUP BY veh_year;
END //

DELIMITER ;

SELECT cus_id, veh_year, veh_price FROM vehicle;

CALL sp_total_stock_value_year_range('2005','2010');

-- question 15
/* DROP PROCEDURE IF EXISTS sp_total_stock_value_year_range; */

-- question 16
DROP TRIGGER IF EXISTS trg_srp_comm;
DELIMITER //
CREATE TRIGGER trg_srp_comm
AFTER INSERT ON vehicle
FOR EACH ROW
BEGIN
    UPDATE slsrep SET srp_comm=round((srp_comm * 1.03), 2) WHERE srp_total_sales>=500000;
END //
DELIMITER ;

SELECT * FROM vehicle;
SELECT * FROM slsrep;

INSERT INTO vehicle
(veh_vin, dlr_id, cus_id, veh_type, veh_make, veh_model, veh_year, veh_price, veh_notes)
VALUES
('82JSKCLAOW99AJKQ3A', 5, 4, 'auto', 'Nissan', 'GTR', 2016, 80000.00, NULL);

SELECT * FROM vehicle;
SELECT * FROM slsrep;

-- question 17
show triggers;

-- question 18
/* DROP TRIGGER IF EXISTS trg_srp_comm; */

-- question 19 Extra Credit
START TRANSACTION;
SELECT * FROM vehicle;
select srp_lname, CONCAT('$', FORMAT(srp_comm, 2)) as srp_comm, CONCAT('$', FORMAT(srp_total_sales, 2)) as srp_total_sales FROM slsrep;

INSERT INTO vehicle
(veh_vin, dlr_id, cus_id, veh_type, veh_make, veh_model, veh_year, veh_price, veh_notes)
VALUES
('981RHO12OI4IO10LAA', 3, NULL, 'auto', 'Chrysler', '300', 2009, 57890.00, NULL);
SHOW WARNINGS;

SELECT * FROM vehicle;
SELECT srp_lname, CONCAT('$', FORMAT(srp_comm, 2)) as sales_rep_comm, CONCAT('$', FORMAT(srp_total_sales, 2)) as sales_rep_total_sales
FROM slsrep;

SHOW WARNINGS;
/* COMMIT; */
ROLLBACK; -- Use rollback to test and make it nonpermanent
-- To test rollback
SELECT srp_lname, CONCAT('$', FORMAT(srp_comm, 2)) as sales_rep_comm, CONCAT('$', FORMAT(srp_total_sales, 2)) as sales_rep_total_sales FROM slsrep;

DROP TRIGGER IF EXISTS trg_srp_comm;
SHOW WARNINGS;

-- question 20 Extra Credit
SELECT ROUTINE_TYPE, ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINESCHEMA='iww15';

/* notee */
