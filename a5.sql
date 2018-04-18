SET ANSI_WARNINGS ON;
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name=N'iww15')
DROP DATABASE iww15;
GO

IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name=N'iww15')
CREATE DATABASE iww15;
GO

use iww15;
GO

IF OBJECT_ID(N'dbo.applicant',N'U') IS NOT NULL
DROP TABLE dbo.applicant;
GO

CREATE TABLE dbo.applicant
(
app_id SMALLINT not null IDENTITY(1,1),
app_ssn INT not null check(app_ssn > 0 and app_ssn <=999999999),
app_state_id VARCHAR(45) not null,
app_fname VARCHAR(15) not null,
app_lname VARCHAR(30) not null,
app_street VARCHAR(30) not null,
app_city VARCHAR(30) not null,
app_state CHAR(2) not null DEFAULT'FL',
app_zip INT not null CHECK(app_zip > 0 and app_zip <= 999999999),
app_email VARCHAR(100) null,
app_dob DATE not null,
app_gender CHAR(1) not null CHECK(app_gender IN('m','f')),
app_bckgd_check CHAR(1) not null CHECK(app_bckgd_check IN('n','y')),
app_notes VARCHAR(45) null,
PRIMARY KEY (app_id),

CONSTRAINT ux_app_ssn unique nonclustered (app_ssn ASC),
CONSTRAINT ux_app_state_id unique nonclustered(app_state_id ASC)
);

IF OBJECT_ID(N'dbo.property',N'U') IS NOT NULL
DROP TABLE dbo.property;

CREATE TABLE dbo.property
(
prp_id SMALLINT not null IDENTITY(1,1),
prp_street VARCHAR(30) not null,
prp_city VARCHAR(30) not null,
prp_state CHAR(2) not null DEFAULT'FL',
prp_zip INT not null CHECK(prp_zip > 0 and prp_zip <= 999999999),
prp_type VARCHAR(15) not null CHECK(prp_type IN('house','condo','townhouse','duplex','apt','mobile home','room')),
prp_rental_rate DECIMAL(7,2) not null CHECK(prp_rental_rate > 0),
prp_status CHAR(1) not null CHECK(prp_status IN('a','u')),
prp_notes VARCHAR(255) null,
PRIMARY KEY (prp_id)
);

IF OBJECT_ID (N'dbo.aggreement', N'U') IS NOT NULL 
DROP TABLE dbo.agreement;

CREATE TABLE dbo.agreement
(
agr_id SMALLINT not null IDENTITY(1,1),
prp_id SMALLINT not null,
app_id SMALLINT not null,
agr_signed DATE not null,
agr_start DATE not null,
agr_end DATE not null,
agr_amt DECIMAL(7,2) not null CHECK(agr_amt > 0),
agr_notes VARCHAR(255) null,
PRIMARY KEY(agr_id),

CONSTRAINT ux_prp_id_app_id_agr_signed UNIQUE nonclustered
(prp_id ASC, app_id ASC, agr_signed ASC),

CONSTRAINT fk_agreement_property
	FOREIGN KEY(prp_id)
	REFERENCES dbo.property(prp_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,

CONSTRAINT fk_agreement_applicant
	FOREIGN KEY(app_id)
	REFERENCES dbo.applicant(app_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

IF OBJECT_ID (N'dbo.feature',N'U') IS NOT NULL
DROP TABLE dbo.feature;

CREATE TABLE dbo.feature
(
ftr_id TINYINT not null IDENTITY(1,1),
ftr_type VARCHAR(45) not null,
ftr_notes VARCHAR(255) null,
PRIMARY KEY(ftr_id)
);

IF OBJECT_ID(N'dbo.prop_feature',N'U') IS NOT NULL
DROP TABLE dbo.prop_feature;

CREATE TABLE dbo.prop_feature
(
pft_id SMALLINT not null IDENTITY(1,1),
prp_id SMALLINT not null,
ftr_id TINYINT not null,
pft_notes VARCHAR(255) null,
PRIMARY KEY(pft_id),

CONSTRAINT ux_prp_id_ftr_id UNIQUE nonclustered(prp_id ASC, ftr_id ASC),

CONSTRAINT fk_prop_feat_property
	FOREIGN KEY (prp_id)
	REFERENCES dbo.property (prp_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,

CONSTRAINT fk_prop_feat_feature
	FOREIGN KEY(ftr_id)
	REFERENCES dbo.feature(ftr_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

IF OBJECT_ID (N'dbo.occupant',N'U') IS NOT NULL
    DROP TABLE dbo.occupant;

CREATE TABLE dbo.occupant
(
ocp_id SMALLINT not null IDENTITY(1,1),
app_id SMALLINT not null,
ocp_ssn INT not null CHECK(ocp_ssn > 0 and ocp_ssn <= 999999999),
ocp_state_id VARCHAR(45) null,
ocp_fname VARCHAR(15) not null,
ocp_lname VARCHAR(30) not null,
ocp_email VARCHAR(100) null,
ocp_dob DATE not null,
ocp_gender CHAR(1) not null CHECK(ocp_gender IN('m','f')),
ocp_bckgd_check CHAR(1) not null CHECK(ocp_bckgd_check IN('n','y')),
ocp_notes VARCHAR(45) null,
PRIMARY KEY (ocp_id),

CONSTRAINT ux_ocp_ssn UNIQUE nonclustered (ocp_ssn ASC),
CONSTRAINT ux_ocp_state_id UNIQUE nonclustered (ocp_state_id ASC),

CONSTRAINT fk_occupant_applicant
    FOREIGN KEY (app_id)
    REFERENCES dbo.applicant(app_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

IF OBJECT_ID(N'dbo.phone',N'U') IS NOT NULL
    DROP TABLE dbo.phone;

CREATE TABLE dbo.phone
(
phn_id SMALLINT not null IDENTITY(1,1),
app_id SMALLINT not null,
ocp_id SMALLINT null,
phn_num BIGINT not null CHECK(phn_num > 0 and phn_num <= 9999999999),
phn_type CHAR(1) not null CHECK(phn_type IN('c','h','w','f')),
phn_notes VARCHAR(45) null,
PRIMARY KEY (phn_id),

CONSTRAINT ux_app_id_phn_num UNIQUE nonclustered (ocp_id ASC, phn_num ASC),

CONSTRAINT fk_phone_applicant
    FOREIGN KEY (app_id)
    REFERENCES dbo.applicant (app_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

IF OBJECT_ID (N'dbo.room_type',N'U') IS NOT NULL
    DROP TABLE dbo.room_type;

CREATE TABLE dbo.room_type
(
rtp_id TINYINT not null IDENTITY(1,1),
rtp_name VARCHAR(45) not null,
rtp_notes VARCHAR(45) null,
PRIMARY KEY (rtp_id)
);

IF OBJECT_ID (N'dbo.room',N'U') IS NOT NULL
    DROP TABLE dbo.room;

CREATE TABLE dbo.room
(
rom_id SMALLINT not null IDENTITY(1,1),
prp_id SMALLINT not null,
rtp_id TINYINT not null,
rom_size VARCHAR(45) not null,
rom_notes VARCHAR(255) null,
PRIMARY KEY (rom_id),

CONSTRAINT fk_room_property
    FOREIGN KEY (prp_id)
    REFERENCES dbo.property (prp_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

CONSTRAINT fk_room_roomtype
    FOREIGN KEY (rtp_id)
    REFERENCES dbo.room_type (rtp_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

SELECT * FROM information_schema.tables

EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

INSERT INTO dbo.feature
(ftr_type, ftr_notes)

VALUES
('Central A/C', null),
('Pool', null),
('Close to school', null),
('Furnished', null),
('Cable', null),
('Washer/dryer', null),
('Refrigerator', null),
('Microwave', null),
('Oven', null),
('1-car garage', null),
('2-car garage', null),
('Sprinkler system', null),
('Security', null),
('Wi-fi', null),
('Storage', null),
('Fireplace', null);

INSERT INTO dbo.room_type
(rtp_name, rtp_notes)

VALUES
('Bed', null),
('Bath', null),
('Living', null),
('Kitchen', null),
('Lanai', null),
('Dining', null),
('Basement', null),
('Office', null);

INSERT INTO dbo.prop_feature
(prp_id, ftr_id, pft_notes)

VALUES
(1,4,null),
(2,5,null),
(3,3,null),
(4,2,null),
(5,1,null),
(1,1,null),
(1,5,null);

INSERT INTO dbo.room
(prp_id, rtp_id, rom_size, rom_notes)

VALUES
(1,1, '10" x 10"', null),
(3,2, '20" x 15"', null),
(4,3, '10" x 12"', null),
(5,4, '45" x 50"', null),
(2,3, '30" x 30"', null);

INSERT INTO dbo.property
(prp_street, prp_city, prp_state, prp_zip, prp_type, prp_rental_rate, prp_status, prp_notes)

VALUES
('5133 Bradford rd', 'Tallahassee', 'FL', '32301', 'house', 1500.00, 'u', null),
('408 W College ave', 'Tallahassee', 'FL', '32301', 'apt', 750.00, 'u', null),
('3219 Sandy Ridge Dr', 'Clearwater', 'FL', '33761', 'house', 2000.00, 'u', null),
('4123 Farrier Trail', 'Clearwater', 'FL', '33755', 'townhouse', 1300.00, 'a', null),
('3372 Countryside Blvd', 'Clearwater', 'FL', '33761', 'townhouse', 1500.00, 'a', null);

INSERT INTO dbo.applicant
(app_ssn, app_state_id, app_fname, app_lname, app_street, app_city, app_state, app_zip, app_email, app_dob, app_gender,app_bckgd_check, app_notes)

VALUES
('123456789', 'Q83U18YY142H', 'Barry', 'Jones', '5133 Bradford rd', 'Tallahassee', 'FL', 32301, 'bjones@gmail.com','1984-12-20', 'm', 'y', null),
('987654321', 'A8941UW0ASC9', 'Elizabeth', 'Williams', '5408 W College ave', 'Tallahassee', 'FL', '32301', 'ewilliams@gmail.com','1990-04-12', 'f', 'y', null),
('123549876', '9Q89C9A8WD12', 'Jessica', 'Jones', '3219 Sandy Ridge Dr', 'Clearwater', 'FL', '33761', 'jjones@gmail.com','1996-01-12', 'f', 'n', null),
('321549876', '81N29C97CAS3', 'Zohan', 'Miller', '4123 Farrier Trail', 'Clearwater', 'FL', '33755', 'zohanmill@gmail.com','1972-04-15', 'm', 'n', null),
('741289911', '82U124H12BS7', 'Timothy', 'Bradly', '3372 Countryside Blvd', 'Clearwater', 'FL', '33761', 'timbr@gmail.com','1988-06-02', 'm', 'y', null);

INSERT INTO dbo.agreement
(prp_id, app_id, agr_signed, agr_start, agr_end, agr_amt, agr_notes)

VALUES
(3,4, '2013-12-01', '2014-01-01', '2014-12-31', 1000.00, null),
(1,1, '2001-01-01', '2002-01-01', '2015-12-31', 780.00, null),
(4,2, '1999-12-01', '2000-01-01', '2017-12-31', 820.00, null),
(5,3, '2012-12-01', '2013-01-01', '2014-12-31', 1200.00, null),
(2,5, '2007-01-01', '2003-01-01', '2005-12-31', 980.00, null);

INSERT INTO dbo.occupant
(app_id, ocp_ssn, ocp_state_id, ocp_fname, ocp_lname, ocp_email, ocp_dob, ocp_gender, ocp_bckgd_check, ocp_notes)

VALUES
(1, '312645978', 'Q23E45T67U89', 'Ryan', 'Thompson', 'rthompson@gmail.com', '1989-02-22', 'm', 'y', null),
(1, '432116877', 'U12498QA9412', 'Casey', 'Thorton', 'cthorton@gmail.com', '1991-04-03', 'f', 'n', null),
(2, '912498121', '9712EQ7182T1', 'Tyler', 'Johnson', 'tj@gmail.com', '1972-01-18', 'm', 'y', null),
(2, '194819289', '912Q9124Y9RH', 'Chelsea', 'Rodriguez', 'chelsear@gmail.com', '1977-11-11', 'f', 'n', null),
(5, '124152232', '981725B12A11', 'Richard', 'Bentley', 'rbentley@gmail.com', '1989-01-04', 'm', 'y', null);

INSERT INTO dbo.phone
(app_id, ocp_id, phn_num, phn_type, phn_notes)

VALUES
(1, null, '1234567891', 'h', null),
(1, null, '7198249124', 'c', null),
(1, 5, '0871491247', 'f', null),
(1, 1, '9817249121', 'h', null),
(1, null, '1908724911', 'c', null);

EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"

select * from dbo.feature;
select * from dbo.prop_feature;
select * from dbo.room_type;
select * from dbo.room;
select * from dbo.property;
select * from dbo.applicant;
select * from dbo.agreement;
select * from dbo.occupant;
select * from dbo.phone;

--***REPORT***

--join on
select p.prp_id, prp_type, prp_rental_rate, rtp_name, rom_size
from property p 
JOIN room r on p.prp_id=r.prp_id
JOIN room_type rt on r.rtp_id=rt.rtp_id
where p.prp_id=3;

--old style join
select p.prp_id, prp_type, prp_rental_rate,rtp_name, rom_size
from property p, room r, room_type rt
where p.prp_id=r.prp_id
and r.rtp_id=rt.rtp_id
and p.prp_id=3;

--join on
select p.prp_id, prp_type, prp_rental_rate, ftr_type
from property p
JOIN prop_feature pf on p.prp_id=pf.prp_id
JOIN feature f on pf.ftr_id=f.ftr_id
where p.prp_id > 4 and p.prp_id<6;

--old style join
select p.prp_id, prp_type, prp_rental_rate, ftr_type
from property p, prop_feature pf, feature f
where p.prp_id=pf.prp_id
and pf.ftr_id=f.ftr_id
and p.prp_id > 4 and p.prp_id < 6;

--old style join
select app_ssn, app_state_id, app_fname, app_lname, phn_num, phn_type
from applicant a, phone p
where a.app_id=p.app_id

--join on
select app_ssn, app_state_id, app_fname, app_lname, phn_num, phn_type
from applicant a
JOIN phone p on a.app_id=p.app_id;

--left outer join
select ocp_ssn, ocp_state_id, ocp_fname, ocp_lname, phn_num, phn_type
from phone p
LEFT OUTER JOIN occupant o ON o.ocp_id=p.ocp_id;

--right outer join
select ocp_ssn, ocp_state_id, ocp_fname, ocp_lname, phn_num, phn_type
from occupant o
RIGHT OUTER JOIN phone p ON o.ocp_id=p.ocp_id;

