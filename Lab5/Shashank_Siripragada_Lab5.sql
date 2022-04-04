--- Lab 5-1 
/* Create a function in your own database that takes two 
   parameters: 
1) A year parameter  
2) A month parameter 
   The function then calculates and returns the total sale  
   for the requested year and month. If there was no sale 
   for the requested period, returns 0. 
 
   Hints: a) Use the TotalDue column of the  
             Sales.SalesOrderHeader table in an 
             AdventureWorks database for 
             calculating the total sale. 
          b) The year and month parameters should use  
             the INT data type. 
          c) Make sure the function returns 0 if there 
             was no sale in the database for the requested 
             period. */ 

USE shashank;

DROP FUNCTION dbo.totalsalesyearmonth;

CREATE FUNCTION dbo.totalsalesyearmonth
(@y INT, @m INT)
RETURNS FLOAT
AS
BEGIN
	DECLARE @totalsum FLOAT;
	IF EXISTS (SELECT TotalDue
		FROM AdventureWorks2008R2.sales.salesOrderHeader
		WHERE YEAR(OrderDate) = @y AND MONTH(OrderDate) = @m)
	SELECT @totalsum = sum(TotalDue)
		FROM AdventureWorks2008R2.sales.salesOrderHeader
		WHERE YEAR(OrderDate) = @y AND MONTH(OrderDate) = @m;
	ELSE
		BEGIN
			SET @totalsum = 0;
		END
	RETURN @totalsum;
END;

SELECT dbo.totalsalesyearmonth(2008,12); -- Trial run Lab 5-1


----- 5-2
/*
Create a table in your own database using the following statement.
CREATE TABLE DateRange
(DateID INT IDENTITY,
DateValue DATE,
Month INT,
DayOfWeek INT);
Write a stored procedure that accepts two parameters:
1) A starting date
2) The number of the consecutive dates beginning with the starting
date
The stored procedure then populates all columns of the
DateRange table according to the two provided parameters.
*/


DROP TABLE dbo.DateRange;
DROP PROCEDURE dbo.populatetable;


CREATE TABLE
	dbo.DateRange (DateID INT IDENTITY,
	DateValue DATE,
	Month INT,
	DayOfWeek INT);

CREATE PROCEDURE dbo.populatetable
	@d DATE,@n INT
AS
BEGIN
	WHILE @n <> 0
		BEGIN
			INSERT INTO dbo.DateRange (DateValue,Month,DayOfWeek)
			SELECT @d,MONTH(@d),DATEPART(dw,@d)
			SET @d = DATEADD(d,1,@d);
			SET @n = @n - 1;
		END
END
-- Trial run Lab 5-2
DECLARE @d DATE;
DECLARE @n INT;

SET @d = GETDATE();
SET @n = 7;

EXEC dbo.populatetable @d,@n;

SELECT * FROM dbo.DateRange;


------ 5-3

/* With three tables as defined below: */
CREATE TABLE Customer
(CustomerID VARCHAR(20) PRIMARY KEY,
CustomerLName VARCHAR(30),
CustomerFName VARCHAR(30),
CustomerStatus VARCHAR(10));

CREATE TABLE SaleOrder
(OrderID INT IDENTITY PRIMARY KEY,
CustomerID VARCHAR(20) REFERENCES Customer(CustomerID),
OrderDate DATE,
OrderAmountBeforeTax INT);

CREATE TABLE SaleOrderDetail
(OrderID INT REFERENCES SaleOrder(OrderID),
ProductID INT,
Quantity INT,
UnitPrice INT,
PRIMARY KEY (OrderID, ProductID));


/* Write a trigger to update the CustomerStatus column of Customer
 based on the total of OrderAmountBeforeTax for all orders
 placed by the customer. If the total exceeds 5,000, put Preferred
 in the CustomerStatus column. */

 
DROP TRIGGER dbo.UpdateCustomerStatus;

CREATE TRIGGER dbo.UpdateCustomerStatus 
ON dbo.SaleOrder 
FOR INSERT,UPDATE
AS
	BEGIN
		DECLARE @ThisCustomerID INT;
		DECLARE @TotalAmountBeforeTax FLOAT;
	SELECT @ThisCustomerID = CustomerID FROM inserted;
SET
@TotalAmountBeforeTax = ( Select Sum(OrderAmountBeforeTax) FROM dbo.SaleOrder WHERE CustomerID = @ThisCustomerID);

IF @TotalAmountBeforeTax >= 5000
BEGIN
UPDATE
	dbo.Customer
SET
	CustomerStatus = 'Preffered'
WHERE
	CustomerID = @ThisCustomerID;
END;
END;