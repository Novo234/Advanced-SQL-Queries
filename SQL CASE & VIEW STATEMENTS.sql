SELECT *
FROM Sales_table

-- CASE STATEMENTS
--Create a query to categorize orders based on the `Profit` column: 'Loss' for profits less than 0
--Low Profit' for profits between 0 and 100
-- 'High Profit' for profits greater than 100

SELECT Product_ID, Profit,
       CASE WHEN Profit < 0 THEN 'Loss'
		    WHEN Profit BETWEEN 0 AND 100 THEN 'Low Profit'
		    WHEN Profit > 100 THEN 'High Profit'
	   ELSE NULL END AS Order_category
FROM Sales_table

-- Write a query to display the `Customer Name` along with a flag indicating if their order quantity is 'High' (Quantity > 10) or 'Low' (Quantity<= 10).
SELECT Customer_Name, Quantity, 
       CASE WHEN Quantity > 10 THEN 'High'
	        WHEN Quantity <= 10 THEN 'Low'
	   ELSE NULL END AS Order_Qty_Flag
FROM Sales_table

--Create a query to classify orders based on the `Ship Mode`: 
-- 'Fast' for 'First Class'
--'Standard' for 'Standard Class

SELECT Order_ID,
       CASE WHEN Ship_Mode = 'First Class' THEN 'Fast'
	        WHEN Ship_Mode = 'Second Class' THEN 'Standard'
		ELSE 'Moderate' END AS Order_Classification
FROM Sales_table


--Write a query to show the `Sales` along with a message indicating if the sales are 'Above Average' or 'Below Average', considering the average sales of all orders.
SELECT Product_ID,
       CASE WHEN Sales > (SELECT AVG(Sales) FROM Sales_table) THEN 'Above Average'
        ELSE 'Below Average' END AS Rating
FROM Sales_table
GROUP BY Product_ID

--VIEW QUERIES
--Create a view named ‘sales_summary’ that shows the total sales, quantity, and profit for each region.
CREATE VIEW sales_summary AS
SELECT Region, SUM(Sales) AS TotalSales, SUM(Quantity) AS TotalQuantity, SUM(Profit) AS TotalProfit
FROM 
    Sales_table
GROUP BY Region

--Modify the ‘sales_summary’ view to include the category and subcategory columns.
ALTER VIEW Sales_summary AS
SELECT Region,Category, Sub_category, SUM(Sales) AS TotalSales, SUM(Quantity) AS TotalQuantity, SUM(Profit) AS TotalProfit
FROM Sales_table
GROUP BY Region, Category, Sub_Category

--Drop the ‘sales_summary’ view
DROP VIEW Sales_summary

--Create a view named ‘customer sales’ that shows the total sales and profit for each customer.
CREATE VIEW Customer_Sales AS
SELECT Customer_name, profit, SUM(Sales) Total_sales
FROM Sales_table
GROUP BY Customer_Name, Profit

--Modify the ‘customer sales’ view to include the city and state columns
ALTER VIEW Customer_Sales AS
SELECT Customer_name, profit,City, State, SUM(Sales) Total_sales
FROM Sales_table
GROUP BY Customer_Name, Profit, City, State

--Create a view named ‘product_sales’ that shows the total sales and profit for each product category and subcategory
CREATE VIEW Product_Sales AS
SELECT Profit, Category, Sub_Category, SUM(Sales) Total_Sales
FROM Sales_table
GROUP BY Profit, Category, Sub_Category

--ADVANCED QUERIES
--Write a query to find the top 3 customers with the highest total sales.
SELECT TOP 3 Customer_Name, SUM(Sales) AS Total_Sales
FROM Sales_table
GROUP BY Customer_Name

--Write a query to find the total sales and profit for each region, including only orders with a specific ship mode
SELECT Profit,Region, SUM(Sales) TotalSales
FROM Sales_table
WHERE Ship_mode IN ('First Class', 'Second Class', 'Standard Class')
GROUP BY Profit, Region

--Write a query to find the average sales and profit for each category and subcategory
SELECT Category, Sub_Category, Profit, AVG(Sales) AverageSales
FROM Sales_table
GROUP BY Category, Sub_Category, Profit

--Write a query to find the top 3 products with the highest total sales and profit
SELECT TOP 3 Product_ID, SUM(Sales) AS Total_Sales
FROM Sales_table
GROUP BY Product_ID

--Window functions
--1. Write a query to find the running total of sales for each order
SELECT Order_ID, Order_Date,Sales,
    SUM(Sales) OVER (ORDER BY Order_Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotalSales
FROM Sales_Table
ORDER BY Order_Date;
--2. Write a query to find the average sales and profit for each region including a running total.
SELECT Region,
    AVG(Sales) AS AvgSales,
    AVG(Profit) AS AvgProfit,
    SUM(Sales) OVER (PARTITION BY Region ORDER BY Order_Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotalSales,
    SUM(Profit) OVER (PARTITION BY Region ORDER BY Order_Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotalProfit
FROM Sales_table
GROUP BY Region, Order_Date
ORDER BY Region, Order_Date;

--3. Write a query to find the total sales and profit for each product category and sub category including a running total.
SELECT  Category, Sub_Category,
        SUM(Sales) AS TotalSales,
        SUM(Profit) AS TotalProfit,
        SUM(SUM(Sales)) OVER (PARTITION BY Category ORDER BY SubCategory) AS RunningTotalSales,
    SUM(SUM(Profit)) OVER (PARTITION BY Category ORDER BY SubCategory) AS RunningTotalProfit
FROM Sales_table
GROUP BY Category, Sub_Category,
ORDER BY Category, Sub_Category;

--CTE
--Write a query to find the total sales and profit for each region using a CTE to calculate the running total.
WITH SalesCTE AS (
    SELECT Region,
        SUM(Sales) AS TotalSales,
        SUM(Profit) AS TotalProfit
    FROM Sales_table
    GROUP BY Region
),
RunningTotalCTE AS (
    SELECT Region, TotalSales, TotalProfit,
        SUM(TotalSales) OVER (ORDER BY Region) AS RunningTotalSales,
        SUM(TotalProfit) OVER (ORDER BY Region) AS RunningTotalProfit
    FROM SalesCTE
)
SELECT Region, TotalSales,TotalProfit, RunningTotalSales, RunningTotalProfit
FROM RunningTotalCTE
ORDER BY Region

--Write a query to find the top 3 customers with the highest total sales, using a CTE to calculate the ranking
WITH CustomerSalesCTE AS (
    SELECT Customer_Name,
        SUM(Sales) AS TotalSales,
        RANK() OVER (ORDER BY SUM(Sales) DESC) AS SalesRank
    FROM Sales_table
    GROUP BY Customer_ID, Customer_Name
)
SELECT Customer_Name, TotalSales, SalesRank
FROM CustomerSalesCTE
WHERE SalesRank <= 3
ORDER BY SalesRank

--Write a query to find the average sales for each category and subcategory using a CTE to calculate the running average
WITH SalesAverage AS (
     SELECT Category, Sub_Category
	 AVG(Sales) OVER (ORDER BY Category


WITH SalesAverageCTE AS (
    SELECT Category,Sub_Category,
        AVG(Sales) OVER ( PARTITION BY Category, Sub_Category  ORDER BY Sales ) AS RunningAverage
    FROM Sales_table
)
SELECT Category,Sub_Category,
    AVG(Sales) AS AverageSales,
    MAX(RunningAverage) AS FinalRunningAverage
FROM SalesAverageCTE
GROUP BY Category, Sub_Category
ORDER BY Category, Sub_Category;


--Write a query to find the total sales and profit for each customer using a CTE to calculate the running total.

WITH CustomerSalesCTE AS (
    SELECT Customer_ID, Customer_Name,
        SUM(Sales) OVER (PARTITION BY Customer_ID ORDER BY Customer_ID) AS RunningTotalSales,
        SUM(Profit) OVER (PARTITION BY Customer_ID ORDER BY Customer_ID) AS RunningTotalProfit
    FROM Sales_table
)
SELECT  Customer_ID, Customer_Name,
    MAX(RunningTotalSales) AS TotalSales,
    MAX(RunningTotalProfit) AS TotalProfit
FROM CustomerSalesCTE
GROUP BY Customer_ID, Customer_Name
ORDER BY TotalSales DESC;

--Write a query to find the total sales and profit for each region using a CTE to calculate the running total and including only orders within a specific year and month.
WITH RegionSalesCTE AS (
    SELECT 
        Region,
        YEAR(Order_Date) AS OrderYear,
        MONTH(Order_Date) AS OrderMonth,
        SUM(Sales) OVER (PARTITION BY Region ORDER BY Order_Date ROWS UNBOUNDED PRECEDING) AS RunningTotalSales,
        SUM(Profit) OVER (PARTITION BY Region ORDER BY Order_Date ROWS UNBOUNDED PRECEDING) AS RunningTotalProfit
    FROM Sales_table
    WHERE YEAR(Order_Date) = 2012 AND MONTH(Order_Date) = 11
)
SELECT Region,
    MAX(RunningTotalSales) AS TotalSales,
    MAX(RunningTotalProfit) AS TotalProfit
FROM RegionSalesCTE
GROUP BY Region
ORDER BY TotalSales DESC;
