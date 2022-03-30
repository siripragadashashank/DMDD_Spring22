 --create database "shashank";
 --go

use "shashank";


--Create table dbo.Customers
--(
--CustomerID varchar(5) not null primary key,
--Name varchar(40) not null
--);

--create table dbo.Orders
--(
--OrderID int IDENTITY not null primary key, 
--CustomerID varchar(5) not null
--	references dbo.Customers(CustomerID),
--OrderDate datetime DEFAULT Current_Timestamp
--);


--create table dbo.Products
--(
--ProductID int IDENTITY not null primary key,
--Name varchar(40) not null,
--UnitPrice money not null
--);

--create table dbo.OrderItems
--(
--OrderID int not null references dbo.Orders(OrderID),
--ProductID int NOT null REFERENCES dbo.Products(ProductID), 
--UnitPrice money NOT NULL, 
--Quantity int NOT null CONSTRAINT PKOrderItem PRIMARY KEY (OrderID, ProductID)
--);

INSERT dbo.Customers 
    VALUES ('ABC', 'Bob''s Pretty Good Garage'); 

INSERT dbo.Orders (CustomerID) 
VALUES ('ABC'); 

select * from dbo.OrderItems

INSERT dbo.Products 
    VALUES ('Widget', 5.55), 
           ('Thingamajig', 8.88) 

INSERT dbo.OrderItems 
    VALUES (1, 1, 5.55, 3); 



	-- Create a table without specifying constraints.  
CREATE TABLE TBL3 (pk3 int); 
 
 
-- Add the NOT NULL constraint 
 
ALTER TABLE tbl3 ALTER COLUMN pk3 int not null; 
 
 
-- Add the Primary Key constraint. 
 
ALTER TABLE tbl3 ADD CONSTRAINT key3 PRIMARY KEY (pk3); 
 
-- Add the Foreign Key constraint. 
 
-- Create the parent table first.  
 
CREATE TABLE TBL1 (pk1 int PRIMARY KEY); 
 
 
ALTER TABLE tbl3 ADD CONSTRAINT R3 FOREIGN KEY (pk3)  
      REFERENCES tbl1(pk1) 

	  select * from tbl1;
 
-- Must DROP the child table before dropping the parent table.  
DROP TABLE TBL3; 
DROP TABLE TBL1;


DECLARE @counter INT 
SET @counter = 0  
WHILE @counter <> 5 
   BEGIN  
      SET @counter = @counter + 1  
      PRINT 'The counter : ' + CAST(@counter AS CHAR)  
   END 