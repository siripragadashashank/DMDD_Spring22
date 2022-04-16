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
, sum(t2.totalprod)/t1.total * 100 
, cast(sum(t2.totalprod) as decimal) / t1.total * 100 [% of Total Sale]
,stuff((select ', ' + cast(ProductID as varchar) 
from temp2
where t2.year = year and topprods<=5
for xml path('')), 1, 2, '') as top5
from temp2 t2
join temp1 t1 on t1.year=t2.year and t2.topprods<=5
group by t2.year, t1.total



