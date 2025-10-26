
-- Display all products with a selling price greater than ₹500.
select ProductName,ProductPrice from products
	where ProductPrice >500;

-- Show top 10 products with the highest total revenue.
select p.ProductName , sum(p.ProductPrice * s.OrderQuantity) as total_revenue
from products p join `sales-2017` s
	on p.ProductKey = s.ProductKey
group by p.ProductName
order by total_revenue desc
limit 10;

-- List all sales transactions from the year 2017 where quantity > 10.
select OrderNumber from `sales-2017` where OrderQuantity >10;

-- Combine Products, ProductSubcat, and ProductCat to display each product’s name, subcategory, and category.
select p.ProductName, ps.SubcategoryName, pc.CategoryName 
from products p join ProductSubcat ps 
	on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
join productcat pc
	on ps.ProductCategoryKey = pc.ProductCategoryKey;

-- Show all products and their return quantities (include products with no returns).
select p.productname , sum(r.ReturnQuantity) as total_return_qty
from returns r join products p 
	on r.ProductKey = p.ProductKey
group by p.productname;

-- Display all return records along with corresponding product and category information.
select p.productname , pc.CategoryName, sum(r.ReturnQuantity) as total_return_qty
from products p join ProductSubcat ps 
	on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
join productcat pc
	on ps.ProductCategoryKey = pc.ProductCategoryKey
join returns r 
	on r.productkey = p.productkey
group by 1,2;

-- Find which category contributed the most to total sales.
select pc.CategoryName , round(sum(p.ProductPrice * s.OrderQuantity),2) as total_sales
from products p join ProductSubcat ps 
	on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
join productcat pc
	on ps.ProductCategoryKey = pc.ProductCategoryKey
join `sales-2017` s
	on s.ProductKey = p.ProductKey
group by 1;

-- Find average sales per subcategory.
select ps.SubcategoryName , avg(p.ProductPrice * s.OrderQuantity) as avg_sales
from products p join ProductSubcat ps 
	on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
join `sales-2017` s
	on s.ProductKey = p.ProductKey
group by 1;

-- Identify the top 3 products by total revenue.
select p.productname , sum(p.ProductPrice * s.OrderQuantity) as revenue
from products p join ProductSubcat ps 
	on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
join `sales-2017` s
	on s.ProductKey = p.ProductKey
group by 1
order by revenue desc
limit 3;

-- Count the number of products in each category.
select pc.CategoryName, count(productkey) as no_of_products
from products p join ProductSubcat ps 
	on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
join productcat pc
	on ps.ProductCategoryKey = pc.ProductCategoryKey
group by 1;

-- Find all products whose revenue is above the overall average revenue.
SELECT 
  p.ProductName,
  SUM(p.ProductPrice * s.OrderQuantity) AS total_revenue
FROM products p JOIN `sales-2017` s 
	ON p.ProductKey = s.ProductKey
GROUP BY 
  p.ProductName
HAVING 
  SUM(p.ProductPrice * s.OrderQuantity) > (
    SELECT AVG(total_rev) FROM (
      SELECT SUM(p2.ProductPrice * s2.OrderQuantity) AS total_rev
      FROM products p2 JOIN `sales-2017` s2 
		ON p2.ProductKey = s2.ProductKey
      GROUP BY p2.ProductName
    ) avg_table
  );

-- Create a view named v_ProductPerformance showing product, category, subcategory, revenue, and quantity sold.
CREATE VIEW view_Product AS
SELECT
    p.Product_Name,
    s.SubcategoryName,
    c.CategoryName,
    s.OrderQuantity,
    p.ProductPrice * s.OrderQuantity as revenue
FROM Products p
JOIN ProductSubcat s 
    ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
JOIN ProductCat c 
    ON s.ProductCategoryKey = c.ProductCategoryKey
JOIN`sales-2017` s
	ON s.ProductKey = p.ProductKey ;

-- Using that view, find total revenue per category.
SELECT 
    CategoryName,
    SUM(Revenue) AS Total_Revenue
FROM view_Product
GROUP BY Category_Name
ORDER BY Total_Revenue DESC;


-- Create an index on Product_ID in Returns and Sales-2015 to improve query performance.
CREATE INDEX idx_product_returns 
ON Returns(Product_ID);

CREATE INDEX idx_product_sales 
ON `Sales-2015`(Product_ID);

-- Find total monthly sales for 2017.
SELECT 
    MONTH(OrderDate) AS Sale_Month,
    SUM(Revenue) AS Total_Monthly_Sales
FROM `Sales-2017`
GROUP BY MONTH(OrderDate)
ORDER BY Sale_Month;

-- Show month-wise return counts.
SELECT 
    MONTH(Return_Date) AS Return_Month,
    COUNT(Return_ID) AS Total_Returns
FROM Returns
GROUP BY MONTH(Return_Date)
ORDER BY Return_Month;
