create database shashank;
use shashank;


create table dbo.TargetCustomers
(
TargetID int IDENTITY not null primary key,
FirstName varchar(40) not null,
LastName varchar(40) not null,
Address varchar(40) not null,
City varchar(40) not null,
State varchar(40) not null,
ZipCode varchar(5) not null
);


create table dbo.MailingLists
(
MailingListID int IDENTITY not null primary key,
MailingList varchar(40) not null
);

create table dbo.TargetMailingLists
(
TargetID int not null references dbo.TargetCustomers(TargetID), 
StudentID int not null references dbo.MailingLists(MailingListID),
);


--------------------------------------------------

---Part B 
 
--- B-1 
/* Using the content of AdventureWorks, write a query to retrieve 
   all unique customers with all salespeople they have dealt with. 
   If a customer has never worked with a salesperson, make the 
   'Salesperson ID' column blank instead of displaying NULL. 
   Sort the returned data by CustomerID in the descending order. 
   The result should have the following format. 
 
   Hint: Use the SalesOrderHeadrer table. 
 
CustomerID SalesPerson ID 
30118  275, 277 
30117  275, 277 
30116  276 
30115  289 
30114  290 
30113  282 
30112  280, 284 
*/ 

USE AdventureWorks2008R2;


Select soh1.CustomerID, 
STUFF(
(Select distinct ', ' + isnull(CAST([SalesPersonID] AS VARCHAR(20)), '') 
from Sales.SalesOrderHeader soh2
where soh1.CustomerID = soh2.CustomerID 
FOR XML PATh ('')
),1,1,'') as [SalesPersonID]
from Sales.SalesOrderHeader soh1
group by soh1.CustomerID
order by soh1.CustomerID desc

WITH temp AS (
SELECT DISTINCT CustomerID,
SalesPersonID, ISNULL(CAST(SalesPersonID AS varchar(20)),'') idNEW
FROM Sales.SalesOrderHeader) 
SELECT
DISTINCT t2.CustomerID,
STUFF(
(SELECT ', ' + RTRIM(CAST(idNEW as char))
FROM temp t1
WHERE t1.CustomerID = t2.CustomerID 
FOR XML PATH('')
),1,2,'') AS listSalesPersonID
FROM temp t2
ORDER BY CustomerID DESC;

-------------------------------2 B

/* Using the content of AdventureWorks, write a query to retrieve the top five  
     products for each year. Use OrderQty of SalesOrderDetail to calculate the total quantity sold. 
     The top five products have the five highest sold quantities.  Also calculate the top five products'  
     sold quantity for a year as a percentage of the total quantity sold for the year.  
    
     Return the data in the following format. 
 
 Year % of Total Sale   Top5Products 
 2005 19.58980418600  709, 712, 715, 770, 760 
 2006 13.70859187700  863, 715, 712, 711, 852 
 2007 12.39464630800  712, 870, 711, 708, 715 
 2008 15.68128704000  870, 712, 711, 708, 707 
*/ 

--Select soh1.CustomerID, 
--STUFF(
--(Select distinct ', ' + isnull(CAST([SalesPersonID] AS VARCHAR(20)), '') 
--from Sales.SalesOrderHeader soh2
--where soh1.CustomerID = soh2.CustomerID 
--FOR XML PATh ('')
--),1,1,'') as [SalesPersonID]
--from Sales.SalesOrderHeader soh1
--group by soh1.CustomerID
--order by soh1.CustomerID desc

select soh1.year, soh1.TotalQtySold 
stuff(
(select ', ' + CAST([ProductID] AS VARCHAR(20)) from (
select abc.Year, total, ProductID from (
select a.Year
, sum(TtlQty) as total
from (
select year(soh.OrderDate) as Year
, sum(sod.OrderQty) as TtlQty
, rank() over(partition by year(soh.OrderDate) order by sum(sod.OrderQty) desc) as rank
, ProductID from Sales.SalesOrderDetail sod
join Sales.SalesOrderHeader soh on
Sod.SalesOrderID = soh.SalesOrderID
group by year(soh.OrderDate), ProductID
)a where a.rank<=5
group by a.year )abc 
left join (
select a.Year, a.ProductID
from ( select year(soh.OrderDate) as Year
, sum(sod.OrderQty) as TtlQty
, rank() over(partition by year(soh.OrderDate) order by sum(sod.OrderQty) desc) as rank
, ProductID from Sales.SalesOrderDetail sod
join Sales.SalesOrderHeader soh on
Sod.SalesOrderID = soh.SalesOrderID
group by year(soh.OrderDate), ProductID )a
where a.rank<=5)aba on abc.year=aba.year
)tab2
where soh1.year=tab2.year
FOR XML PATh ('')
),1,1,'') as [SalesPersonID]
from (select year(soh.OrderDate), sum(sod.OrderQty) as TotalQtySold from Sales.SalesOrderDetail sod
join Sales.SalesOrderHeader soh on
Sod.SalesOrderID = soh.SalesOrderID
group by year(soh.OrderDate))soh1



Select soh1.CustomerID, 
STUFF(
(Select distinct ', ' + isnull(CAST([SalesPersonID] AS VARCHAR(20)), '') 
from Sales.SalesOrderHeader soh2
where soh1.CustomerID = soh2.CustomerID 
FOR XML PATh ('')
),1,1,'') as [SalesPersonID]
from Sales.SalesOrderHeader soh1
group by soh1.CustomerID
order by soh1.CustomerID desc


