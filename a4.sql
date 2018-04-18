use master;
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabase WHERE name = N'iww15')
DROP DATABASE iww15;
GO

IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'iww15')
CREATE DATABASE iww15;
GO

use iww15;
GO

IF OBJECT_ID (N'dbo.slsrep',N'U') IS NOT NULL
DROP TABLE dbo.petstore;
GO

CREATE TABLE dbo.petstore
(
pst_id SMALLINT not null identity(1,1),
pst_name VARCHAR(15) NOT NULL,
pst_street VARCHAR(30) NOT NULL,
pst_city VARCHAR(30) NOT NULL,
pst_state CHAR(2) NOT NULL default'AZ',
pst_zip INT NOT NULL check(pst_zip > 0 and pst_zip <= 999999999),
pst_phone BIGINT NOT NULL,
pst_email VARCHAR(100) NOT NULL,
pst_url VARCHAR(100) NOT NULL,
pst_ytd_sales DECIMAL(10,2) NOT NULL check(pst_ytd_sales > 0),
pst_notes VARCHAR(255) NULL,
primary key(pst_id)
);

SELECT * FROM information_schema.tables;

insert into dbo.petstore
(pst_name,pst_street,pst_city,pst_state,pst_zip,pst_phone,pst_email,pst_url,pst_ytd_sales,pst_notes)
values
('Petsmart','408 W College','Tallahassee','FL',99999,8051234567,'petsmart@gmail.com','petsmart.com',8500.00,'First entry');
('Petco','123 Sandy Ridge','New York','NY',99999,8140172407,'petco@gmail.com','petco.com',1000.00,'Second entry');
('Velmas Pets','231 Tarpon Woods','Clearwater','FL',99999,9812489717,'velmas@gmail.com','velmaspets.com',850.00,'Third entry');
('Walmart','456 Countryside','Tallahassee','FL',99999,7912479123,'walmart@gmail.com','walmart.com',1200.00,'Fourth entry');
('Pets R Us','984 Farrier Trail','Austin','TX',99999,4961249824,'petsrus@gmail.com','petsrus.com',7000.00,'Fifth entry');

SELECT * FROM dbo.petstore;

IF OBJECT_ID (N'dbo.pet', N'U') IS NOT NULL
DROP TABLE dbo.pet;
GO

CREATE TABLE dbo.pet
(
pet_id SMALLINT not null identity(1,1),
pst_id SMALLINT NULL,
pet_type VARCHAR(45) NOT NULL,
pet_sex CHAR(1) NOT NULL CHECK(pet_sex IN('m','f')),
pet_cost DECIMAL(6,2) NOT NULL check(pet_cost >0),
pet_price DECIMAL(6,2) NOT NULL check(pet_price > 0),
pet_age SMALLINT NOT NULL check(pet_age > 0 and pet_age <= 10500),
pet_color VARCHAR(30) NOT NULL,
pet_sale_date DATE NOT NULL,
pet_vaccine CHAR(1) NOT NULL CHECK(pet_vaccine IN('y','n')),
pet_neuter CHAR(1) NOT NULL CHECK(pet_neuter IN('y','n')),
pet_notes VARCHAR(255) NULL,
PRIMARY KEY (pet_id),
CONSTRAINT fk_pet_petstore
	FOREIGN KEY (pst_id)
	REFERENCES dbo.petstore (pst_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

SELECT * FROM information_schema.tables;

insert into dbo.petstore
(pet_type,pet_sex,pet_cost,pet_price,pet_age,pet_color,pet_sales_date,pet_vaccine,pet_neuter,pet_notes)
values
('Dog','m',120.00,175.00,3,'brown', 2001-01-01,'y','y','First entry');
('Dog','f',100.00,150.00,2,'yellow', 2002-04-01,'y','n','Second entry');
('Cat','m',60.00,80.00,1,'brown', 2001-03-03,'y','y','Third entry');
('Cat','f',50.00,75.00,8,'grey', 2001-04-02,'y','n','Fourth entry');
('Lizard','m',120.00,175.00,3,'brown', 2001-01-01,'n','n','Fifth entry');

EXEC sp_help 'dbo.pet';
