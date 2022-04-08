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

use shashank;

drop function dbo.TotalSales;

create function dbo.TotalSales (@year int, @month int) returns float as
begin
	declare @totalsum float;
	if exists
	(
		select soh.TotalDue from AdventureWorks2008R2.Sales.SalesOrderHeader soh
		where year(soh.OrderDate) = @year and 
			  month(soh.OrderDate) = @month
	)
	select @totalsum = sum(soh.TotalDue) from AdventureWorks2008R2.Sales.SalesOrderHeader soh
	where year(soh.OrderDate) = @year and 
	      month(soh.OrderDate) = @month
	else
		begin
			set @totalsum = 0;
		end
	return @totalsum;
end;

SELECT dbo.TotalSales(2005,12) as TotalSalesYearMonth;


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

use shashank;

drop table dbo.DateRange;
drop procedure dbo.sp_DateRange;

CREATE TABLE dbo.DateRange 
(
DateID INT IDENTITY,
DateValue DATE,
Month INT,
DayOfWeek INT
);

create procedure dbo.sp_DateRange @startdate DATE, @ndays INT as
begin
	while @ndays <> 0
	begin
		insert into dbo.DateRange (DateValue, Month, DayOfWeek)
		select @startdate
			 , month(@startdate)
			 , datepart(dw, @startdate)
		set @startdate = DATEADD(d, 1, @startdate);
		set @ndays = @ndays - 1;
	end
end

declare @ndays int;
declare @startdate date;
set @ndays = 7;
set @startdate = GETDATE();
exec dbo.sp_DateRange @startdate, @ndays;

select * from dbo.DateRange;


------ 5-3

/* With three tables as defined below: */


use shashank;

drop table SaleOrderDetail;
drop table SaleOrder;
drop table Customer;

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

 
drop trigger dbo.trig_CustomerStatus_update;

create trigger dbo.trig_CustomerStatus_update on dbo.SaleOrder for insert, update as
begin
	declare @CID int
	declare @TotalOrderAmountBeforeTax float
	select @CID = CustomerID from inserted;

	set @TotalOrderAmountBeforeTax = (select sum(OrderAmountBeforeTax) from SaleOrder where CustomerID = @CID);
	if @TotalOrderAmountBeforeTax >= 5000
	begin
		update Customer
		set CustomerStatus = 'Preferred' where CustomerID = @CID;
	end;
end;

--test for 5-3

insert into Customer values ('1', 'Luke', 'Skywalker', 'Not A Sith');

insert into SaleOrder values ('1', getdate(), 3000);

select * from Customer;

insert into SaleOrder values ('1', getdate(), 3000);

select * from Customer;