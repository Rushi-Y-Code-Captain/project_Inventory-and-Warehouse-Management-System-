
#  Inventory and Warehouse Management System

##  Project Overview

This project is a mini SQL-based backend system designed to manage inventory across multiple warehouses. It provides functionality for tracking stock levels, monitoring low-stock alerts, and transferring stock between locations using SQL features like triggers and stored procedures.

---

##  Objective

To build a normalized SQL schema and implement backend logic to:
- Track product inventory across warehouses
- Trigger low-stock alerts
- Support inventory transfer between warehouses

---

##  Tools Used

- **MySQL** – Core SQL development and backend database
- **DBeaver** – GUI for SQL management and testing
- **SQL** – Triggers, queries, procedures

---

##  Database Schema

**Tables Created:**
- `Products`: Stores product details and reorder levels  
- `Suppliers`: Stores supplier contact info  
- `Warehouses`: Stores warehouse names and locations  
- `Stock`: Junction table linking products and warehouses with quantity  
- `LowStockAlerts`: Stores log of triggered alerts when stock is low

---

## ⚙ Features Implemented

###  Sample Data
Pre-loaded sample entries for Products, Suppliers, Warehouses, and Stock for testing.

###  SQL Queries
- Current stock level by product and warehouse  
- Products below reorder level (reorder alert)  
- Total stock per product across all warehouses

###  Trigger
- **`trg_LowStockAlert`**: Logs alert if stock falls below the defined reorder level after update

###  Stored Procedure
- **`TransferStock`**: Transfers stock from one warehouse to another with quantity validation

---

##  Project Deliverables

- `inventory_project.sql`: Complete SQL script with tables, sample data, queries, triggers, and procedures
- `project_report.pdf`: 1–2 page summary report
- `README.md`: This file (project summary and guide)
- `DFD.png`: Level 0 & Level 1 Data Flow Diagrams (optional)

---

##  How to Run

1. Import `inventory_project.sql` into MySQL or DBeaver  
2. Run the script to create tables, triggers, procedures, and sample data  
3. Test using provided queries and procedure calls

---



