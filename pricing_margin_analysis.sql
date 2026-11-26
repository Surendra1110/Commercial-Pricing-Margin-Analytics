-- 1. Executive KPI Summary: Net Revenue, Price Leakage & Gross Margin %
SELECT 
    COUNT(Order_ID) AS Total_Orders,
    ROUND(SUM(Gross_Revenue), 2) AS Total_Gross_Revenue,
    ROUND(SUM(Net_Revenue), 2) AS Total_Net_Revenue,
    ROUND(SUM(Price_Leakage), 2) AS Total_Price_Leakage,
    ROUND(SUM(Gross_Margin), 2) AS Total_Gross_Margin,
    ROUND((SUM(Gross_Margin) / SUM(Net_Revenue)) * 100, 2) AS Gross_Margin_Pct
FROM commercial_pricing;

-- 2. Product Mix & Margin Variance vs. 32% Target
SELECT 
    Product_Category,
    Product_Name,
    ROUND(SUM(Net_Revenue), 2) AS Net_Revenue,
    ROUND(AVG(Discount_Pct) * 100, 2) AS Avg_Discount_Pct,
    ROUND((SUM(Gross_Margin) / SUM(Net_Revenue)) * 100, 2) AS Actual_Margin_Pct,
    ROUND(((SUM(Gross_Margin) / SUM(Net_Revenue)) - 0.32) * 100, 2) AS Margin_Variance_vs_Target_Pct
FROM commercial_pricing
GROUP BY Product_Category, Product_Name
ORDER BY Actual_Margin_Pct ASC;

-- 3. Unapproved High-Discount Leakage Audit (Discounts > 15%)
SELECT 
    Sales_Rep,
    Region,
    COUNT(CASE WHEN Discount_Pct > 0.15 THEN 1 END) AS High_Discount_Orders,
    ROUND(SUM(CASE WHEN Discount_Pct > 0.15 THEN Price_Leakage ELSE 0 END), 2) AS Excess_Leakage_Amount,
    ROUND((SUM(Gross_Margin) / SUM(Net_Revenue)) * 100, 2) AS Rep_Gross_Margin_Pct
FROM commercial_pricing
GROUP BY Sales_Rep, Region
ORDER BY Excess_Leakage_Amount DESC;

-- 4. Top 10 Margin-Eroding Accounts (Recovery Opportunity if Capped at 12% Discount)
SELECT 
    Customer_ID,
    Region,
    ROUND(SUM(Net_Revenue), 2) AS Customer_Revenue,
    ROUND(AVG(Discount_Pct) * 100, 2) AS Avg_Discount_Pct,
    ROUND(SUM(Price_Leakage), 2) AS Total_Price_Leakage,
    ROUND((SUM(Gross_Margin) / SUM(Net_Revenue)) * 100, 2) AS Gross_Margin_Pct
FROM commercial_pricing
GROUP BY Customer_ID, Region
HAVING AVG(Discount_Pct) > 0.14
ORDER BY Total_Price_Leakage DESC
LIMIT 10;

-- 5. Monthly Revenue & Gross Margin % Trend
SELECT 
    DATE_FORMAT(Order_Date, '%Y-%m') AS Order_Month,
    ROUND(SUM(Net_Revenue), 2) AS Monthly_Net_Revenue,
    ROUND(SUM(Price_Leakage), 2) AS Monthly_Price_Leakage,
    ROUND((SUM(Gross_Margin) / SUM(Net_Revenue)) * 100, 2) AS Monthly_Margin_Pct
FROM commercial_pricing
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY Order_Month;
