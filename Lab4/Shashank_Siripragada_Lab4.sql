
-------------------------------------- Part A-----------------------

create database shashank;
use shashank;

--drop table dbo.TargetMailingLists;
--drop table dbo.TargetCustomers;
--drop table dbo.MailingLists;

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
MailingListID varchar(5) not null primary key,
MailingList varchar(40) not null
);

create table dbo.TargetMailingLists
(
TargetID int not null references dbo.TargetCustomers(TargetID), 
MailingListID varchar(5) not null references dbo.MailingLists(MailingListID),
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

with temp as (select distinct CustomerID, SalesPersonID,
isnull(cast(SalesPersonID AS varchar(20)),'') salespersonidnew from Sales.SalesOrderHeader) 
select distinct t2.CustomerID,
stuff((select ', ' + rtrim(cast(salespersonidnew as char))
from temp t1
where t1.CustomerID = t2.CustomerID FOR XML PATH('')), 1, 2,'') AS [SalesPerson ID]
from temp t2
order by CustomerID desc

------------------------------- B 2

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

USE AdventureWorks2008R2;

select 
cast(tab1.OrderYear as varchar(10)) as Year , round((SumOfOrderQtySum * 100.00 / OrderQtySum), 9) as [% of Total Sale] , Top5Products 
from (select OrderYear , sum(OrderQtySum) as SumOfOrderQtySum, string_agg(ProductID, ', ') as Top5Products from
(select year(OrderDate) as OrderYear , ProductID , sum(OrderQty) as OrderQtySum , rank() over (partition by year(OrderDate) order by sum(OrderQty) desc) as OrderQtyRank
from Sales.SalesOrderDetail sod
inner join Sales.SalesOrderHeader soh
on sod.SalesOrderID = soh.SalesOrderID
group by year(OrderDate), ProductID )
as RankedOrderQty
where OrderQtyRank <= 5
group by OrderYear
) as tab1
join
(select year(OrderDate) as OrderYear, sum(OrderQty) as OrderQtySum 
from Sales.SalesOrderDetail sod
inner join Sales.SalesOrderHeader soh
on sod.SalesOrderID = soh.SalesOrderID
group by year(OrderDate)) as tab2
on tab1.OrderYear = tab2.OrderYear

----------------------- Part C

/* Bill of Materials - Recursive */ 
/* Use Adventureworks */ 
/* The following code retrieves the components required for manufacturing 
   the "Mountain-500 Black, 48" (Product 992). Use it as the starter code 
   for calculating the material cost reduction if the component 815 
   is manufactured internally at the level 1 instead of purchasing it 
   for use at the level 0. Use the list price of a component as 
   the material cost for the component. */ 
 
-- Starter code 

USE AdventureWorks2008R2;

WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS 
( 
    SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty, 
           b.EndDate, 0 AS ComponentLevel 
    FROM Production.BillOfMaterials AS b 
    WHERE b.ProductAssemblyID = 992 AND b.EndDate IS NULL 
 
    UNION ALL 
 
    SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty, 
           bom.EndDate, ComponentLevel + 1 
    FROM Production.BillOfMaterials AS bom  
    INNER JOIN Parts AS p 
    ON bom.ProductAssemblyID = p.ComponentID AND bom.EndDate IS NULL 
) 
SELECT AssemblyID, ComponentID, Name, PerAssemblyQty, ComponentLevel 
FROM Parts AS p 
INNER JOIN Production.Product AS pr 
ON p.ComponentID = pr.ProductID 
ORDER BY ComponentLevel, AssemblyID, ComponentID; 

select (select ListPrice from Production.Product p where ProductID = 815) - 
(select sum(ListPrice) as InternallySum from Production.BillOfMaterials bom 
join Production.Product p on bom.ComponentID = p.ProductID 
where ProductAssemblyID = 815) 
as [Material Cost Reduction] ;