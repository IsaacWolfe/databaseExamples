select 'drop, create, use database, create tables, display data:' as '';
do sleep(5);

DROP SCHEMA IF EXISTS iww15;
CREATE SCHEMA IF NOT EXISTS iww15;
USE iww15;

SET foreign_key_checks=0;

DROP TABLE IF EXISTS person;
CREATE TABLE IF NOT EXISTS person
(
    per_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_ssn BINARY(64) NULL,
    per_fname VARCHAR(15) NOT NULL,
    per_lname VARCHAR(30) NOT NULL,
    per_street VARCHAR(30) NOT NULL,
    per_city VARCHAR(30) NOT NULL,
    per_state CHAR(2) NOT NULL,
    per_zip INT(9) UNSIGNED ZEROFILL NOT NULL,
    per_email VARCHAR(100) NOT NULL,
    per_dob DATE NOT NULL,
    per_type ENUM('a','c','j') NOT NULL,
    per_notes VARCHAR(255) NULL,
    PRIMARY KEY (per_id),
    UNIQUE INDEX ux_per_ssn (per_ssn ASC)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE=utf8_unicode_ci;

SHOW WARNINGS;

DROP TABLE IF EXISTS attorney;
CREATE TABLE IF NOT EXISTS attorney
(
    per_id SMALLINT UNSIGNED NOT NULL,
    aty_start_date DATE NOT NULL,
    aty_end_date DATE NULL DEFAULT NULL,
    aty_hourly_rate DECIMAL(5,2) UNSIGNED NOT NULL,
    aty_years_in_practice TINYINT NOT NULL,
    aty_notes VARCHAR(255) NULL DEFAULT NULL,
    PRIMARY KEY (per_id),

    INDEX idx_per_id (per_id ASC),
    
    CONSTRAINT fk_attorney_person
    FOREIGN KEY (per_id)
    REFERENCES person (per_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

DROP TABLE IF EXISTS client;
CREATE TABLE IF NOT EXISTS client
(
    per_id SMALLINT UNSIGNED NOT NULL,
    cli_notes VARCHAR(255) NULL DEFAULT NULL,
    PRIMARY KEY (per_id),
    
    INDEX idx_per_id (per_id ASC),

    CONSTRAINT fk_client_person
    FOREIGN KEY (per_id)
    REFERENCES person (per_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

DROP TABLE IF EXISTS court;
CREATE TABLE IF NOT EXISTS court
(
    crt_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    crt_name VARCHAR(45) NOT NULL,
    crt_street VARCHAR(30) NOT NULL,
    crt_city VARCHAR(30) NOT NULL,
    crt_state CHAR(2) NOT NULL,
    crt_zip INT(9) UNSIGNED ZEROFILL NOT NULL,
    crt_phone BIGINT NOT NULL,
    crt_email VARCHAR(100) NOT NULL,
    crt_url VARCHAR(100) NOT NULL,
    crt_notes VARCHAR(255) NULL,
    PRIMARY KEY (crt_id)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

DROP TABLE IF EXISTS judge;
CREATE TABLE IF NOT EXISTS judge
(
    per_id SMALLINT UNSIGNED NOT NULL,
    crt_id TINYINT UNSIGNED NULL DEFAULT NULL,
    jud_salary DECIMAL(8,2) NOT NULL,
    jud_years_in_practice TINYINT UNSIGNED NOT NULL,
    jud_notes VARCHAR(255) NULL DEFAULT NULL,
    PRIMARY KEY (per_id),

    INDEX idx_per_id (per_id ASC),
    INDEX idx_crt_id (crt_id ASC),

	CONSTRAINT fk_judge_person
	FOREIGN KEY (per_id)
	REFERENCES person (per_id)
	ON DELETE NO ACTION
	ON UPDATE CASCADE,

    CONSTRAINT fk_judge_court
    FOREIGN KEY (crt_id)
    REFERENCES court (crt_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

DROP TABLE IF EXISTS judge_hist;
CREATE TABLE IF NOT EXISTS judge_hist
(
    jhs_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    jhs_crt_id TINYINT NULL,
    jhs_date TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    jhs_type ENUM('i','u','D') NOT NULL DEFAULT 'i',
    jhs_salary DECIMAL(8,2) NOT NULL,
    jhs_notes VARCHAR(255) NULL,
    PRIMARY KEY (jhs_id),

    INDEX idx_per_id (per_id ASC),

    CONSTRAINT fk_judge_hist_judge
    FOREIGN KEY (per_id)
    REFERENCES judge (per_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)
ENGINE =InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

DROP TABLE IF EXISTS `case`;
CREATE TABLE IF NOT EXISTS `case`
(
    cse_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    cse_type VARCHAR(45) NOT NULL,
    cse_description TEXT NOT NULL,
    cse_start_date DATE NOT NULL,
    cse_end_date DATE NULL,
    cse_notes VARCHAR(255) NULL,
    PRIMARY KEY (cse_id),

    INDEX idx_per_id (per_id ASC),

    CONSTRAINT fk_court_case_judge
    FOREIGN KEY (per_id)
    REFERENCES judge (per_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

DROP TABLE IF EXISTS bar;
CREATE TABLE IF NOT EXISTS bar
(
    bar_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    bar_name VARCHAR(45) NOT NULL,
    bar_notes VARCHAR(255) NULL,
    PRIMARY KEY (bar_id),

    INDEX idx_per_id (per_id ASC),

    CONSTRAINT fk_bar_attorney
    FOREIGN KEY (per_id)
    REFERENCES attorney (per_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

DROP TABLE IF EXISTS specialty;
CREATE TABLE IF NOT EXISTS specialty
(
    spc_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    spc_type VARCHAR(45) NOT NULL,
    spc_notes VARCHAR(255) NULL,
    PRIMARY KEY (spc_id),

    INDEX idx_per_id (per_id ASC),

    CONSTRAINT fk_specialty_attorney
    FOREIGN KEY (per_id)
    REFERENCES attorney (per_id)
    ON DELETE NO ACTION 
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

DROP TABLE IF EXISTS assignment;
CREATE TABLE IF NOT EXISTS assignment
(
    asn_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_cid SMALLINT UNSIGNED NOT NULL,
    per_aid SMALLINT UNSIGNED NOT NULL,
    cse_id SMALLINT UNSIGNED NOT NULL,
    asn_notes VARCHAR(255) NULL,
    PRIMARY KEY (asn_id),

    INDEX idx_per_cid (per_cid ASC),
    INDEX idx_per_aid (per_aid ASC),
    INDEX idx_cse_id (cse_id ASC),

    UNIQUE INDEX ux_per_cid_per_aid_cse_id (per_cid ASC, per_aid ASC, cse_id ASC),

    CONSTRAINT fk_assign_case
    FOREIGN KEY (cse_id)
    REFERENCES `case` (cse_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,

    CONSTRAINT fk_assignment_client
    FOREIGN KEY (per_cid)
    REFERENCES client (per_id)
    ON DELETE NO ACTION 
    ON UPDATE CASCADE,

    CONSTRAINT fk_assignment_attorney
    FOREIGN KEY (per_aid)
    REFERENCES attorney (per_id)
    ON DELETE NO ACTION 
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

DROP TABLE IF EXISTS phone;
CREATE TABLE IF NOT EXISTS phone
(
    phn_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    phn_num BIGINT UNSIGNED NOT NULL,
    phn_type ENUM('h','c','w','f') NOT NULL COMMENT 'home, cell, work, fax',
    phn_notes VARCHAR(255) NULL,
    PRIMARY KEY (phn_id),

    INDEX idx_per_id (per_id ASC),

    CONSTRAINT fk_phone_person
    FOREIGN KEY (per_id)
    REFERENCES person (per_id)
    ON DELETE NO ACTION 
    ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

SHOW WARNINGS;

-- match per_id values
-- person 1-15
-- client 1-5
-- attorney 6-10
-- judge 11-15

-- insert person table
START TRANSACTION;

INSERT INTO person
(per_id,per_ssn,per_fname,per_lname,per_street,per_city,per_state,per_zip,per_email,per_dob,per_type,per_notes)
VALUES
(NULL,NULL,'Christian','Bennings','3124 Tennessee St','Tallahassee','FL',414890042,'christianb@gmail.com','1923-10-03','c',NULL),
(NULL,NULL,'Terry','Crews','9898 W Michigan St','Tallahassee','FL',918499127,'terryc@gmail.com','1968-03-20','c',NULL),
(NULL,NULL,'Samantha','Miller','941 Farrier Trail Dr','Clearwater','FL',512598221,'samantham@gmail.com','1988-09-12','c',NULL),
(NULL,NULL,'Ronald','Williams','498 Tarpon Woods Blvd','Clearwater','FL',827840012,'ronaldw@gmail.com','1978-05-08','c',NULL),
(NULL,NULL,'Micheal','Wheeler','4891 Landmark Blvd','Clearwater','FL',194102412,'michealw@gmail.com','1994-07-19','c',NULL),
(NULL,NULL,'Steve','Rogers','437 Southern Drive','Tallahassee','FL',298481252,'steverogers@gmail.com','1954-02-22','a',NULL),
(NULL,NULL,'Tony','Stark','1007 Mountain Drive','Tallahassee','FL',981858912,'terryc@gmail.com','1992-09-02','a',NULL),
(NULL,NULL,'Diana','Prince','1242 Ingram Drive','Clearwater','FL',512598221,'dianap@gmail.com','1920-04-20','a',NULL),
(NULL,NULL,'Bruce','Wayne','498 Bats Rd','Clearwater','FL',827840012,'brucew@gmail.com','1981-08-17','a',NULL),
(NULL,NULL,'Michael','Scott','4891 Dunder St','Clearwater','FL',194102412,'micheals@gmail.com','1945-04-19','a',NULL),
(NULL,NULL,'Peter','Parker','3124 Spidey St','Tallahassee','FL',414890042,'peterp@gmail.com','1990-03-30','j',NULL),
(NULL,NULL,'Hank','Pym','9898 Anthill St','Tallahassee','FL',918499127,'hankp@gmail.com','1935-01-20','j',NULL),
(NULL,NULL,'Scott','Lang','941 Ant Jr Dr','Clearwater','FL',512598221,'scottl@gmail.com','1968-02-05','j',NULL),
(NULL,NULL,'Bruce','Banner','498 Lawrence Ave','Clearwater','FL',827840012,'bruceb@gmail.com','1929-06-10','j',NULL),
(NULL,NULL,'Steven','Strange','4891 Rover Ct','Clearwater','FL',194102412,'stevens@gmail.com','1982-03-13','j',NULL);

COMMIT;

-- insert phone table
START TRANSACTION;

INSERT INTO phone
(phn_id,per_id,phn_num,phn_type,phn_notes)
VALUES
(NULL,1,8509184428,'c',NULL),
(NULL,2,8508125985,'h',NULL),
(NULL,3,8500149015,'w',NULL),
(NULL,4,8500195498,'c',NULL),
(NULL,5,8509149851,'f',NULL),
(NULL,6,8509185985,'c',NULL),
(NULL,7,8509815511,'h',NULL),
(NULL,8,8509158955,'w',NULL),
(NULL,9,8501595912,'c',NULL),
(NULL,10,8508128951,'f',NULL),
(NULL,11,8509125981,'c',NULL),
(NULL,12,8509812411,'h',NULL),
(NULL,13,8501241112,'w',NULL),
(NULL,14,8501982895,'c',NULL),
(NULL,15,8501112412,'f',NULL);

COMMIT;

-- insert client table
START TRANSACTION;

INSERT INTO client
(per_id,cli_notes)
VALUES
(1,NULL),
(2,NULL),
(3,NULL),
(4,NULL),
(5,NULL);

COMMIT;

-- insert attorney table
START TRANSACTION;

INSERT INTO attorney
(per_id,aty_start_date,aty_end_date,aty_hourly_rate,aty_years_in_practice,aty_notes)
VALUES
(6,'2006-06-01',NULL,90,13,NULL),
(7,'2010-010-015',NULL,102,16,NULL),
(8,'2007-07-07',NULL,80,8,NULL),
(9,'2008-011-022',NULL,70,10,NULL),
(10,'2010-08-017',NULL,75,5,NULL);

COMMIT;

-- insert bar table
START TRANSACTION;

INSERT INTO bar
(bar_id,per_id,bar_name,bar_notes)
VALUES
(NULL,6,'Florida bar',NULL),
(NULL,7,'Mississippi bar',NULL),
(NULL,8,'Ocala bar',NULL),
(NULL,9,'Arizona bar',NULL),
(NULL,10,'Arizona bar',NULL),
(NULL,6,'Tallahassee bar',NULL),
(NULL,7,'Montana bar',NULL),
(NULL,8,'California bar',NULL),
(NULL,9,'Cincinatti bar',NULL),
(NULL,10,'Alabama bar',NULL),
(NULL,6,'Georgia bar',NULL),
(NULL,7,'Missouri bar',NULL),
(NULL,8,'Nevada bar',NULL),
(NULL,9,'New Mexico bar',NULL),
(NULL,10,'Colorado bar',NULL);

COMMIT;

-- insert specialty table
INSERT INTO specialty
(spc_id,per_id,spc_type,spc_notes)
VALUES
(NULL,6,'buisness',NULL),
(NULL,7,'traffic',NULL),
(NULL,8,'bankruptcy',NULL),
(NULL,9,'insurance',NULL),
(NULL,10,'insurance',NULL),
(NULL,6,'judicial',NULL),
(NULL,7,'environmental',NULL),
(NULL,8,'criminal',NULL),
(NULL,9,'real estate',NULL),
(NULL,10,'malpractice',NULL);

COMMIT;

-- insert court table
INSERT INTO court
(crt_id,crt_name,crt_street,crt_city,crt_state,crt_zip,crt_phone,crt_email,crt_url,crt_notes)
VALUES
(NULL,'Leon County Circut Court','301 South Monroe Street','Tallahassee','fl',323035292,8506065504,'lcc@fl.gov','https://www.leoncountycircutcourt.gov',NULL),
(NULL,'Clearwater County Circut Court','3819 Us 19 N','Clearwater','fl',981249812,7279124981,'cccc@fl.gov','https://www.clearwatercountycircutcourt.gov',NULL),
(NULL,'Florida Supreme Court','2819 World Dr','Orlando','fl',149812222,3289319121,'fsc@fl.gov','https://www.floridasupremecourt.gov',NULL),
(NULL,'Leon County Traffic Court','500 North Duval Street','Tallahassee','fl',323035292,8501924891,'ltc@fl.gov','https://www.leoncountytrafficcourt.gov',NULL),
(NULL,'Orange County Courthouse','300 South Beach Street','Daytona Beach','fl',419824111,9124091211,'occ@fl.gov','https://www.orangecountycourthouse.gov',NULL);

COMMIT;

-- insert judge table
START TRANSACTION;

INSERT INTO judge
(per_id,crt_id,jud_salary,jud_years_in_practice,jud_notes)
VALUES
(11,5,150000,10,NULL),
(12,4,185000,12,NULL),
(13,3,135000,8,NULL),
(14,2,170000,2,NULL),
(15,1,120000,4,NULL);

COMMIT;

-- insert judge_hist table
START TRANSACTION;

INSERT INTO judge_hist
(jhs_id,per_id,jhs_crt_id,jhs_date,jhs_type,jhs_salary,jhs_notes)
VALUES
(NULL,11,1,'2009-01-16','i',130000,NULL),
(NULL,12,2,'2011-12-26','i',140000,NULL),
(NULL,13,3,'2005-08-12','i',115000,NULL),
(NULL,14,4,'2015-05-06','i',174000,NULL),
(NULL,15,5,'2017-07-14','i',120000,NULL),
(NULL,11,1,'2015-04-08','i',130000,NULL),
(NULL,12,2,'2013-10-28','i',140000,NULL),
(NULL,13,3,'2006-04-23','i',115000,NULL),
(NULL,14,4,'2017-10-14','i',174000,NULL),
(NULL,15,5,'2012-06-07','i',120000,NULL);

COMMIT;

-- insert `case` table
START TRANSACTION;

INSERT INTO `case`
(cse_id,per_id,cse_type,cse_description,cse_start_date,cse_end_date,cse_notes)
VALUES
(NULL,11,'civil','client says rival is using logo without consent','2010-01-04',NULL,'Copyright infringement'),
(NULL,12,'criminal','client is charged with assualting husband during argument','2012-10-16',NULL,'assualt'),
(NULL,13,'civil','client broke ankle while shopping','2014-11-26',NULL,'slip and fall'),
(NULL,14,'criminal','client was charged with stealing several televisions','2016-07-13',NULL,'theft'),
(NULL,15,'criminal','client found in possesion of 10grams of cocaine','2017-12-12',NULL,'possesion of narcotics'),
(NULL,11,'civil','client alleges newspaper printed false information','2013-10-06',NULL,'defamation'),
(NULL,12,'criminal','client charged with murder of co worker, no alibi','2009-05-26',NULL,'murder'),
(NULL,13,'civil','client has run into money trouble and is filing bankruptcy','2016-10-16',NULL,'bankruptcy');

COMMIT;

-- insert assignment table
START TRANSACTION;

INSERT INTO assignment
(asn_id,per_cid,per_aid,cse_id,asn_notes)
VALUES
(NULL,1,6,7,NULL),
(NULL,2,6,6,NULL),
(NULL,3,7,2,NULL),
(NULL,4,8,2,NULL),
(NULL,5,9,5,NULL),
(NULL,1,10,1,NULL),
(NULL,2,6,3,NULL),
(NULL,3,7,8,NULL),
(NULL,4,8,8,NULL),
(NULL,5,9,8,NULL),
(NULL,4,10,4,NULL);

COMMIT;

-- Securing SSNs
SELECT 'Securing SSNs procedure then deleting' AS '';

DROP PROCEDURE IF EXISTS CreatePersonSSN;
DELIMITER $$
CREATE PROCEDURE CreatePersonSSN()
BEGIN
    DECLARE x,y INT;
    SET x=1;
    -- dynamically set amount of loops to amount of insert
    SELECT COUNT(*) INTO y FROM person;

    WHILE x <= y DO
        UPDATE person
        SET per_ssn=(SELECT unhex(sha2(FLOOR(000000001 + (RAND() * 1000000000)),512)))
        WHERE per_id=x;

    SET x=x+1;

    END WHILE;

END$$
DELIMITER ;
CALL CreatePersonSSN();

SHOW WARNINGS;

SELECT 'show populated per_ssn fields after calling stored proc' AS '';
SELECT per_id,length(per_ssn) FROM person ORDER BY per_id;
DO SLEEP(7);

DROP PROCEDURE IF EXISTS CreatePersonSSN;

SELECT 'Selecting from tables' AS '';
-- Verify data with selects
SELECT * FROM person;
DO SLEEP(3);

SELECT * FROM phone;
DO SLEEP(3);

SELECT * FROM client;
DO SLEEP(3);

SELECT * FROM attorney;
DO SLEEP(3);

SELECT * FROM specialty;
DO SLEEP(3);

SELECT * FROM bar;
DO SLEEP(3);

SELECT * FROM court;
DO SLEEP(3);

SELECT * FROM judge;
DO SLEEP(3);

SELECT * FROM judge_hist;
DO SLEEP(3);

SELECT * FROM `case`;
DO SLEEP(3);

SELECT * FROM assignment;
DO SLEEP(3);


SET foreign_key_checks=1;


/*
############### Start of reports ############### 
*/

-- question 1
DROP VIEW IF EXISTS v_attorney_info;
CREATE VIEW v_attorney_info AS
    SELECT
        concat(per_lname,",",per_fname) AS name,
        concat(per_street,",",per_city,",",per_state," ",per_zip) AS address,
        TIMESTAMPDIFF(year,per_dob,now()) AS age,
        concat('$',format(aty_hourly_rate,2)) as hourly_rate,
        bar_name,spc_type
    FROM person
    NATURAL JOIN attorney
    NATURAL JOIN bar
    NATURAL JOIN specialty
    ORDER BY per_lname;

SELECT 'display view v_attorney_info' AS '';
SELECT * FROM v_attorney_info;
DROP VIEW IF EXISTS v_attorney_info;
DO SLEEP(3);

-- question 2
SELECT 'Step a) Display all persons DOB months' AS '';
SELECT per_id,per_fname,per_lname,per_dob,monthname(per_dob) FROM person;
DO SLEEP(3);

SELECT 'Step b) Display patient judge data' AS '';
SELECT p.per_id,per_fname,per_lname,per_dob,per_type FROM person AS p NATURAL JOIN judge AS j;
DO SLEEP(3);

SELECT 'Step c) Stored procedure' AS '';
DROP PROCEDURE IF EXISTS sp_num_judges_born_by_month;
DELIMITER //
CREATE PROCEDURE sp_num_judges_born_by_month()
BEGIN
    SELECT month(per_dob) AS month,monthname(per_dob) AS month_name, count(*) AS count
    FROM person
    NATURAL JOIN judge
    GROUP BY month_name
    ORDER BY month;
END //
DELIMITER ;

SELECT 'Calling sp_num_judges_born_by_month()' AS '';

CALL sp_num_judges_born_by_month();
DO SLEEP(3);

DROP PROCEDURE IF EXISTS sp_num_judges_born_by_month;

-- question 3

DROP PROCEDURE IF EXISTS sp_cases_and_judges;
DELIMITER //
CREATE PROCEDURE sp_cases_and_judges()
BEGIN
    SELECT per_id,cse_id,cse_type,cse_description,
    concat(per_fname," ",per_lname) AS name,
    concat('(',substring(phn_num,1,3),')',substring(phn_num,4,3),'-',substring(phn_num,7,4)) AS judge_office_num,
    phn_type,jud_years_in_practice,cse_start_date,cse_end_date
    FROM person
    NATURAL JOIN judge
    NATURAL JOIN `case`
    NATURAL JOIN phone
    WHERE per_type='j'
    ORDER BY per_lname;

END//
DELIMITER ;

SELECT 'Calling sp_cases_and_judges()' AS '';
CALL sp_cases_and_judges();
DROP PROCEDURE IF EXISTS sp_cases_and_judges;
DO SLEEP(5);

-- question 4
SELECT 'Show person data before adding record' AS '';
SELECT per_id,per_fname,per_lname FROM person;
DO SLEEP(2);

INSERT INTO person
(per_id,per_ssn,per_fname,per_lname,per_street,per_city,per_state,per_zip,per_email,per_dob,per_type,per_notes)
VALUES
(NULL,unhex(sha2(0000000000,512)),'Bobby','Sue','123 Main St','Panama City Beach','FL',324530221,'bsue@fl.gov','1962-05-16','j','new district judge');

SELECT 'Show person data after adding records' AS '';
SELECT per_id,per_fname,per_lname FROM person;
DO SLEEP(2);

SELECT 'Show judge/judge_hist data before the after insert transaction' AS '';
SELECT * FROM judge;
SELECT * FROM judge_hist;
DO SLEEP(2);

DROP TRIGGER IF EXISTS trg_judge_history_after_insert;

DELIMITER //
CREATE TRIGGER trg_judge_history_after_insert
AFTER INSERT ON judge
FOR EACH ROW
    BEGIN
        INSERT INTO judge_hist
        (per_id,jhs_crt_id,jhs_date,jhs_type,jhs_salary,jhs_notes)
        VALUES
        (NEW.per_id,NEW.crt_id,current_timestamp(),'i',NEW.jud_salary,concat("modifying user: ",user()," Notes: ",NEW.jud_notes));
    END//

DELIMITER ;

SELECT 'Fire trigger by inserting into judge' AS '';
DO SLEEP(2);

INSERT INTO judge
(per_id,crt_id,jud_salary,jud_years_in_practice,jud_notes)
VALUES
((SELECT count(per_id) FROM person),3,175000,31,'Transferred from neighboring jurisdiction');

SELECT 'Show judge/judge_hist data after the after insert transaction' AS '';
SELECT * FROM judge;
SELECT * FROM judge_hist;
DO SLEEP(3);

/* Dont drop trigger while testing */ 
/* DROP TRIGGER IF EXISTS trg_judge_history_after_insert; */

-- question 5
SELECT 'Show data before the after update trigger' AS '';
SELECT * FROM judge;
SELECT * FROM judge_hist;
DO SLEEP(3);

DROP TRIGGER IF EXISTS trg_judge_history_after_update;
DELIMITER //
CREATE TRIGGER trg_judge_history_after_update
AFTER UPDATE ON judge
FOR EACH ROW
    BEGIN
        INSERT INTO judge_hist
        (per_id,jhs_crt_id,jhs_date,jhs_type,jhs_salary,jhs_notes)
        VALUES
        (NEW.per_id,NEW.crt_id,CURRENT_TIMESTAMP(),'u',NEW.jud_salary,concat("modifying user: ",user()," Notes: ",NEW.jud_notes));
    END //

DELIMITER ;

SELECT 'Fire trigger by updating judge' AS '';
DO SLEEP(2);

UPDATE judge
SET jud_salary=190000,jud_notes='sennior justice-longest serving member'
WHERE per_id=16;

SELECT 'Show data after the after update trigger' AS '';
SELECT * FROM judge;
SELECT * FROM judge_hist;
DO SLEEP(3);

DROP TRIGGER IF EXISTS trg_judge_history_after_update;

-- question 6
DROP PROCEDURE IF EXISTS sp_add_judge_record;
DELIMITER //

CREATE PROCEDURE sp_add_judge_record()
BEGIN
    INSERT INTO judge
    (per_id,crt_id,jud_salary,jud_years_in_practice,jud_notes)
    VALUES
    (6,1,110000,0,concat("New judge was former attorney.","Modifying event creator: ",current_user()));
END //

DELIMITER ;

-- check to make sure events are enabled
SHOW VARIABLES LIKE 'event_scheduler';

-- if not to turn on execute
SET GLOBAL event_scheduler = ON;
SHOW VARIABLES LIKE 'event_scheduler';

-- Check data before event 
SELECT * FROM judge;
SELECT * FROM judge_hist;
DO SLEEP(2);

DROP EVENT IF EXISTS one_time_add_judge;
DELIMITER //
CREATE EVENT IF NOT EXISTS one_time_add_judge
ON SCHEDULE
AT NOW() + INTERVAL 1 HOUR
COMMENT 'adds a judge record only one at a time'
DO
    BEGIN
        CALL sp_add_judge_record();
    END//

DELIMITER ;

SHOW EVENTS FROM iww15;
DO SLEEP(3);

SHOW PROCESSLIST;
DO SLEEP(3);

SELECT 'Show data after the event' AS '';
SELECT * FROM judge;
SELECT * FROM judge_hist;
DO SLEEP(5);

-- extra credit
DROP EVENT IF EXISTS remove_judge_history;

DELIMITER //
CREATE EVENT IF NOT EXISTS remove_judge_history
ON SCHEDULE
EVERY 2 MONTH
STARTS NOW() + INTERVAL 3 WEEK
ENDS NOW() + INTERVAL 4 YEAR
COMMENT 'keeps only the first 100 judge records'
DO
    BEGIN
        DELETE FROM judge_hist WHERE jhs_id > 100;
    END //

DELIMITER ;

-- DROP IF EXISTS remove_judge_history;
