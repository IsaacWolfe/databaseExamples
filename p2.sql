SET ANSI_WARNINGS ON;
GO

use master;
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'iww15')
DROP DATABASE iww15;
GO

IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'iww15')
DROP DATABASE iww15;
GO

use iww15;
GO


IF OBJECT_ID (N'dbo.patient',N'U') IS NOT NULL
DROP TABLE dbo.patient;
GO

CREATE TABLE dbo.patient
(
    pat_id SMALLINT NOT NULL IDENTITY(1,1),
    pat_ssn INT NOT NULL CHECK(pat_ssn > 0 and pat_ssn <= 999999999),
    pat_fname VARCHAR(15) NOT NULL,
    pat_lname VARCHAR(30) NOT NULL,
    pat_street VARCHAR(30) NOT NULL,
    pat_city VARCHAR(30) NOT NULL,
    pat_state CHAR(2) NOT NULL DEFAULT 'FL',
    pat_zip INT NOT NULL CHECK(pat_zip > 0 and pat_zip <= 999999999),
    pat_phone BIGINT NOT NULL CHECK(pat_phone > 0 and pat_phone <= 9999999999),
    pat_email VARCHAR(100) NULL,
    pat_dob DATE NOT NULL,
    pat_gender CHAR(1) NOT NULL CHECK(pat_gender IN('m','f')),
    pat_notes VARCHAR(45) NULL,
    PRIMARY KEY (pat_id),

    CONSTRAINT ux_pat_ssn unique nonclustered (pat_ssn ASC)
);

IF OBJECT_ID (N'dbo.medication', N'U') IS NOT NULL
DROP TABLE dbo.medication;

CREATE TABLE dbo.medication
(
    med_id SMALLINT NOT NULL IDENTITY(1,1),
    med_name VARCHAR(100) NOT NULL,
    med_price DECIMAL(5,2) NOT NULL CHECK(med_price > 0),
    med_shelf_life DATE NOT NULL,
    med_notes VARCHAR(255) NULL,
    PRIMARY KEY (med_id)
);

IF OBJECT_ID (N'dbo.perscription', N'U') IS NOT NULL
DROP TABLE dbo.persciption;


CREATE TABLE dbo.prescription
(
    pre_id SMALLINT NOT NULL IDENTITY(1,1),
    pat_id SMALLINT NOT NULL,
    med_id SMALLINT NOT NULL,
    pre_date DATE NOT NULL,
    pre_dosage VARCHAR(255) NOT NULL,
    pre_num_refills VARCHAR(3) NOT NULL,
    pre_notes VARCHAR(255) NULL,
    PRIMARY KEY (pre_id),

    CONSTRAINT ux_pat_id_med_id_pre_date unique nonclustered (pat_id ASC, med_id ASC, pre_date ASC),

    CONSTRAINT fk_perscription_patient
        FOREIGN KEY (pat_id)
        REFERENCES dbo.patient (pat_id)
        ON DELETE NO ACTION 
        ON UPDATE CASCADE,

    CONSTRAINT fk_perscription_medication
        FOREIGN KEY (med_id)
        REFERENCES dbo.medication (med_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);

IF OBJECT_ID (N'dbo.treatment', N'U') IS NOT NULL
DROP TABLE dbo.treatment;

CREATE TABLE dbo.treatment
(
    trt_id SMALLINT NOT NULL IDENTITY(1,1),
    trt_name VARCHAR(255) NOT NULL, 
    trt_price DECIMAL(8,2) NOT NULL CHECK(trt_price > 0),
    trt_notes VARCHAR(255) NULL,
    PRIMARY KEY (trt_id)
);

IF OBJECT_ID (N'dbo.physician', N'U') IS NOT NULL
DROP TABLE dbo.physician;
GO

CREATE TABLE dbo.physician
(
    phy_id SMALLINT NOT NULL IDENTITY(1,1),
    phy_specialty VARCHAR(25) NOT NULL,
    phy_fname VARCHAR(15) NOT NULL,
    phy_lname VARCHAR(30) NOT NULL,
    phy_street VARCHAR(30) NOT NULL,
    phy_city VARCHAR(30) NOT NULL,
    phy_state CHAR(2) NOT NULL DEFAULT 'FL',
    phy_zip INT NOT NULL CHECK(phy_zip > 0 and phy_zip <= 999999999),
    phy_phone BIGINT NOT NULL CHECK(phy_phone > 0 and phy_phone <= 9999999999),
    phy_fax BIGINT NOT NULL CHECK(phy_fax > 0 and phy_fax <= 9999999999),
    phy_email VARCHAR(100) NULL,
    phy_url VARCHAR(100) NULL,
    phy_notes VARCHAR(255) NULL,
    PRIMARY KEY (phy_id)
);

IF OBJECT_ID (N'dbo.patient_treatment', N'U') IS NOT NULL
DROP TABLE dbo.patient_treatment;

CREATE TABLE dbo.patient_treatment
(
    ptr_id SMALLINT NOT NULL IDENTITY(1,1),
    pat_id SMALLINT NOT NULL,
    phy_id SMALLINT NOT NULL,
    trt_id SMALLINT NOT NULL,
    ptr_date DATE NOT NULL,
    ptr_start TIME(0) NOT NULL,
    ptr_end TIME(0) NOT NULL,
    ptr_results VARCHAR(255) NULL,
    ptr_notes VARCHAR(255) NULL,
    PRIMARY KEY (ptr_id),

    CONSTRAINT ux_pat_id_phy_id_trt_id_ptr_date unique nonclustered (pat_id ASC, phy_id ASC, trt_id ASC, ptr_id ASC),

    CONSTRAINT fk_patient_treatment_patient
        FOREIGN KEY (pat_id)
        REFERENCES dbo.patient (pat_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,

    CONSTRAINT fk_patient_tratment_physician
        FOREIGN KEY (phy_id)
        REFERENCES dbo.physician (phy_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,

    CONSTRAINT fk_patient_treament_treatment
        FOREIGN KEY (trt_id)
        REFERENCES dbo.treatment (trt_id)
        ON DELETE NO ACTION 
        ON UPDATE CASCADE
);

IF OBJECT_ID (N'dbo.administration_lu', N'U') IS NOT NULL
DROP TABLE dbo.administration_lu;

CREATE TABLE dbo.administration_lu
(
    pre_id SMALLINT NOT NULL,
    ptr_id SMALLINT NOT NULL,
    PRIMARY KEY (pre_id, ptr_id),

    CONSTRAINT fk_administration_lu_prescription
        FOREIGN KEY (pre_id)
        REFERENCES dbo.prescription (pre_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,

    CONSTRAINT fk_administration_lu_treatment
        FOREIGN KEY (ptr_id)
        REFERENCES dbo.patient_treatment (ptr_id)
        ON DELETE NO ACTION 
        ON UPDATE NO ACTION
);

--Showing the taboes created 
SELECT * FROM information_schema.tables;

EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL"

INSERT INTO dbo.patient
(pat_ssn, pat_fname, pat_lname, pat_street, pat_city, pat_state, pat_zip, pat_phone, pat_email, pat_dob, pat_gender, pat_notes)
VALUES
('123456789', 'Isaac', 'Wolfe', '408 W College Ave', 'Tallahassee', 'FL', '32301', 11234567890, 'iwolfe@gmail.com', '12-03-1997', 'm', NULL),
('987654321', 'Jessica', 'King', '3219 Snady Ridge dr', 'Clearwater', 'FL', '33761', 19812491241, 'jking@gmail.com', '11-30-1998', 'f', NULL),
('192478124', 'Tod', 'Smith', '312 King st', 'Tallahassee', 'FL', '32302', 18714912892, 'tsmith@gmail.com', '04-18-1998', 'm', NULL),
('981240981', 'Charles', 'Miller', '841 Prince st', 'Tallahassee', 'FL', '32301', 18498112482, 'charlesmiller@gmail.com', '12-22-1979', 'm', NULL),
('981489712', 'Sara', 'Parker', '212 Martin Luther King blvd', 'Tallahassee', 'FL', '32301', 19871498121, 'sparker@gmail.com', '02-07-1980', 'f', NULL);

INSERT INTO dbo.medication
(med_name, med_price, med_shelf_life, med_notes)
VALUES
('Ablify', 300.00, '02-01-2018', NULL),
('Corttono', 150.00, '08-01-2018', NULL),
('Insulin', 250.00, '05-15-2018', NULL),
('Mitoral', 120.00, '08-22-2018', NULL),
('Cartenol', 350.00, '05-02-2018', NULL);

INSERT INTO dbo.prescription
(pat_id, med_id, pre_date, pre_dosage, pre_num_refills, pre_notes)
VALUES
(1,1,'2015-12-20','Take one per day','1',NULL),
(1,2,'2015-02-15','Take twice per day','3',NULL),
(2,3,'2015-10-10','Take as needed','4',NULL),
(3,5,'2015-05-03','Take one per day','2',NULL),
(4,3,'2015-07-08','Take one before bed','2',NULL);

INSERT INTO dbo.physician
(phy_specialty, phy_fname, phy_lname, phy_street, phy_city, phy_state, phy_zip, phy_phone, phy_fax, phy_url, phy_notes)
VALUES
('pediatrician', 'Susane', 'Hart', '412 Copland rd', 'Tallahassee', 'FL', '32301', 18987651234, '1257389282', 'susanehart@gmail.com', 'susanehart.com', NULL),
('family medicine', 'Greg', 'Williams', '481 Tennessee st', 'Tallahassee', 'FL', '32301', 18912498124, '9821790120', 'gwilliams@gmail.com', 'gregwilliams.com', NULL),
('cancer surgery', 'Ronald', 'Berkhart', '89 South Gate av', 'Clearwater', 'FL', '33761', 19002941224, '9140014222', 'ronaldb@gmail.com', 'ronaldb.com', NULL),
('cardiovascular', 'Kevin', 'Burns', '821 Collins ln', 'Miami', 'FL', '31419', '9910274998', 19018427011, 'kevinburns@gmail.com', 'kevinburns.com', NULL),
('anesthesiology', 'Mike', 'James', '1824 Washington av', 'Tampa', 'FL', '33784', '9108470981', 13197049121, 'mjames@gmail.com', 'mjames.com', NULL);

INSERT INTO dbo.treatment
(trt_name, trt_price, trt_notes)
VALUES
('heart transplant', 150000.00, NULL),
('kidney transplant', 180000.00, NULL),
('shoulder surgery', 18000.00, NULL),
('hip replacement', 40000.00, NULL),
('skin graft', 2200.00, NULL);

INSERT INTO dbo.patient_treatment
(pat_id, phy_id, trt_id, ptr_date, ptr_start, ptr_end, ptr_results, ptr_notes)
VALUES
(1,1,4,'2016-10-21','10:02:10','13:15:15', 'success patient will fully recover',NULL),
(2,3,1,'2016-07-29','07:08:12','17:30:38', 'patient ran into complications long recovery time',NULL),
(3,2,2,'2016-07-12','12:40:57','14:37:29', 'success patient will fully recover',NULL),
(4,5,4,'2016-02-07','08:01:41','12:29:52', 'will need follow up surgery',NULL),
(5,1,3,'2016-12-02','15:51:47','18:32:29', 'success patient will fully recover',NULL);

INSERT INTO dbo.administration_lu
(pre_id, ptr_id)
VALUES
(3,1),(4,2),(2,5),(1,4),(5,3);

EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CONSTRAINT ALL"


SELECT * FROM dbo.patient;
SELECT * FROM dbo.medication;
SELECT * FROM dbo.prescription;
SELECT * FROM dbo.physician;
SELECT * FROM dbo.treatment;
SELECT * FROM dbo.patient_treatment;
SELECT * FROM dbo.administration_lu;


--Starting transactions
use iww15;
GO

BEGIN TRANSACTION;
    select pat_fname, pat_lname, pat_notes, med_name, med_price, med_shelf_life, pre_dosage, pre_num_refills
    from medication m
    join prescription pr on pr.med_id=m.med_id
    join patient p on pr.pat_id=p.pat_id
    order by med_price desc;
commit;

use iww15;
GO

IF OBJECT_ID (N'dbo.v_physician_patient_treatments', N'V') IS NOT NULL
DROP VIEW dbo.v_physician_patient_treatments;
GO

create view dbo.v_physician_patient_treatments as
select phy_fname, phy_lname, trt_name, trt_price, ptr_results, ptr_date, ptr_start, ptr_end
from physician p, patient_treatment pt, treatment t
where p.phy_id=pt.phy_id
and pt.trt_id=t.trt_id;
GO

select * from dbo.v_physician_patient_treatments order by trt_price desc;
GO

use iww15;
GO

select * from dbo.v_physician_patient_treatments;

IF OBJECT_ID('AddRecord') IS NOT NULL
DROP PROCEDURE AddRecord;
GO

CREATE PROCEDURE AddRecord AS
insert into dbo.patient_treatment
(pat_id, phy_id, trt_id, ptr_date, ptr_start, ptr_end, ptr_results, ptr_notes)
values (5,5,5,'2013-04-23', '11:00:00','12:30:00', 'realeased', 'ok');

select * from dbo.v_physician_patient_treatments;
GO

EXEC AddRecord

DROP PROCEDURE AddRecord;

begin TRANSACTION;
    select * from dbo.administration_lu;
    delete from dbo.administration_lu where pre_id=5 and ptr_id=3;
    select * from dbo.administration_lu;
commit;

use iww15;
GO

IF OBJECT_ID('dbo.UpdatePatient') IS NOT NULL
DROP PROCEDURE dbo.UpdatePatient;
GO

CREATE PROCEDURE dbo.UpdatePatient AS

select * from dbo.patient;

update dbo.patient
set pat_lname='Vanderbilt'
where pat_id=3;

select * from dbo.patient;
GO

EXEC dbo.UpdatePatient;
GO

DROP PROCEDURE dbo.UpdatePatient;
GO

EXEC sp_help 'dbo.patient_treatment';
ALTER TABLE dbo.patient_treatment add ptr_prognosis VARCHAR(255) NULL DEFAULT 'testing';
EXEC sp_help 'dbo.patient_treatment';

use iww15;

IF OBJECT_ID('dbo.AddShowRecords') IS NOT NULL
DROP PROCEDURE dbo.AddShowRecords;
GO

CREATE PROCEDURE dbo.AddShowRecords AS

select * from dbo.patient;

insert into dbo.patient
(pat_ssn, pat_fname, pat_lname, pat_street, pat_city, pat_state, pat_zip, pat_phone, pat_email, pat_dob, pat_gender, pat_notes)
values (8211429128, 'John', 'Doe', '4211 Main st', 'Tallahassee', 'FL', '32301', 8509281414, 'jdoe@gmail.com', '1990-01-01', 'm', 'testing notes');

select * from dbo.patient;

select phy_fname, phy_lname, trt_name, ptr_start, ptr_end, ptr_date
from dbo.patient p
join dbo.patient_treatment pt on p.pat_id=pt.pat_id
join dbo.physician pn on pn.phy_id=pt.phy_id
join dbo.treatment t on t.trt_id=pt.trt_id
order by ptr_date desc;
GO

EXEC dbo.AddShowRecords;
GO

DROP PROCEDURE dbo.AddShowRecords;
