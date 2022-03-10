
USE AdventureWorks2008R2;

/*
--Lab 3-1 
 Modify the following query to add a column that identifies the 
   performance of salespersons and contains the following feedback 
   based on the number of orders processed by a salesperson: 
 
     'Do more!' for the order count range 1-120 
     'Fine!' for the order count range of 121-320 
     'Excellent!' for the order count greater than 320 
 
   Give the new column an alias to make the report more readable.  
*/ 

 SELECT SalesPersonID
, p.LastName
, p.FirstName
, COUNT(o.SalesOrderid) [Total Orders] 
, CASE
WHEN COUNT(o.SalesOrderid) >= 1 and COUNT(o.SalesOrderid) <=120 THEN 'Do More!'
WHEN COUNT(o.SalesOrderid) >=121 and COUNT(o.SalesOrderid)<=320 THEN 'Fine!'
ELSE 'Excellent!'
END AS [Feedback]
FROM Sales.SalesOrderHeader o 
JOIN Person.Person p 
   ON o.SalesPersonID = p.BusinessEntityID 
GROUP BY o.SalesPersonID, p.LastName, p.FirstName 
ORDER BY p.LastName, p.FirstName; 
 
 
/* --Lab 3-2 
 Modify the following query to add a new column named rank. 
   The new column is based on ranking with gaps according to 
   the total orders in descending. Also partition by the territory.*/ 
 
SELECT o.TerritoryID, s.Name, o.SalesPersonID, 
COUNT(o.SalesOrderid) [Total Orders] 
, RANK() OVER  (PARTITION BY o.TerritoryID  ORDER BY COUNT(o.SalesOrderid) DESC) AS Rank
FROM Sales.SalesOrderHeader o 
JOIN Sales.SalesTerritory s 
   ON o.TerritoryID = s.TerritoryID 
WHERE SalesPersonID IS NOT NULL 
GROUP BY o.TerritoryID, s.Name, o.SalesPersonID 
ORDER BY o.TerritoryID; 
 
 
/* 
--Lab 3-3 
 Write a query to retrieve the most popular product of each city. 
   The most popular product has the highest total sold quantity in a city. 
   Use OrderQty in SalesOrderDetail for calculating the total sold quantity. 
   Use ShipToAddressID in SalesOrderHeader to determine what city a product  
   is related to. If there is a tie, your solution must retrieve it. 
 
   Return only the products which have a total sold quantity of more than 100 
   in a city. Include City, ProductID, and total sold quantity of the most 
   popular product in the city for the returned data.  
   Sort the returned data by City. */ 

Select 
City
, ShipToAddressID
, ProductID
, [Total Sold Quantity]
from (
SELECT 
soh.ShipToAddressID
, pa.City as City
, sod.ProductID
, sum(sod.OrderQty) as [Total Sold Quantity]
, RANK() OVER  (PARTITION BY soh.ShipToAddressID  ORDER BY sum(sod.OrderQty) DESC) AS Rank
FROM Sales.SalesOrderHeader soh 
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
join Person.Address pa on soh.ShipToAddressID = pa.AddressID
group by soh.ShipToAddressID, pa.City, sod.ProductID
having sum(sod.OrderQty)>100
)a where rank=1
order by City
 
/*
--Lab 3-4 
 Retrieve the top selling product of each day. 
   Use the total sold quantity to determine the top selling product. 
   The top selling product has the highest total sold quantity. 
   If there is a tie, the solution must pick up the tie. 
 
   Include the order date, product id, and the total sold quantity 
   of the top selling product of each day in the returned data. 
   Sort the returned data by the order date. 
*/ 

select 
cast(OrderDate as date) as [Order Date]
, ProductID
, [Total Sold Quantity]
from (
SELECT 
soh.OrderDate
, sod.ProductID
, sum(sod.OrderQty) as [Total Sold Quantity]
, RANK() OVER  (PARTITION BY soh.OrderDate ORDER BY sum(sod.OrderQty) DESC) AS Rank
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
group by  sod.ProductID, soh.OrderDate 
)a
where Rank=1
order by OrderDate

/*
--Lab 3-5 
 Write a query to retrieve the customers who have purchased 
   more than ten different products and never purchased 
   the same product for all of their orders.  
    
   For example, if Customer A has purchased more than 10 distinct 
   products and never purchased a product more than once for all of 
   his orders, then Customer A should be returned.  
 
   Sort the returned data by the total number of different 
   products purchased by a customer in the descending order.  
   Include only the customer id in the report. */ 


select 
soh.CustomerID
 --, count( distinct sod.ProductID) as ProdCount
 --, sum(sod.OrderQty) as [Total no. of Different Products]
from Sales.SalesOrderHeader soh
left join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
group by soh.CustomerID
having count(distinct sod.ProductID) > 10 and count(distinct sod.ProductID)=sum(sod.OrderQty)
order by sum(sod.OrderQty) desc