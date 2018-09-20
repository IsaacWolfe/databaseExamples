DROP DATABASE IF EXISTS lis3781;
CREATE DATABASE IF NOT EXISTS lis3781;

USE lis3781;

DROP TABLE IF EXISTS company;
CREATE TABLE IF NOT EXISTS company
(
    cmp_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    cmp_type enum('C-Corp','S-Corp','Non-Profit-Corp','LLC','Partnership'),
    cmp_street VARCHAR(30) NOT NULL,
    cmp_city VARCHAR(30) NOT NULL,
    cmp_state CHAR(2) NOT NULL,
    cmp_zip INT(9) UNSIGNED ZEROFILL NOT NULL COMMENT 'no dashes',
    cmp_phone BIGINT UNSIGNED NOT NULL,
    cmp_ytd_sales DECIMAL(10,2) UNSIGNED NOT NULL,
    cmp_email VARCHAR(100) NULL,
    cmp_url VARCHAR(100) NULL,
    cmp_notes VARCHAR(255) NULL,
    PRIMARY KEY (cmp_id)
)
ENGINE=InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci;

SHOW WARNINGS;

START TRANSACTION;
USE lis3781;
INSERT INTO lis3781.company (cmp_id, cmp_type, cmp_street, cmp_city, cmp_state, cmp_zip, cmp_phone, cmp_ytd_sales, cmp_email, cmp_url, cmp_notes)
VALUES
( NULL, 'C-Corp','408 Martin Luther King St','Tallahassee','FL','609814821','7271497821','50000000.00','ccorp@company.com','https://ccorp.org',NULL),
( NULL, 'S-Corp','3814 Counrtyside Blvd','Clearwater','FL','839281123','7279718833','3500000.00','scorp@company.com','https://scorp.net',NULL),
( NULL, 'Non-Profit-Corp','212 W College Ave','Tallahassee','FL','980724111','7271210001','9000000.00',NULL,NULL,NULL),
( NULL, 'Partnership','3945 Sandry Ridge Dr','Clearwater','FL','901409917','7271494924','450000.00',NULL,'https://partnership.org',NULL),
( NULL, 'LLC','1201 Gaines St','Tallahassee','FL','490107882','7270914022','9000000.00','llc@company.com',NULL,NULL);
COMMIT;

SHOW WARNINGS;

DROP TABLE IF EXISTS customer;
CREATE TABLE IF NOT EXISTS customer
(
    cus_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    cmp_id INT UNSIGNED NOT NULL,
    cus_ssn INT(9) UNSIGNED ZEROFILL NOT NULL,
    cus_type enum('Loyal','Discount','Impulse','Need-Based','Wandering'),
    cus_first VARCHAR(15) NOT NULL,
    cus_last VARCHAR(30) NOT NULL,
    cus_street VARCHAR(30) NULL,
    cus_city VARCHAR(30) NULL,
    cus_state CHAR(2) NULL,
    cus_zip INT(9) UNSIGNED ZEROFILL NULL,
    cus_phone BIGINT UNSIGNED NOT NULL,
    cus_email VARCHAR(100) NULL,
    cus_balance DECIMAL(7,2) UNSIGNED NULL,
    cus_tot_sales DECIMAL(7,2) UNSIGNED NULL,
    cus_notes VARCHAR(255) NULL,
    PRIMARY KEY (cus_id),

    UNIQUE INDEX ux_cus_ssn (cus_ssn ASC),
    INDEX idx_cmp_id (cmp_id ASC),

    CONSTRAINT fk_customer_company
        FOREIGN KEY (cmp_id)
        REFERENCES company (cmp_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
)
ENGINE=InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci;

SHOW WARNINGS;

START TRANSACTION;
USE lis3781;
INSERT INTO lis3781.customer (cus_id, cmp_id, cus_ssn, cus_type, cus_first, cus_last, cus_street, cus_city, cus_state, cus_zip, cus_phone, cus_email, cus_balance, cus_tot_sales, cus_notes)
VALUES
( NULL,1,928884123,'Loyal','Christian','Bennings','3124 Tennessee St','Tallahassee','FL','414890042','8509418827','christianb@gmail.com','49814.00','98243.00',NULL),
( NULL,2,984122499,'Discount','Terry','Crews','9898 W Michigan St','Tallahassee','FL','918499127','8509849112','terryc@gmail.com','8412.00','74823.00',NULL),
( NULL,3,478244591,'Impulse','Samantha','Miller','941 Farrier Trail Dr','Clearwater','FL','512598221','8504119125','samantham@gmail.com','38944.00','78890.00',NULL),
( NULL,4,192500424,'Need-Based','Ronald','Williams','498 Tarpon Woods Blvd','Clearwater','FL','827840012','8509814470','ronaldw@gmail.com','88219.00','75192.00',NULL),
( NULL,5,729849401,'Wandering','Micheal','Wheeler','4891 Landmark Blvd','Clearwater','FL','194102412','8509840100','michealw@gmail.com','98420.00','89124.00',NULL);
COMMIT;

SHOW WARNINGS;

-- Starting setting up accounts

-- Create and grant user3
CREATE USER 'user3'@'localhost' IDENTIFIED BY 'password3';
GRANT SELECT, UPDATE, DELETE ON lis3781.* TO 'user3'@'localhost';

-- Create and grant user4
CREATE USER 'user4'@'localhost' IDENTIFIED BY 'password4';
GRANT SELECT, INSERT ON lis3781.customer TO 'user4'@'localhost';

-- Testing to make sure it all worked correctly

SHOW GRANTS; -- As admin
SHOW GRANTS FOR user3;
SHOW GRANTS FOR user4;

SELECT USER(), VERSION(); -- From user4

SHOW TABLES; -- As admin
DESCRIBE COMPANY;
DESCRIBE CUSTOMER;

SELECT * FROM company;
SELECT * FROM customer;

START TRANSACTION;
SELECT * FROM company;
SELECT * FROM customer;

UPDATE company 
SET cmp_id = 6
WHERE cmp_id = 1;

SELECT * FROM company;
SELECT * FROM customer;
COMMIT;

START TRANSACTION;
SELECT * FROM company;

TEE /home/iwolfe/Documents/lis3781/lis3781_a2_reports.sql
DELETE FROM company 
WHERE cmp_id = 2;
NOTEE

SELECT * FROM company;
COMMIT;

-- Only from admin only on final step
DROP TABLE customer;
DROP TABLE company;
