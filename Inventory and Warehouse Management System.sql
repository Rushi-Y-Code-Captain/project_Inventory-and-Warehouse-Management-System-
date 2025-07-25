-- creating table 

-- Products

CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Description TEXT,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    ReorderLevel INT DEFAULT 10
);

-- Warehouses

CREATE TABLE Warehouses (
    WarehouseID INT AUTO_INCREMENT PRIMARY KEY,
    WarehouseName VARCHAR(100) NOT NULL,
    Location VARCHAR(100)
);

-- Suppliers

CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactPerson VARCHAR(100),
    Phone VARCHAR(20),
    Email VARCHAR(100)
);

-- junction table: Product x Warehouse

CREATE TABLE Stock (
    StockID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    WarehouseID INT,
    Quantity INT DEFAULT 0,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
);


-- data insertion 

INSERT INTO Products (ProductName, Description, UnitPrice, ReorderLevel) VALUES
('Laptop', '15-inch business laptop', 55000.00, 5),
('Wireless Mouse', 'Bluetooth mouse with ergonomic design', 1200.00, 15),
('Keyboard', 'Mechanical keyboard with backlight', 2500.00, 10),
('Monitor', '24-inch full HD monitor', 8500.00, 8);

INSERT INTO Warehouses (WarehouseName, Location) VALUES
('Central Warehouse', 'Mumbai'),
('East Hub', 'Kolkata'),
('North Depot', 'Delhi');

INSERT INTO Suppliers (SupplierName, ContactPerson, Phone, Email) VALUES
('TechSupply Co.', 'Amit Sharma', '9876543210', 'amit@techsupply.com'),
('GadgetMart Ltd.', 'Priya Mehta', '9123456780', 'priya@gadgetmart.com'),
('CompuWorld', 'Rajeev Sinha', '9988776655', 'rajeev@compuworld.com');


INSERT INTO Stock (ProductID, WarehouseID, Quantity) VALUES
(1, 1, 20),  -- Laptops in Mumbai
(2, 1, 50),  -- Mice in Mumbai
(3, 2, 30),  -- Keyboards in Kolkata
(4, 3, 15),  -- Monitors in Delhi
(1, 2, 5),   -- Laptops in Kolkata (low stock)
(2, 3, 8);   -- Mice in Delhi (low stock)

-- Check Current Stock Levels

SELECT 
    P.ProductName,
    W.WarehouseName,
    S.Quantity
FROM 
    Stock S
JOIN Products P ON S.ProductID = P.ProductID
JOIN Warehouses W ON S.WarehouseID = W.WarehouseID;

-- Products Below Reorder Level

SELECT 
    P.ProductName,
    W.WarehouseName,
    S.Quantity,
    P.ReorderLevel
FROM 
    Stock S
JOIN Products P ON S.ProductID = P.ProductID
JOIN Warehouses W ON S.WarehouseID = W.WarehouseID
WHERE 
    S.Quantity < P.ReorderLevel;

-- Total Stock of Each Product Across All Warehouses

SELECT 
    P.ProductName,
    SUM(S.Quantity) AS TotalQuantity
FROM 
    Stock S
JOIN Products P ON S.ProductID = P.ProductID
GROUP BY 
    P.ProductName;

-- Create Alert Log Table

CREATE TABLE LowStockAlerts (
    AlertID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    WarehouseID INT,
    Quantity INT,
    AlertTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
);

-- Create Trigger After Stock Update

DELIMITER $$

CREATE TRIGGER trg_LowStockAlert
AFTER UPDATE ON Stock
FOR EACH ROW
BEGIN
    DECLARE reorderLvl INT;

    -- Get the reorder level from Products table
    SELECT ReorderLevel INTO reorderLvl
    FROM Products
    WHERE ProductID = NEW.ProductID;

    -- If quantity goes below reorder level, log it
    IF NEW.Quantity < reorderLvl THEN
        INSERT INTO LowStockAlerts (ProductID, WarehouseID, Quantity)
        VALUES (NEW.ProductID, NEW.WarehouseID, NEW.Quantity);
    END IF;
END$$

DELIMITER ;

-- Stored Procedure: TransferStock

DELIMITER $$

CREATE PROCEDURE TransferStock (
    IN p_ProductID INT,
    IN p_FromWarehouseID INT,
    IN p_ToWarehouseID INT,
    IN p_Quantity INT
)
BEGIN
    DECLARE currentQty INT;

    -- Check if enough stock is available in source warehouse
    SELECT Quantity INTO currentQty
    FROM Stock
    WHERE ProductID = p_ProductID AND WarehouseID = p_FromWarehouseID;

    IF currentQty IS NULL OR currentQty < p_Quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock in source warehouse.';
    ELSE
        -- Deduct from source warehouse
        UPDATE Stock
        SET Quantity = Quantity - p_Quantity
        WHERE ProductID = p_ProductID AND WarehouseID = p_FromWarehouseID;

        -- Add to destination warehouse
        INSERT INTO Stock (ProductID, WarehouseID, Quantity)
        VALUES (p_ProductID, p_ToWarehouseID, p_Quantity)
        ON DUPLICATE KEY UPDATE Quantity = Quantity + p_Quantity;
    END IF;
END$$

DELIMITER ;


CALL TransferStock(1, 1, 2, 5);  
-- Transfer 5 units of ProductID=1 from Warehouse 1 to Warehouse 2
