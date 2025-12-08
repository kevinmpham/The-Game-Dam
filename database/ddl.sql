-- The Game Dam Inventory Management System
-- Group 62
-- Kevin Pham
-- Brian Gatch
-- 10/30/2025

-- This file is a database definition language (DDL) script that will create
-- the necessary tables for our partially functional inventory management system,
-- along with inserting sample data to test the functionality of our system.
-- This file corresponds to our CS340 Portfolio Project

-- Disable foreign key checks and autocommit for clean import
SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;

DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS ProductRestockDetails;
DROP TABLE IF EXISTS Products_Suppliers;
DROP TABLE IF EXISTS RestockOrders;
DROP TABLE IF EXISTS Suppliers;

-- Categories table: Stores information on category of product
CREATE TABLE `Categories` (
  `categoryID` int(11) NOT NULL AUTO_INCREMENT UNIQUE,
  `categoryName` varchar(55) NOT NULL,
  PRIMARY KEY (categoryID)
);

-- Employees table: stores information about employees in the company
CREATE TABLE `Employees` (
  `employeeID` int(11) NOT NULL AUTO_INCREMENT UNIQUE,
  `fName` varchar(55) NOT NULL,
  `lName` varchar(55) NOT NULL,
  `email` varchar(55) NOT NULL,
  `phone` varchar(20) NOT NULL,
  PRIMARY KEY (employeeID)
); 

-- Products table: stores information of products in store
CREATE TABLE `Products` (
  `productID` int(11) NOT NULL AUTO_INCREMENT UNIQUE,
  `productName` varchar(55) NOT NULL,
  `productPrice` decimal(10,2) NOT NULL,
  `productStock` int(11) NOT NULL,
  `categoryID` int(11) NOT NULL,
  PRIMARY KEY(productID),
  FOREIGN KEY(categoryID) REFERENCES Categories(categoryID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


-- Suppliers table: stores information on various supplies
CREATE TABLE `Suppliers` (
  `supplierID` int(11) NOT NULL AUTO_INCREMENT UNIQUE,
  `supplierName` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `state` varchar(55) NOT NULL,
  `zip` varchar(55) NOT NULL,
  `country` varchar(55) NOT NULL,
  `city` varchar(55) NOT NULL,
  PRIMARY KEY (supplierID)
);

-- Products_Suppliers table: intersection table between Products and Suppliers
CREATE TABLE `Products_Suppliers` (
  `proSupID` int(11) NOT NULL AUTO_INCREMENT UNIQUE,
  `productID` int(11) NOT NULL,
  `supplierID` int(11) NOT NULL,
  PRIMARY KEY(proSupID),
  FOREIGN KEY(productID) REFERENCES Products(productID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY(supplierID) REFERENCES Suppliers(supplierID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- RestockOrders table: stores information on restock orders made to suppliers
CREATE TABLE `RestockOrders` (
  `orderID` int(11) NOT NULL AUTO_INCREMENT UNIQUE,
  `orderDate` date NOT NULL,
  `totalCost` decimal(10,2) NOT NULL,
  `isDelivered` binary(1) NOT NULL DEFAULT '0',
  `supplierID` int(11) NOT NULL,
  `employeeID` int(11) NOT NULL,
  PRIMARY KEY (orderID),
  FOREIGN KEY(supplierID) REFERENCES Suppliers(supplierID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY(employeeID) REFERENCES Employees(employeeID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- ProductRestockDetails table: stores information on products in each restock order
CREATE TABLE `ProductRestockDetails` (
  `detailsID` int(11) NOT NULL AUTO_INCREMENT UNIQUE,
  `productID` int(11) NOT NULL,
  `orderID` int(11) NOT NULL,
  `quantityOrdered` int(11) NOT NULL,
  `singlePrice` decimal(10,2) NOT NULL,
  `totalPrice` decimal(10,2) NOT NULL,
  PRIMARY KEY (detailsID),
  FOREIGN KEY(productID) REFERENCES Products(productID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY(orderID) REFERENCES RestockOrders(orderID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Insert sample data for Categories
INSERT INTO Categories (`categoryName`) VALUES
('Video Game'),
('Trading Card'),
('Board Game'),
('Accessory');

-- Insert sample data for Employees
INSERT INTO Employees (`fName`, `lName`, `email`, `phone`) VALUES
('Duke', 'Brown', 'dukebrown@email.com', '555-000-0001'),
('Tina', 'Blue', 'tinablue@email.com', '555-000-0002'),
('Jack', 'Black', 'jackblack@email.com', '555-000-0003'),
('John', 'White', 'johnwhite@email.com', '555-000-0004');

-- Insert sample data for Products
INSERT INTO Products (`productName`, `productPrice`, `productStock`, `categoryID`) VALUES
('Mario Kart', 59.99, 20, 
    (SELECT categoryID FROM Categories WHERE categoryName = 'Video Game')),
('Pokemon Evolutions Booster', 4.99, 120, 
    (SELECT categoryID FROM Categories WHERE categoryName = 'Trading Card')),
('PS5 Dualshock Controller', 69.99, 12, 
    (SELECT categoryID FROM Categories WHERE categoryName = 'Accessory')),
('Settlers of Catan', 39.99, 16, 
    (SELECT categoryID FROM Categories WHERE categoryName = 'Board Game'));

-- Insert sample data for Suppliers
INSERT INTO Suppliers (`supplierName`, `phone`, `email`, `address`, `state`, `zip`, `country`, `city`) VALUES
('Games Warehouse', '555-111-0001', 'gameswherehouse@email.com', '123 Games Street', 'OR', '97001', 'USA', 'Portland'),
('International Shippers', '555-111-0002', 'intership@email.com', '1122 Wei Way', 'SI', '663312', 'China', 'Sichuan'),
('Deals Central', '555-111-0003', 'dealscenral@email.com', '234 Good Deals Lane', 'VA', '25011', 'USA', 'Fairfax');

-- Insert sample data for Products_Suppliers
INSERT INTO Products_Suppliers (`productID`, `supplierID`) VALUES
((SELECT productID FROM Products WHERE productName = 'Mario Kart'),
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'Games Warehouse')),
((SELECT productID FROM Products WHERE productName = 'Pokemon Evolutions Booster'),
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'Games Warehouse')),
((SELECT productID FROM Products WHERE productName = 'PS5 Dualshock Controller'),
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'Games Warehouse')),
((SELECT productID FROM Products WHERE productName = 'Settlers of Catan'),
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'Games Warehouse')),
((SELECT productID FROM Products WHERE productName = 'Pokemon Evolutions Booster'),
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'International Shippers')),
((SELECT productID FROM Products WHERE productName = 'PS5 Dualshock Controller'),
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'International Shippers')),
((SELECT productID FROM Products WHERE productName = 'PS5 Dualshock Controller'),
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'Deals Central')),
((SELECT productID FROM Products WHERE productName = 'Settlers of Catan'),
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'Deals Central'));

-- Insert sample data for RestockOrders
INSERT INTO RestockOrders (`orderDate`, `totalCost`, `isDelivered`, `supplierID`, `employeeID`) VALUES
('2024-10-05', 100.00, 1, 
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'Games Warehouse'), 
    (SELECT employeeID FROM Employees WHERE fName = 'Duke' AND lName = 'Brown')),
('2025-01-01', 600.00, 1, 
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'International Shippers'), 
    (SELECT employeeID FROM Employees WHERE fName = 'Tina' AND lName = 'Blue')),
('2025-10-29', 50.00, 0, 
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'Deals Central'), 
    (SELECT employeeID FROM Employees WHERE fName = 'John' AND lName = 'White')),
('2024-10-30', 300.00, 0, 
    (SELECT supplierID FROM Suppliers WHERE supplierName = 'Games Warehouse'), 
    (SELECT employeeID FROM Employees WHERE fName = 'Jack' AND lName = 'Black'));

-- Insert sample data for ProductRestockDetails
INSERT INTO ProductRestockDetails (`productID`, `orderID`, `quantityOrdered`, `singlePrice`, `totalPrice`) VALUES
((SELECT productID FROM Products WHERE productName = 'Mario Kart'),
    1, 1, 50.00, 50.00),
((SELECT productID FROM Products WHERE productName = 'Settlers of Catan'),
    1, 2, 25.00, 50.00),
((SELECT productID FROM Products WHERE productName = 'PS5 Dualshock Controller'),
    2, 10, 50.00, 500.00),
((SELECT productID FROM Products WHERE productName = 'Settlers of Catan'),
    2, 4, 25.00, 100.00),
((SELECT productID FROM Products WHERE productName = 'Pokemon Evolutions Booster'),
    3, 20, 2.50, 50.00),
((SELECT productID FROM Products WHERE productName = 'Mario Kart'),
    4, 2, 40.00, 80.00),
((SELECT productID FROM Products WHERE productName = 'Pokemon Evolutions Booster'),
    4, 4, 2.50, 10.00),
((SELECT productID FROM Products WHERE productName = 'PS5 Dualshock Controller'),
    4, 2, 60.00, 120.00),
((SELECT productID FROM Products WHERE productName = 'Settlers of Catan'),
    4, 3, 30.00, 90.00);


-- Re-enable foreign key checks and commit-
SET FOREIGN_KEY_CHECKS=1;
COMMIT;