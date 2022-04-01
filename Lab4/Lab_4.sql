------------ Part A ------------------

CREATE DATABASE MayannkDB;
GO

CREATE TABLE dbo.TargetCustomers 
    ( 
    TargetID varchar(5) NOT NULL PRIMARY KEY , 
    FirstName varchar(40) NOT NULL , 
    LastName varchar(40) NOT NULL , 
    Address varchar(40) NOT NULL , 
    City varchar(40) NOT NULL , 
    State varchar(40) NOT NULL , 
    ZipCode varchar(5) NOT NULL 
    );

	CREATE TABLE dbo.MailingLists 
    ( 
    MailingListID int IDENTITY NOT NULL PRIMARY KEY , 
    MailingList varchar(40) NOT NULL
    );

	CREATE TABLE dbo.TargetMailingLists 
     ( 
    TargetID varchar(5) NOT NULL 
		REFERENCES TargetCustomers(TargetID), 
    MailingListID int NOT NULL 
        REFERENCES MailingLists(MailingListID) 
    );


------------ Part B-1 ----------------

USE AdventureWorks2008R2;

	WITH temp AS (
	SELECT DISTINCT CustomerID,SalesPersonID,
	ISNULL(CAST(SalesPersonID AS varchar(20)),'') idNEW
FROM Sales.SalesOrderHeader) 
SELECT DISTINCT t2.CustomerID,
STUFF( (
SELECT ', ' + RTRIM(CAST(idNEW as char))
FROM
temp t1
WHERE
t1.CustomerID = t2.CustomerID FOR XML PATH('')) ,1,2,'') AS listSalesPersonID
FROM
temp t2
ORDER BY
CustomerID DESC;


------------ Part B-2 ----------------

select 
cast(sql1.OrderYear as varchar(10)) as Year , (SumOfOrderQtySum * 100.00 / OrderQtySum) as PercentageofTotalSale , Top5Products 
from
(select
OrderYear , sum( OrderQtySum ) as SumOfOrderQtySum, string_agg(ProductID, ', ') as Top5Products from
(select
year(OrderDate) as OrderYear , ProductID , sum(OrderQty) as OrderQtySum , rank() over (partition by year(OrderDate) order by sum(OrderQty) desc) as OrderQtyRank
from
Sales.SalesOrderDetail sod
inner join
Sales.SalesOrderHeader soh
on
sod.SalesOrderID = soh.SalesOrderID
group by
year(OrderDate), ProductID )
as
RankedOrderQty
where
OrderQtyRank <= 5
group by 
OrderYear)
as 
sql1
join
(select
year(OrderDate) as OrderYear, sum(OrderQty) as OrderQtySum 
from
Sales.SalesOrderDetail sod
inner join
Sales.SalesOrderHeader soh
on
sod.SalesOrderID = soh.SalesOrderID
group by 
year(OrderDate))
as
sql2
on
sql1.OrderYear = sql2.OrderYear ;

------------ Part C ------------------

WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS 
(SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty, b.EndDate, 0 AS ComponentLevel 
FROM Production.BillOfMaterials AS b 
WHERE b.ProductAssemblyID = 992 AND b.EndDate IS NULL
UNION ALL
SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty, bom.EndDate, ComponentLevel + 1 
FROM Production.BillOfMaterials AS bom  
INNER JOIN Parts AS p 
ON bom.ProductAssemblyID = p.ComponentID AND bom.EndDate IS NULL)
SELECT AssemblyID, ComponentID, Name, PerAssemblyQty, ComponentLevel 
FROM Parts AS p 
INNER JOIN Production.Product AS pr 
ON p.ComponentID = pr.ProductID 
ORDER BY ComponentLevel, AssemblyID, ComponentID;

select (select ListPrice from Production.Product p where ProductID = 815) - (select sum(ListPrice) as InternallySum from Production.BillOfMaterials bom join Production.Product p on bom.ComponentID = p.ProductID where ProductAssemblyID = 815) as PriceReduction ;