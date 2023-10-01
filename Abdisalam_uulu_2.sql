
--Zhumabai Abdisalam uulu
--Setting a current database
USE AdventureWorks2014

--Part A
--Sales manager would like to know is the total sales revenue associated with each sales territory. 
--Create a report showing the total sales revenue broken out by territory name. 
--Round the revenue figures to the nearest dollar and sort the list so that the highest revenue territory appears first.

SELECT ROUND(SUM(SOH.SubTotal), 0) AS TotalRevenue, ST.Name
FROM Sales.SalesOrderHeader SOH 
INNER JOIN Sales.SalesTerritory ST 
ON SOH.TerritoryID = ST.TerritoryID
GROUP BY ST.Name

--Part B
--The sales manager would like to drill into the 2013 sales results. Revise your query
--from Part A to focus only on results from 2013 (Use the OrderDate) and break the results down by month.
-- Your result set should include four columns: Name (of the territory), Month, Year, and SalesRevenue. This time, sort the list first by territory name and then by month

SELECT ST.Name AS TerritoryName, DATEPART(month, SOH.OrderDate) AS SalesMonth, DATEPART(year, SOH.OrderDate) AS SalesYear, ROUND(SUM(SOH.Subtotal), 0) AS SalesRevenue
FROM Sales.SalesOrderHeader SOH 
INNER JOIN Sales.SalesTerritory ST 
ON SOH.TerritoryID = ST.TerritoryID
WHERE DATEPART(year, SOH.OrderDate) = 2013
GROUP BY ST.Name, DATEPART(month, SOH.ORDERDATE), DATEPART(year, SOH.OrderDate)
ORDER BY TerritoryName, SalesMonth

--Part C
--The sales manager would like to recognize territories that had at least one month in 2013
--with monthly sales over $750,000. Create a report listing these territories. It should
--contain only a single column named ‘AwardWinners’ and should be sorted alphabetically.
--Territories can only win this award once, regardless of the number of months where they
--exceeded the threshold, so don’t include duplicate values in your list.

SELECT ST.Name AS AwardWinners
FROM Sales.SalesOrderHeader SOH 
INNER JOIN Sales.SalesTerritory ST
ON SOH.TerritoryID = ST.TerritoryID
WHERE DATEPART(year, SOH.OrderDate) = 2013
GROUP BY ST.Name
HAVING SUM(SOH.SubTotal) > 750000
ORDER BY ST.Name


--Part D
--The sales manager would like to offer additional training to those territories that did not
--achieve the $750,000 at least once in 2013. Create a list of territories that did not achieve
--their target, sorted alphabetically and the column ‘TrainingTerritories’.
SELECT ST.Name AS TrainingTerritories
FROM Sales.SalesOrderHeader SOH 
INNER JOIN Sales.SalesTerritory ST
ON SOH.TerritoryID = ST.TerritoryID
WHERE DATEPART(year, SOH.OrderDate) = 2013
GROUP BY ST.Name
HAVING SUM(SOH.SubTotal) <= 750000
ORDER BY ST.Name

--Problem 2
--Part A
--The production manager is considering dropping some products and would like to
--generate a report that lists finished goods products (FinishedGoodsFlag=1) where the
--total sales volume is under 50 units. Create a report showing the product name and the
--total number of units ordered (named as ‘Quantity’). Sort the list by Quantity in descending order.
SELECT P.Name AS ProductName, SUM(SOD.OrderQty) AS Quantity
FROM Production.Product P
INNER JOIN Sales.SalesOrderDetail SOD 
ON P.ProductID = SOD.ProductID
WHERE P.FinishedGoodsFlag = 1
GROUP BY P.Name
HAVING SUM(SOD.OrderQty) < 50
ORDER BY Quantity DESC

--Part B
--The production manager is working on profit projections for the coming year. She needs
--to make some assumptions about the sales tax rates in various countries and wants to
--use a conservatively selected single rate for each country.
--Create a report showing the maximum sales tax rate (named as ‘MaxTaxRate’) for each
--country. Use the full country name in the report. Sort the list by tax rate with the highest tax rate first.

SELECT MAX(TR.TaxRate) AS MaxTaxRate, SP.Name
FROM Person.StateProvince SP
INNER JOIN Sales.SalesTaxRate TR 
ON SP.StateProvinceID = TR.StateProvinceID
GROUP BY SP.Name
ORDER BY MaxTaxRate DESC

--Part C
--The quality assurance department is issuing a recall for all helmets shipped to stores 
--during the first five days of February 2014 due to a safety issue. They are already handling
--the notification of individual consumers where records are available. The sales
--department needs your help to follow up with stores that received the recalled helmets.
--Produce a listing of stores that received helmets shipped during the recall period. Your
--result should have two columns:
--  • StoreName
--  • TerritoryNameSort 
-- the list in alphabetical order, first by territory name and then by store name. Each
-- store should only appear once in the list, regardless of the number of shipments they
-- received.

SELECT SS.Name AS StoreName, ST.Name AS TerritoryName
FROM Sales.SalesOrderDetail OD 
INNER JOIN Sales.SalesOrderHeader OH 
ON OD.SalesOrderID = OH.SalesOrderID
INNER JOIN Sales.SalesTerritory ST 
ON OH.TerritoryID = ST.TerritoryID
INNER JOIN Sales.Customer SC 
ON OH.CustomerID = SC.CustomerID
INNER JOIN Sales.Store  SS
ON SC.StoreID = SS.BusinessEntityID
INNER JOIN Production.Product PP 
ON OD.ProductID = PP.ProductID
WHERE PP.Name LIKE '%helmet%' AND OH.ShipDate >= '2014-02-1' AND OH.ShipDate <= '2014-02-05'
ORDER BY TerritoryName, StoreName
