
-- A query is running for a long time
SELECT Sales.Customers.CustomerID,
       Sales.Customers.CustomerName,
       SUM(UnitPrice * Quantity)
FROM Sales.OrderLines
INNER JOIN Sales.Orders ON Sales.OrderLines.OrderID = Sales.Orders.OrderID
INNER JOIN Sales.Customers ON Sales.Customers.CustomerID = Sales.Orders.CustomerID
GROUP BY Sales.Customers.CustomerID, Sales.Customers.CustomerName