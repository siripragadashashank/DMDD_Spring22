use AdventureWorks2008R2;


-------------


select ProductID
,  Name
, case 
when ListPrice - (select avg(listprice) from Production.Product) = 0 then 'AvgPrice'
when ListPrice - (select avg(listprice) from Production.Product) > 0 then 'AboveAvgPrice'
else 'BelowAvgPrice'
end as Remark
from Production.Product;

------------

-- Lab 3-1 

/* Modify the following query to add a column that identifies the performance of salespersons and contains the following feedback based on the number of orders processed by a salesperson:
'Do more!' for the order count range 1-120 'Fine!' for the order count range of 121-320 'Excellent!' for the order count greater than 320
Give the new column an alias to make the report more readable. */
SELECT SalesPersonID, p.LastName, p.FirstName, COUNT(o.SalesOrderid) [Total Orders]
, case
when COUNT(o.SalesOrderid) >=1 and COUNT(o.SalesOrderid) <=120 then 'Do More!'
when COUNT(o.SalesOrderid) >=121 and COUNT(o.SalesOrderid) <=320 then 'Fine!'
else 'Excellent!' end as Feedback
FROM Sales.SalesOrderHeader o JOIN Person.Person p ON o.SalesPersonID = p.BusinessEntityID 
GROUP BY o.SalesPersonID, p.LastName, p.FirstName ORDER BY p.LastName, p.FirstName;


SELECT
RANK() OVER (ORDER BY OrderQty DESC) AS [Rank],
SalesOrderID, ProductID, UnitPrice, OrderQty
FROM Sales.SalesOrderDetail
WHERE UnitPrice >75;


SELECT
RANK() OVER (PARTITION BY ProductID ORDER BY OrderQty DESC) AS [Rank],
SalesOrderID, ProductID, UnitPrice, OrderQty
FROM Sales.SalesOrderDetail
WHERE UnitPrice >75;

SELECT
Dense_RANK() OVER (PARTITION BY ProductID ORDER BY OrderQty DESC) AS [Rank],
SalesOrderID, ProductID, UnitPrice, OrderQty
FROM Sales.SalesOrderDetail
WHERE UnitPrice >75;

-----------------

--Lab 3-2 
/* Modify the following query to add a new column named rank. 
--The new column is based on ranking with gaps according to the total orders in descending. 
-- Also partition by the territory. 
*/
SELECT o.TerritoryID, s.Name, o.SalesPersonID, COUNT(o.SalesOrderid) [Total Orders]
, rank() over(partition by o.TerritoryID order by COUNT(o.SalesOrderid) desc) as Rank

FROM Sales.SalesOrderHeader o JOIN Sales.SalesTerritory s ON o.TerritoryID = s.TerritoryID 
WHERE SalesPersonID IS NOT NULL 
GROUP BY o.TerritoryID, s.Name, o.SalesPersonID 
ORDER BY o.TerritoryID;

-------------------


--Lab 3-3 
/* Write a query to retrieve the most popular product of each city. 
The most popular product has the highest total sold quantity in a city. 
Use OrderQty in SalesOrderDetail for calculating the total sold quantity. 
Use ShipToAddressID in SalesOrderHeader to determine what city a product is related to. 
If there is a tie, your solution must retrieve it.
Return only the products which have a total sold quantity of more than 100 in a city. 
Include City, ProductID, and total sold quantity of the most popular product in the city for the returned data. 
Sort the returned data by City. */

select * from (
Select City, ProductID, sum(OrderQty) [Total Sold Quantity]  
, Rank() over(partition by City order by sum(OrderQty) desc) as rank
from Sales.SalesOrderDetail sod
join Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID
join Person.Address ad on soh.ShipToAddressID = ad.AddressID
group by ad.City, ProductID
having sum(OrderQty)>100
)a where rank=1


----------------

-- Lab 3-4 
/* Retrieve the top selling product of each day. Use the total sold quantity to determine the top selling product. The top selling product has the highest total sold quantity. If there is a tie, the solution must pick up the tie.
Include the order date, product id, and the total sold quantity of the top selling product of each day in the returned data. Sort the returned data by the order date. */
select * from (
Select OrderDate
, sod.ProductID
, sum(OrderQty) as [Total Sold Quantity] 
, rank() over(partition by OrderDate order by sum(OrderQty) desc) [rank]
from Sales.SalesOrderDetail sod
join Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID
group by OrderDate, sod.ProductID
)a where a.rank=1
order by orderdate
---------------


--Lab 3-5 
/* Write a query to retrieve the customers who have purchased more than ten different products and never purchased the same product for all of their orders.
For example, if Customer A has purchased more than 10 distinct products and never purchased a product more than once for all of his orders, then Customer A should be returned.
Sort the returned data by the total number of different products purchased by a customer in the descending order. Include only the customer id in the report. */

select CustomerID from Sales.SalesOrderDetail sod
join Sales.SalesOrderHeader soh on sod.SalesOrderID = Soh.SalesOrderID
group by CustomerID
having count(distinct ProductID) = count(ProductID) and count(distinct ProductID) >10
order by count(distinct OrderQty) desc


--------------------------------------


--- lab 4

---------B-1

/* Using the content of AdventureWorks, write a query to retrieve
all unique customers with all salespeople they have dealt with.
If a customer has never worked with a salesperson, make the
'Salesperson ID' column blank instead of displaying NULL.
Sort the returned data by CustomerID in the descending order.
The result should have the following format.
Hint: Use the SalesOrderHeadrer table.
CustomerID SalesPerson ID
30118 275, 277
30117 275, 277
30116 276
30115 289
30114 290
30113 282
30112 280, 284
*/

use AdventureWorks2008R2;


Select distinct CustomerId,
stuff((select distinct ', ' + cast(SalesPersonID as varchar)
from Sales.SalesOrderHeader s
where s.CustomerID = t.CustomerID
for XML path('')), 1, 2, '') as SalesPersons
from Sales.SalesOrderHeader t
order by CustomerID desc

--------------------- 3-2


/* Using the content of AdventureWorks, write a query to retrieve the top five products for each year. Use OrderQty of SalesOrderDetail to calculate the total quantity sold.
The top five products have the five highest sold quantities. Also calculate the top five products' sold quantity for a year as a percentage of the total quantity sold for the year.
Return the data in the following format.
Year % of Total Sale Top5Products
2005 19.58980418600 709, 712, 715, 770, 760
2006 13.70859187700 863, 715, 712, 711, 852
2007 12.39464630800 712, 870, 711, 708, 715
2008 15.68128704000 870, 712, 711, 708, 707
*/

with temp1 as(
Select year(OrderDate) as Year, sum(OrderQty) as total from Sales.SalesOrderDetail sod
left join Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID
group by year(OrderDate)),
temp2 as (
Select year(OrderDate) as Year, sod.ProductID, sum(OrderQty) as totalprod 
, rank() over(partition by year(OrderDate) order by sum(OrderQty) desc) as topprods
from Sales.SalesOrderDetail sod
left join Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID
group by year(OrderDate), sod.ProductID
)
select t2.year
--, sum(t2.totalprod)/t1.total * 100 
, cast(sum(t2.totalprod) as decimal) / t1.total * 100 [% of Total Sale]
,stuff((select ', ' + cast(ProductID as varchar) 
from temp2
where t2.year = year and topprods<=5
for xml path('')), 1, 2, '') as top5
from temp2 t2
join temp1 t1 on t1.year=t2.year and t2.topprods<=5
--group by t2.year, t1.total


---------------------------------------------------


-- Question 3 (3 points)

/* Write a query to retrieve the top 3 customers, based on the total purchase,
   for each region. The top 3 customers have the 3 highest total purchase amounts.
   Use TotalDue of SalesOrderHeader to calculate the total purchase.
   Also calculate the top 3 customers' total purchase amount.
   Return the data in the following format.
territoryid	Total Sale	Top5Customers
	1		2639574		29818, 29617, 29580
	2		1899953		29701, 29966, 29844
	3		2203384		29827, 29913, 29924
	4		2521259		30117, 29646, 29716
	5		1950980		29715, 29507, 29624
	6		2742459		29722, 29614, 29639
	7		1873658		30103, 29712, 29923
	8		938793		29995, 29693, 29917
	9		583812		29488, 29706, 30059
	10		1565145		30050, 29546, 29587
*/


with temp as(
select TerritoryID, CustomerID, sum(TotalDue) total2
, rank() over(partition by TerritoryID order by sum(TotalDue) desc) rank
from Sales.SalesOrderHeader soh
group by TerritoryID, CustomerID)

select t2.TerritoryID
, cast(sum(t2.total2) as int) as [Total Sale]
, stuff(
		(select ', ' + cast(t1.CustomerId as varchar)
		from temp t1
		where 
		t1.TerritoryID = t2.TerritoryID and
		t1.rank<=3 
		for xml path('')), 1, 2, '') as Top3
from temp t2
where t2.rank<=3
group by TerritoryID
order by TerritoryID



-- Exercise Question 1
/*
Using an AdventureWorks database, write a query to
retrieve the top 3 products for the customer id's between 30000 and 30005.
The top 3 products have the 3 highest total sold quantities.
The quantity sold for a product included in an order is in SalesOrderDetail.
Use the quantity sold to calculate the total sold quantity. If there is
a tie, your solution must retrieve the tie.
Return the data in the following format.
CustomerID Top3Products
30000 869, 809, 779
30001 813, 794
30002 998, 736, 875, 835, 836
30003 863, 771, 783
30004 709, 778, 776, 777
30005 966, 972, 954, 948, 965
*/

with temp as (
Select CustomerID, ProductID, sum(OrderQty) as total 
, rank() over(partition by CustomerID order by sum(OrderQty) desc) as rank
from Sales.SalesOrderDetail sod join Sales.SalesOrderHeader soh 
on sod.SalesOrderID = soh.SalesOrderID
where CustomerID  between 30000 and 30005
group by CustomerID, ProductID
)
select CustomerID, 
stuff((select ', '+cast(ProductID as varchar)
from temp t1
where t1.CustomerID = t2.CustomerID
and rank<=3 
for xml path('')), 1, 2, '') as top3
from temp t2
--group by CustomerID


-----------------


-- Exercise Question 2
/*
Using an AdventureWorks database, write a query to
retrieve the top 3 orders for each salesperson.
The top 3 orders have the 3 highest TotalDue values. TotalDue 
is in SalesOrderHeader. If there is a tie, your solution 
must retrieve the tie.
Return the data in the following format. The name is 
a salesperson's name.
SalesPersonID FullName Top3Orders
274 Jiang, Stephen 51830, 57136, 53465
275 Blythe, Michael 47395, 53621, 50289
276 Mitchell, Linda 47355, 51822, 57186
277 Carson, Jillian 46660, 43884, 44528
278 Vargas, Garrett 44534, 43890, 58932
279 Reiter, Tsvi 44518, 43875, 47455
280 Ansman-Wolfe, Pamela 47033, 67297, 53518
281 Ito, Shu 51131, 55282, 47369
282 Saraiva, Jos 53573, 47451, 51823
283 Campbell, David 46643, 51711, 51123
284 Mensa-Annan, Tete 69508, 50297, 48057
285 Abbas, Syed 53485, 53502, 58915
286 Tsoflias, Lynn 53566, 51814, 71805
287 Alberts, Amy 59064, 58908, 51837
288 Valdez, Rachel 55254, 51761, 69454
289 Pak, Jae 46616, 46607, 46645
290 Varkey Chudukatil, Ranjit 46981, 51858, 57150
*/


with temp as(
select SalesPersonID, SAlesorderID, totaldue , (LastName+ ', ' + FirstName) FullName
, rank() over(partition by SalesPersonID order by totaldue desc) as rank
from Sales.SalesOrderHeader soh
join Person.Person pb on Soh.SalesPersonID=pb.BusinessEntityID
)
select t2.SalesPersonID, FullName
, stuff((select ', '+ cast(SalesOrderID as varchar)
from temp t1
where t1.SalesPersonID=t2.SalesPersonID
and rank<=3
for xml path('')), 1, 2, '') as top3
from temp t2
group by SAlesPersonID, Fullname


---------------------
SELECT TerritoryID, [280], [281], [282], [283], [284], [285]
FROM 
(SELECT TerritoryID, SalesPersonID, SalesOrderID
FROM Sales.SalesOrderHeader) SourceTable
PIVOT
(
COUNT (SalesOrderID)
FOR SalesPersonID IN
( [280], [281], [282], [283], [284], [285] )
) AS PivotTable;

-- Question 2
/* Rewrite the following query to present the same data in a horizontal format,
   as listed below, using the SQL PIVOT command. */
SELECT DATENAME(mm, OrderDate) AS [Month], CustomerID,
       SUM(TotalDue) AS TotalOrder
FROM   Sales.SalesOrderHeader
WHERE CustomerID BETWEEN 30020 AND 30024
GROUP BY CustomerID, DATENAME(mm, OrderDate), MONTH(OrderDate)
ORDER BY MONTH(OrderDate);


select [Month],
isnull(cast([30020] as int), 0) [30020],
isnull(cast([30021] as int), 0) [30021],
isnull(cast([30022] as int), 0) [30022],
isnull(cast([30023] as int), 0) [30023],
isnull(cast([30024] as int), 0) [30024]
from (
SELECT DATENAME(mm, OrderDate) AS [Month], CustomerID,
       SUM(TotalDue) AS TotalOrder
FROM   Sales.SalesOrderHeader
WHERE CustomerID BETWEEN 30020 AND 30024
GROUP BY CustomerID, DATENAME(mm, OrderDate), MONTH(OrderDate)
)t
pivot
(
sum(totalorder)
for CustomerID in 
([30020], [30021], [30022], [30023], [30024])
) as pivottable
order by month([Month] + ' 1 2014')


----------------------



/* Rewrite the following query to present the same data in a horizontal format,
   as listed below, using the SQL PIVOT command. */

SELECT TerritoryID, CAST(OrderDate AS DATE) [Order Date], CAST(SUM(TotalDue) AS int) AS [Customer Count]
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '3-1-2008' AND '3-5-2008'
GROUP BY TerritoryID, OrderDate
ORDER BY TerritoryID, OrderDate;

/*
TerritoryID	2008-3-1	2008-3-2	2008-3-3	2008-3-4	2008-3-5
1			497609		5629		3582		5561		6511
2			219197		0			0			0			0
3			288595		0			0			0			0
4			524907		9878		9755		9308		16161
5			221203		0			0			0			0
6			526176		1361		5687		276			2437
7			104392		3609		3725		978			221
8			158651		49			7910		6152		11118
9			250353		14311		6754		13634		18050
10			368209		9960		2644		3894		8972
*/

select TerritoryID,
isnull(cast([2008-3-1] as int), 0) [2008-3-1],
isnull(cast([2008-3-2] as int), 0) [2008-3-2],
isnull(cast([2008-3-3] as int), 0) [2008-3-3],
isnull(cast([2008-3-4] as int), 0) [2008-3-4],
isnull(cast([2008-3-5] as int), 0) [2008-3-5]
from (
SELECT TerritoryID,OrderDate, TotalDue
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '3-1-2008' AND '3-5-2008'

)t
pivot
(SUM(TotalDue)
for OrderDate in 
([2008-3-1], [2008-3-2],	[2008-3-3],	[2008-3-4],	[2008-3-5])
) as pivotable


-- Question 2 (6 points)

/* Write a query to retrieve the top 3 products for each year.
   Use OrderQty of SalesOrderDetail to calculate the total sold quantity.
   The top 3 products have the 3 highest total sold quantities.
   Also calculate the top 3 products' total sold quantity for the year.
   Return the data in the following format.

Year	Total Sale		Top3Products
2005	1598			709, 712, 715
2006	5703			863, 715, 712
2007	9750			712, 870, 711
2008	8028			870, 712, 711
*/

with temp as (

select 
year(OrderDate) Year, productId, sum(OrderQty) as total , 
rank() over(partition by year(OrderDate) order by sum(OrderQty) desc) rank
from Sales.SalesOrderDetail sod
join Sales.SalesOrderHeader soh
on sod.SalesOrderId=Soh.SalesOrderID
group by year(orderdate), productid
)

select Year, sum(total) as [Total Sale], 
stuff(( select ', ' + cast(productid as varchar) 
from temp t1
where t1.year=t2.year
and rank<=3
for xml path('')), 1, 2, '') Top3Products
from temp t2
where rank<=3
group by year


-- Question 1 (2 points)
USE AdventureWorks2008R2;
/* The following SQL query generates a report in a vertical format.
   Please convert the query to a PIVOT query that creates a report
   containing the same data but in a horizontal format.
   The returned report should have the format like the one listed below,
   with NULL converted to 0. Use an alias to create a column heading.
   The example format below may not contain all the returned data. */
    
SELECT TerritoryID, CAST(OrderDate AS DATE) [Order Date], 
       SUM(TotalDue) AS [Sale Amount]
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '5-1-2008' AND '5-5-2008'
GROUP BY TerritoryID, OrderDate
ORDER BY TerritoryID, OrderDate;
/*
TerritoryID	2008-5-1		2008-5-2	2008-5-3	2008-5-4	2008-5-5
	1		640355.3651		3513.7676	10004.2614	2220.8956	7148.2785
	2		187500.0667		0.00		0.00		0.00		0.00
	3		281836.1068		0.00		0.00		0.00		0.00
*/

select TerritoryID,

isnull([2008-5-1],0)[2008-5-1],isnull([2008-5-2],0)[2008-5-2],isnull([2008-5-3],0)[2008-5-3],isnull([2008-5-4],0)[2008-5-4],isnull([2008-5-5],0)[2008-5-5]
from(
    
SELECT TerritoryID, OrderDate  , 
       SUM(TotalDue) as TotalDue
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '5-1-2008' AND '5-5-2008'
GROUP BY TerritoryID, OrderDate)t
pivot
(
sum(totaldue)
for OrderDate in ([2008-5-1],[2008-5-2],[2008-5-3],[2008-5-4],[2008-5-5])
) pivottable

---------------------



----LAB 4 PART B

/* Use the content of AdventureWorks and write a query to list the top 3 products included in an order for 
all orders. The top 3 products have the 3 highest order quantities. If there is a tie, it needs to be 
retrieved. The report needs to have the following format. Sort the returned data by the sales order 
column.


SalesOrderID   Products
43659          709, 711, 777, 714
43660          762, 758
43661          708, 776, 712, 715
43662          758, 770, 762
43663          760                                */


with temp as (
select soh.SalesOrderID, ProductId , OrderQty
, rank() over(partition by soh.SalesOrderID order by OrderQty desc) rank
from Sales.SalesOrderHeader soh
join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID
)
select distinct SalesOrderId, 
stuff((select ', ' + cast(ProductID as varchar)
from temp t1
where t1.SalesOrderID=t2.SalesOrderID
and rank<=3
for xml path('')), 1,2, '') as Top3
from temp t2
where t2.rank<=3
--group by t2.SalesOrderID
order by t2.SalesOrderID


---------------------------------

/* Using the content of AdventureWorks, write a query to retrieve
all unique customers with all salespersons each customer has dealt with. Exclude the customers who have never worked with a salesperson.
Sort the returned data by CustomerID in the descending order.
The result should have the following format.
Hint: Use the SalesOrderHeadrer table.
CustomerID SalesPersonID 30118 275, 277 30117 275, 277 30116 276
30115 289 30114 290 30113 282 30112 280, 284 */

with temp as (
Select CustomerID, SalesPersonID from Sales.SalesOrderHeader)
select distinct CustomerID, 
stuff((select distinct ', ' + cast(SalesPersonID as varchar)
from temp t1
where t1.CustomerId=t2.CustomerID
and SalesPersonID is not null
for xml path('')),1,2,'')SalesPersons
from temp t2
order by CustomerID desc

SELECT DISTINCT soh2.CustomerID,
STUFF((SELECT DISTINCT ', '+RTRIM(CAST(SalesPersonID as char))
FROM Sales.SalesOrderHeader soh1
WHERE soh1.CustomerID = soh2.CustomerID
FOR XML PATH('')) , 1, 2, '') AS SalesPersonIDs
FROM Sales.SalesOrderHeader soh2
WHERE SalesPersonID IS NOT NULL
ORDER BY CustomerID DESC;


-----------------------

--Part C (2 points)
/*Use the content of AdventureWorks and write a query to list all distinct products included in an order for all orders. 
 * The report needs to have the following format. Sort the returned data by the sales order column. 
 * Within each order, sort the products in the ascending order.
43659   709, 711, 712, 714, 716, 771, 772, 773, 774, 776, 777, 778
43660   758, 762
43661   708, 711, 712, 715, 716, 741, 742, 743, 745, 747, 773, 775, 776, 777, 778*/

with temp as (
select SalesOrderID, ProductID from Sales.SalesOrderDetail)
Select distinct SalesOrderID, 
stuff((select distinct ', ' + cast(ProductID as varchar)
from temp t1
where t1.SalesOrderID=t2.SalesOrderID
for xml path('')), 1, 2, '') alllist
from temp t2
order by SalesOrderID, alllist


-- Question 3 (6 points)

/* In a tech company, a qualified employee may get multiple salary raises
   in a year. There is a business rule that no employee can be given a total
   of more than $40,000 as raises in a year. Any attempt to give an
   employee a total of more than $40,000 for raises in a year must be logged
   in an audit table and the violating raise is not allowed.

   Given the following 3 tables, please write a trigger to implement
   the business rule. The rule must be enforced every year.
   Assume only one raise is entered in the database at a time.
   You can just consider the INSERT scenarios.
*/
use shashank


---Lab 5-3
/* CREATE 3 tables as listed below in your own database. 
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
 Write a trigger to put the total sale order amount before tax
 (unit price * quantity for all items included in an order) 
 in the OrderAmountBeforeTax column of SaleOrder
 whenever there is a change in SaleOrderDetail. */
 --create database shatest
 use shatest
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

			CREATE TRIGGER trUpdateCustomerStatus
			ON dbo.saleOrder
			AFTER INSERT, UPDATE, DELETE
			AS BEGIN
				DECLARE @total money = 0;
				DECLARE @custid varchar(20);
				DECLARE @status varchar(10);

				SELECT @custid = isnull (i.CustomerID, d.CustomerID)
				   FROM inserted i full join deleted d 
				   ON i.CustomerID = d.CustomerID;

				SELECT @total = sum(OrderAmountBeforeTax)
				   FROM saleOrder
   				   WHERE CustomerID = @custid;

				IF @total > 5000
					SET @status = 'preferred'
				ELSE
					SET @status = 'regular';

				UPDATE Customer
					SET CustomerStatus = @status
					WHERE CustomerID = @custid 
			END

			-- TEST
			INSERT Customer VALUES ('008','Rachel','Ford','Regular');
			INSERT SaleOrder VALUES ('008','2018-03-21',2000);
			SELECT * FROM Customer;

			INSERT SaleOrder VALUES ('008','2018-03-23',5000);
			SELECT * FROM Customer;

			UPDATE SaleOrder SET OrderAmountBeforeTax = 2500
				   WHERE CustomerID = '008' and OrderDate = '2018-03-23';
			SELECT * FROM Customer;

			INSERT SaleOrder VALUES ('008','2018-03-28',6000);
			SELECT * FROM Customer;

			DELETE SaleOrder WHERE CustomerID = '008' and OrderDate = '2018-03-28';
			SELECT * FROM Customer;

			-- DROP
			DROP TABLE saleorderdetail;
			DROP TABLE saleorder;
			DROP TABLE customer;


-- Create a table-valued function  
CREATE FUNCTION dbo.GetDateRange  
(@StartDate date, @NumberOfDays int) 
RETURNS @DateList TABLE (Position int, DateValue date) 
AS BEGIN 
    DECLARE @Counter int = 0; 
    WHILE (@Counter < @NumberOfDays)  
    BEGIN 
        INSERT INTO @DateList  
            VALUES(@Counter + 1, 
                   DATEADD(day,@Counter,@StartDate)); 
        SET @Counter += 1; 
    END 
    RETURN; 
END 
GO 
 
-- Execute the new function 
 
SELECT * FROM dbo.GetDateRange('2009-12-31',14); 
 
 
-- Create a table-valued function 
 
CREATE FUNCTION GetLastOrdersForCustomer  
(@CustomerID int, @NumberOfOrders int) 
RETURNS TABLE 
AS 
RETURN (SELECT TOP(@NumberOfOrders) 
               SalesOrderID, 
               OrderDate, 
               PurchaseOrderNumber 
        FROM AdventureWorks2008R2.Sales.SalesOrderHeader 
        WHERE CustomerID = @CustomerID 
        ORDER BY OrderDate DESC, SalesOrderID DESC 
        ); 
GO 
 
-- Execute the new function 
 
SELECT * FROM GetLastOrdersForCustomer(17288,2); 


USE AdventureWorks2014
GO
/************EXAMPLE 1*****************************/
-- Clean up what we did before
DROP TRIGGER Sales.OrderDetailNotDiscontinued
CREATE TRIGGER OrderDetailNotDiscontinued
   ON Sales.SalesOrderDetail
   AFTER INSERT, UPDATE
AS
   IF EXISTS 
      (
       SELECT 'True' 
       FROM Inserted i
       JOIN Production.Product p
          ON i.ProductID = p.ProductID
       WHERE p.DiscontinuedDate IS NOT NULL
      )
   BEGIN
      ROLLBACK TRAN
      RAISERROR('Order Item is discontinued. Transaction Failed.',16,1)
   END
-- Clean up what we did b