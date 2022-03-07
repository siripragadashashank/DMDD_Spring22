-- Set the database context
USE AdventureWorks2008R2; 

--2-1 
 
/* Write a query to retrieve all orders processed by salespersons 276 
   or 277 which had an total due value greater than $100,000. Include 
   the salesperson id, sales order id, order date and total due columns 
   in the returned data. 
 
   Use the CAST function in the SELECT clause to display the date 
   only for the order date. Use ROUND to display only two decimal  
   places for the total due amount. Use an alias to give a descriptive 
   column heading if a column heading is missing. Sort the returned 
   data first by the SalesPerson ID, then order date. 
 
   Hint: (a) Use the Sales.SalesOrderHeader table. 
         (b) The syntax for CAST is CAST(expression AS data_type), 
             where expression is the column name we want to format and 
             we can use DATE as data_type for this question to display 
             just the date.  
         (c) The syntax for ROUND is ROUND(expression, position_to_round), 
             where expression is the column name we want to format and 
             we can use 2 for position_to_round to display two decimal 
       places. */ 


select SalesPersonID
, SalesOrderID
, cast(OrderDate as date) as "Order Date"
, round(TotalDue, 2) as "Total Due"
from Sales.SalesOrderHeader
where SalesPersonID in (276, 277) and TotalDue > 100000
order by SalesPersonID, OrderDate

--2-2 

/* List the territory id, total number of orders and total sales amount 
   for each sales territory. Use the TotalDue column for calculating the  
   total sales amount. Include only the sales territories which 
   have a total order count greater than 3500. 
    
   Use a column alias to make the report look more presentable. Use ROUND and CAST  
   to display the total sales amount as a rounded integer. Sort the returned  
   data by the territory id. 
 
   Hint: You need to work with the Sales.SalesOrderHeader table. */ 

select TerritoryID
, count(SalesOrderID) as 'Total Number of Orders'
, cast(round(sum(TotalDue), 2) as int) as 'Total Sales Amount'
from sales.SalesOrderHeader
group by TerritoryID
HAVING COUNT(SalesOrderID) > 3500
order by TerritoryID;

--2-3 

/* Write a query to select the product id, name, list price, and  
   sell start date for the product(s) that have a list price greater 
   than the highest list price - $1,000. Display only the date  
   for the sell start date and make sure all columns have a descriptive 
   heading. Sort the returned data by the list price in descending. 
 
   Hint: You’ll need to use a simple subquery in a WHERE clause. */ 
 
select ProductID
, Name
, ListPrice as 'List Price'
, cast(SellStartDate as date) as 'Sell Start Date'
from Production.Product
where ListPrice > (select max(ListPrice) from Production.Product ) - 1000
order by ListPrice desc	  


-- 2-4

/* Write a query to retrieve the total sold quantity for each product. 
   Return only the products that have a total sold quantity greater than 3000 
   and have the black color. 
 
   Use a column alias to make the report look more presentable. 
   Sort the returned data by the total sold quantity in the descending order. 
   Include the product ID, product name and total sold quantity columns  
   in the report. 
 
   Hint: Use the Sales.SalesOrderDetail and Production.Product tables. */

select p.ProductID as 'Product ID'
, p.Name as 'Product Name'
, sum(sod.OrderQty) as 'Total Sold Quantity'	
from Production.Product p 
inner join Sales.SalesOrderDetail sod on sod.ProductID = p.ProductID
where p.Color like '%Black%'
group by p.ProductID, p.Name
HAVING sum(sod.OrderQty) > 3000
order by 'Total Sold Quantity' desc

--2-5 
/* Write a query to retrieve the dates in which there was  
   at least one product sold but no product in red 
   was sold.  
    
   Return the "date" and "total product quantity sold 
   for the date" columns. Use OrderQty in SalesOrderDetail 
   for calculating "total product quantity sold for the date". 
 
   Sort the returned data by the 
   "total product quantity sold for the date" column in desc. */ 

select cast(soh.OrderDate as date) as 'Order Date'
, sum(sod.OrderQty) as 'Total Product Quantity Sold for the Date'
from Production.Product p 
inner join Sales.SalesOrderDetail sod on sod.ProductID = p.ProductID
inner join Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID
WHERE p.Color <> 'Red'
group by soh.OrderDate
HAVING sum(sod.OrderQty)>0
order by 'Total Product Quantity Sold for the Date' desc



--2-6  
/* Write a query to retrieve a customer's 
   overall purchase and highest annual purchase. 
   Use TotalDue in SalesOrderHeader for calculating purchase. 
    
   Include the "Customer ID", "Last name", "First name", 
   "Overall purchase" and "Highest annual purchase" columns 
   in the returned data. Return only the customers who had 
   a total purchase greater than $500,000. 
       
   Sort the returned data by a customer's overall purchase in descending.  */ 


select OVP.CustomerID
, OVP.[Last Name]
, OVP.[First Name]
, round(OVP.[Overall Purchase], 2) as 'Over All Purchase' 
, HAP.[Highest Annual Purchase] 
from (
select c.CustomerID
, p.LastName as 'Last Name' 
, p.FirstName as 'First Name' 
, sum(soh.TotalDue) as 'Overall Purchase'
from Sales.Customer c
join Sales.SalesOrderHeader soh ON soh.CustomerID = c.CustomerID
join Person.Person p ON p.BusinessEntityID = c.PersonID
group by c.CustomerID , p.FirstName , p.LastName 
having sum(soh.TotalDue)> 500000 ) OVP
left join 
(
select b.CustomerID
, max(b.[Annual Purchase]) as 'Highest Annual Purchase' from 
(
select soh.CustomerID
, round(sum(soh.TotalDue), 2) as 'Annual Purchase'
from Sales.SalesOrderHeader soh 
group by soh.CustomerID , year(soh.OrderDate)
)b
group by b.CustomerID 
)HAP
on OVP.CustomerID=HAP.CustomerID
order by 'Over All Purchase' desc


/*
--------------------- multiple purchases for a year--> get annual purchase

--select soh.CustomerID, year(soh.OrderDate) as Year, soh.TotalDue
--from Sales.SalesOrderHeader soh 
--order by  soh.CustomerID
-----------------

--select soh.CustomerID, year(soh.OrderDate) as Year
--, round(sum(soh.TotalDue), 2) as 'Annual Purchase'
--from Sales.SalesOrderHeader soh 
--group by soh.CustomerID , year(soh.OrderDate)
--order by  soh.CustomerID

----------------------------

--select soh.CustomerID, sum(soh.TotalDue) as 'Overall Purchase' from Sales.SalesOrderHeader soh 
--group by soh.CustomerID
--order by sum(soh.TotalDue) desc
------------------------------------
*/
