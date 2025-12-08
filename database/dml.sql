-- The Game Dam Inventory Management System
-- Group 62
-- Kevin Pham
-- Brian Gatch
--
-- This file will contain all data manipulation language (DML) commands for our
-- partially functional inventory management system.

-- Get all category IDs and names from Categories table to populate Category dropdown
SELECT * FROM Categories

-- Get all product information and their category names
SELECT productID AS 'ID', productName AS 'Name', productPrice AS 'Price', 
    productStock AS 'Stock', Categories.categoryName AS 'Category' FROM Products 
LEFT JOIN Categories ON Products.categoryID = Categories.categoryID

-- Get one product information based on product ID from the Update Product form
SELECT productID, productName, productPrice, productStock, categoryID FROM Products
WHERE productID = :productID_selected_from_update_form

-- Create new product
INSERT INTO Products (productName, productPrice, productStock, categoryID) 
VALUES (p_name, p_price, p_stock, category);

-- Update existing product
UPDATE Products SET productPrice = p_price, productStock = p_stock WHERE productID = p_id; 

-- Delete a product
DELETE FROM Products WHERE productID = :product_id_input

-- Associate a product with a supplier
INSERT INTO Products_Suppliers (productID, supplierID) 
VALUES (p_id, s_id);

-- Update a product-supplier relationship
UPDATE Products_Suppliers SET productID = p_id, supplierID = s_id WHERE proSupID = ps_id; 

-- Delete a product-supplier relationship
DELETE FROM Products_Suppliers WHERE proSupID = ps_id;

-- Get all Restock Orders with their supplier names and employee names
SELECT orderID, orderDate, totalCost, isDelivered, 
    Suppliers.supplierName as "Supplier", CONCAT(Employees.fName, " ", Employees.lName) as "Employee" FROM RestockOrders 
LEFT JOIN Suppliers ON RestockOrders.supplierID = Suppliers.supplierID 
LEFT JOIN Employees ON RestockOrders.employeeID = Employees.employeeID

-- Get all Product Restock Details for all Restock Orders and their product names
SELECT detailsID, orderID, Products.productName as "Product", 
    quantityOrdered, singlePrice, totalPrice FROM ProductRestockDetails 
LEFT JOIN Products ON ProductRestockDetails.productID = Products.productID

-- get all employees and their information
SELECT employeeID AS "ID", fName AS "FirstName", lName AS "LastName", 
email AS "Email", phone AS "Phone" FROM Employees

-- get all suppliers and their information
SELECT supplierID as "ID", supplierName as "SupplierName", phone as "Phone", email as "Email", 
    address as "Address", state as "State", zip as "ZipCode", country as "Country", city as "City"  FROM Suppliers

-- Get category information
SELECT categoryID AS "ID", categoryName as "CategoryName" FROM Categories

-- Get product supplier information
SELECT proSupID as "ID", Products.productID as "ProductID", Suppliers.supplierID as "SupplierID", 
     Products.productName as "ProductName", Suppliers.supplierName as "SupplierName" FROM Products_Suppliers
LEFT JOIN Products ON Products_Suppliers.productID = Products.productID
LEFT JOIN Suppliers ON Products_Suppliers.supplierID = Suppliers.supplierID;