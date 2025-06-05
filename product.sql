-- ========================================
-- Видалення таблиць (якщо існують)
-- ========================================
DROP TABLE IF EXISTS WriteOffs CASCADE;
DROP TABLE IF EXISTS Payments CASCADE;
DROP TABLE IF EXISTS TransactionDetails CASCADE;
DROP TABLE IF EXISTS Transactions CASCADE;
DROP TABLE IF EXISTS ProductSuppliers CASCADE;
DROP TABLE IF EXISTS PaymentsCustomers CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS Suppliers CASCADE;
DROP TABLE IF EXISTS Products CASCADE;

-- ========================================
-- Видалення ENUM типів (якщо існують)
-- ========================================
DROP TYPE IF EXISTS transaction_type CASCADE;
DROP TYPE IF EXISTS payment_type CASCADE;

-- ========================================
-- Створення ENUM типів для полів Type
-- ========================================
CREATE TYPE transaction_type AS ENUM ('Purchase', 'Sale', 'Write-off');
CREATE TYPE payment_type AS ENUM ('Incoming', 'Outgoing');

-- ========================================
-- Створення таблиць
-- ========================================
CREATE TABLE Products (
  ProductID SERIAL PRIMARY KEY,
  Name VARCHAR(255) NOT NULL,
  Category VARCHAR(255),
  Unit VARCHAR(50),
  ExpiryDate DATE,
  PurchasePrice NUMERIC(10,2),
  SalePrice NUMERIC(10,2),
  StockQuantity INTEGER
);

CREATE TABLE Suppliers (
  SupplierID SERIAL PRIMARY KEY,
  Name VARCHAR(255) NOT NULL,
  Address TEXT,
  Discount NUMERIC(5,2)
);

CREATE TABLE Customers (
  CustomerID SERIAL PRIMARY KEY,
  Name VARCHAR(255) NOT NULL,
  Category VARCHAR(100),
  Address TEXT,
  Discount NUMERIC(5,2),
  Balance NUMERIC(10,2)
);

CREATE TABLE ProductSuppliers (
  ProductSuppliersID SERIAL PRIMARY KEY,
  ProductID INTEGER REFERENCES Products(ProductID),
  SupplierID INTEGER REFERENCES Suppliers(SupplierID),
  PurchasePrice NUMERIC(10,2),
  Amount INTEGER
);

CREATE TABLE Transactions (
  TransactionID SERIAL PRIMARY KEY,
  Date DATE NOT NULL,
  CustomerID INTEGER REFERENCES Customers(CustomerID),
  Type transaction_type NOT NULL
);

CREATE TABLE TransactionDetails (
  TransactionDetailsID SERIAL PRIMARY KEY,
  TransactionID INTEGER REFERENCES Transactions(TransactionID),
  ProductID INTEGER REFERENCES Products(ProductID),
  Quantity INTEGER,
  PurchasePrice NUMERIC(10,2),
  SalePrice NUMERIC(10,2)
);

CREATE TABLE Payments (
  PaymentID SERIAL PRIMARY KEY,
  SupplierID INTEGER REFERENCES Suppliers(SupplierID),
  Balance NUMERIC(10,2),
  Amount NUMERIC(10,2),
  Date DATE NOT NULL,
  Type payment_type NOT NULL
);

CREATE TABLE WriteOffs (
  WriteOffID SERIAL PRIMARY KEY,
  ProductID INTEGER REFERENCES Products(ProductID),
  Count INTEGER,
  Date DATE NOT NULL
);

-- Створення таблиці PaymentsCustomers для платежів покупців
CREATE TABLE PaymentsCustomers (
  PaymentID SERIAL PRIMARY KEY,
  CustomerID INTEGER REFERENCES Customers(CustomerID),
  Amount NUMERIC(10,2) NOT NULL,
  Date DATE NOT NULL,
  Type payment_type NOT NULL
);

-- ========================================
-- Додавання тестових даних
-- ========================================
INSERT INTO Products (Name, Category, Unit, ExpiryDate, PurchasePrice, SalePrice, StockQuantity) VALUES
('Молоко', 'Напої', 'л', '2025-04-01', 15.50, 22.00, 100),
('Хліб', 'Випічка', 'шт', '2025-03-15', 10.00, 15.00, 50),
('Вода', 'Напої', 'л', '2025-06-01', 12.00, 18.00, 20),
('Сир', 'Молочні продукти', 'кг', '2025-04-10', 50.00, 70.00, 5);



INSERT INTO Suppliers (Name, Address, Discount) VALUES
('ТОВ Постачальник 1', 'м. Київ, вул. Перемоги, 1', 5.00),
('ТОВ Постачальник 2', 'м. Львів, вул. Франка, 10', 7.00),
('ТОВ Постачальник 3', 'м. Одеса, вул. Дерибасівська, 20', 10.00);

INSERT INTO Customers (Name, Category, Address, Discount, Balance) VALUES
('ТОВ Покупець 1', 'Оптовий', 'м. Харків, вул. Шевченка, 12', 10.00, 1500.00),
('ТОВ Покупець 2', 'Роздрібний', 'м. Одеса, вул. Дерибасівська, 5', 5.00, 500.00),
('ТОВ Покупець 3', 'Оптовий', 'м. Київ, вул. Грушевського, 20', 15.00, 0.00);

INSERT INTO ProductSuppliers (ProductID, SupplierID, PurchasePrice, Amount) VALUES
(1, 1, 14.00, 200),
(2, 2, 9.00, 300),
(3, 3, 10.00, 500),
(4, 1, 45.00, 100);

INSERT INTO Transactions (Date, CustomerID, Type) VALUES
('2025-04-13', 1, 'Sale'),
('2025-03-12', NULL, 'Purchase'),
('2025-03-14', 2, 'Sale');



INSERT INTO TransactionDetails (TransactionID, ProductID, Quantity, PurchasePrice, SalePrice)
VALUES (1, 1, 3, 10.00, 15.00);


INSERT INTO Payments (SupplierID, Balance, Amount, Date, Type)
VALUES
(1, 1000.00, 500.00, '2025-02-10', 'Outgoing'),
(2, 300.00, 200.00, '2025-02-15', 'Outgoing'),
(3, 0.00, 700.00, '2025-02-20', 'Outgoing');

INSERT INTO PaymentsCustomers (CustomerID, Amount, Date, Type) VALUES
(1, 500.00, '2025-04-10', 'Incoming'),
(2, 200.00, '2025-04-12', 'Incoming'),
(3, 700.00, '2025-04-11', 'Incoming');

INSERT INTO WriteOffs (ProductID, Count, Date) VALUES
(1, 3, '2025-03-05'),
(4, 1, '2025-03-15');

-- ========================================
-- Запити (тестові)
-- ========================================

-- 1. Вибірка всіх продуктів з категорії "Напої"
SELECT * FROM Products WHERE Category = 'Напої';

-- 2. Вибірка постачальників, які мають знижку більше 5%
SELECT * FROM Suppliers WHERE Discount > 5.00;

-- 3. Додавання нового покупця
INSERT INTO Customers (Name, Category, Address, Discount, Balance)
VALUES ('ТОВ Новий Покупець', 'Оптовий', 'м. Київ, вул. Грушевського, 20', 8.00, 0.00);

-- 4. Оновлення кількості товару в складі (додаємо 50 одиниць для продукту з ID = 1)
UPDATE Products
SET StockQuantity = StockQuantity + 50
WHERE ProductID = 1;

-- 5. Видалення постачальника з SupplierID = 2, якщо немає залежностей
DELETE FROM Suppliers
WHERE SupplierID = 2
AND SupplierID NOT IN (SELECT SupplierID FROM Payments WHERE SupplierID = 2)
AND SupplierID NOT IN (SELECT SupplierID FROM ProductSuppliers WHERE SupplierID = 2);

-- 6. Вибірка продуктів, де кількість на складі менша за 10 одиниць
SELECT ProductID, Name, StockQuantity
FROM Products
WHERE StockQuantity < 10;

-- 7. Вибірка товарів з постачальниками та цінами закупки
SELECT
  p.ProductID,
  p.Name AS ProductName,
  s.Name AS SupplierName,
  ps.PurchasePrice,
  ps.Amount
FROM ProductSuppliers ps
JOIN Products p ON ps.ProductID = p.ProductID
JOIN Suppliers s ON ps.SupplierID = s.SupplierID;

-- 8. Історія продажів за останні 30 днів
SELECT
  t.TransactionID,
  t.Date,
  c.Name AS CustomerName,
  td.ProductID,
  p.Name AS ProductName,
  td.Quantity,
  td.SalePrice
FROM Transactions t
JOIN TransactionDetails td ON t.TransactionID = td.TransactionID
JOIN Customers c ON t.CustomerID = c.CustomerID
JOIN Products p ON td.ProductID = p.ProductID
WHERE t.Type = 'Sale'
AND t.Date >= CURRENT_DATE - INTERVAL '30 days';

-- 9. Вибірка списаних товарів
SELECT
  w.WriteOffID,
  p.Name AS ProductName,
  w.Count AS Quantity,
  w.Date
FROM WriteOffs w
JOIN Products p ON w.ProductID = p.ProductID;

-- 10. Додавання нової транзакції продажу
INSERT INTO Transactions (Date, CustomerID, Type)
VALUES ('2025-03-13', 2, 'Sale');

INSERT INTO TransactionDetails (TransactionID, ProductID, Quantity, PurchasePrice, SalePrice)
VALUES
(3, 1, 20, 15.00, 22.00);

UPDATE Products
SET StockQuantity = StockQuantity - 20
WHERE ProductID = 1;

-- 11. Вибірка покупців з боргом більше ніж 1000
SELECT *
FROM Customers
WHERE Balance > 1000.00;

-- 12. Вибірка платежів по постачальниках за лютий 2025

SELECT
  s.Name AS SupplierName,
  SUM(p.Amount) AS TotalPaid
FROM Payments p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE p.Date::date BETWEEN '2025-02-01' AND '2025-02-28'
AND p.Type = 'Outgoing'
GROUP BY s.Name;




-- 13. Вибірка постачальників, які постачають більше ніж 100 товарів
SELECT
  s.SupplierID,
  s.Name AS SupplierName,
  SUM(ps.Amount) AS TotalSupplied
FROM ProductSuppliers ps
JOIN Suppliers s ON ps.SupplierID = s.SupplierID
GROUP BY s.SupplierID
HAVING SUM(ps.Amount) > 100;

-- 14. Вибірка продуктів, термін придатності яких минув
SELECT
  ProductID,
  Name,
  ExpiryDate
FROM Products
WHERE ExpiryDate < CURRENT_DATE;

-- 15. Вибірка продуктів, назви яких починаються з літери "М" (LIKE)
SELECT * FROM Products WHERE Name LIKE 'М%';

-- 16. Вибірка продуктів, термін придатності яких знаходиться між двома датами (BETWEEN)
SELECT * FROM Products WHERE ExpiryDate BETWEEN '2025-03-01' AND '2025-06-01';

-- 17. Вибірка продуктів, які належать до певних категорій (IN)
SELECT * FROM Products WHERE Category IN ('Напої', 'Випічка');

-- 18. Вибірка покупців, у яких є транзакції (EXISTS)
SELECT * FROM Customers c
WHERE EXISTS (SELECT 1 FROM Transactions t WHERE t.CustomerID = c.CustomerID);

-- 19. Вибірка продуктів, чия кількість на складі більше за всі значення в іншій таблиці (ALL)
SELECT * FROM Products p
WHERE StockQuantity > ALL (SELECT Amount FROM ProductSuppliers);

-- 20. Вибірка продуктів, чия кількість на складі більше ніж будь-яке значення в іншій таблиці (ANY)
SELECT * FROM Products p
WHERE StockQuantity > ANY (SELECT Amount FROM ProductSuppliers);

-- 21. Ієрархічний SELECT-запит для вибірки продуктів категорії "Напої"
WITH RECURSIVE ProductHierarchy AS (
  SELECT ProductID, Name, Category, 1 AS Level
  FROM Products
  WHERE Category = 'Напої'
  UNION ALL
  SELECT p.ProductID, p.Name, p.Category, ph.Level + 1
  FROM Products p
  JOIN ProductHierarchy ph ON p.Category = ph.Category
)
SELECT * FROM ProductHierarchy;

-- 22. CrossTab-запит для отримання інформації про кількість постачань від кожного постачальника
SELECT
  p.Name AS ProductName,
  SUM(CASE WHEN ps.SupplierID = 1 THEN ps.Amount ELSE 0 END) AS Supplier1Amount,
  SUM(CASE WHEN ps.SupplierID = 2 THEN ps.Amount ELSE 0 END) AS Supplier2Amount
FROM ProductSuppliers ps
JOIN Products p ON ps.ProductID = p.ProductID
GROUP BY p.Name;

SELECT
    p.Name AS ProductName,
    p.PurchasePrice,
    p.SalePrice,
    p.StockQuantity
FROM Products p
WHERE p.Category = 'Напої';  -- Замініть 'Напої' на будь-яку категорію
--Список обігу товарів за певний період часу
SELECT --Список обігу товарів за певний період часу з вказанням назви, суми товару наявного на початок періоду, суми приходу товару за період, суми продажу та списання товару за період, суми
    p.Name AS ProductName,
    p.Category,
    p.StockQuantity AS BeginningQuantity,
    COALESCE(SUM(CASE WHEN t.Type = 'Purchase' THEN td.Quantity ELSE 0 END), 0) AS PurchaseQuantity,
    COALESCE(SUM(CASE WHEN t.Type = 'Sale' THEN td.Quantity ELSE 0 END), 0) AS SaleQuantity,
    COALESCE(SUM(CASE WHEN t.Type = 'Write-off' THEN td.Quantity ELSE 0 END), 0) AS WriteOffQuantity,
    (p.StockQuantity + COALESCE(SUM(CASE WHEN t.Type = 'Purchase' THEN td.Quantity ELSE 0 END), 0) -
     COALESCE(SUM(CASE WHEN t.Type = 'Sale' THEN td.Quantity ELSE 0 END), 0) -
     COALESCE(SUM(CASE WHEN t.Type = 'Write-off' THEN td.Quantity ELSE 0 END), 0)) AS EndingQuantity
FROM Products p
JOIN TransactionDetails td ON p.ProductID = td.ProductID
JOIN Transactions t ON td.TransactionID = t.TransactionID
WHERE t.Date BETWEEN '2025-03-01' AND '2025-03-31'  --  відповідний період
GROUP BY p.Name, p.Category, p.StockQuantity
ORDER BY p.Category, p.Name;
--Список постачальників з вказанням всіх даних документів про прихід товару від них
SELECT
    s.Name AS SupplierName,
    s.Address,
    s.Discount,
    p.Name AS ProductName,
    ps.PurchasePrice,
    ps.Amount AS ProductAmount,
    ps.PurchasePrice * ps.Amount AS TotalPurchasePrice,
    ps.ProductID,
    ps.SupplierID
FROM ProductSuppliers ps
JOIN Suppliers s ON ps.SupplierID = s.SupplierID
JOIN Products p ON ps.ProductID = p.ProductID
ORDER BY s.Name, p.Name;

-- 23. Оновлення кількості товарів в таблиці Products та в таблиці ProductSuppliers
UPDATE Products
SET StockQuantity = StockQuantity - 10
WHERE ProductID = 1;

UPDATE ProductSuppliers
SET Amount = Amount - 10
WHERE ProductID = 1;

-- 24. Додавання записів з інших таблиць (копіюємо покупців до тієї ж таблиці)
INSERT INTO Customers (Name, Category, Address, Discount, Balance)
SELECT Name, Category, Address, Discount, Balance FROM Customers;

-- 25. Видалення всіх записів з таблиці ProductSuppliers (видалення обмеження на зовнішній ключ)
ALTER TABLE ProductSuppliers
  DROP CONSTRAINT productsuppliers_productid_fkey;

ALTER TABLE ProductSuppliers
  ADD CONSTRAINT productsuppliers_productid_fkey
  FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE;

-- 26. Видалення вибраних записів з таблиці PaymentsCustomers (видалення обмеження на зовнішній ключ)
ALTER TABLE PaymentsCustomers
  DROP CONSTRAINT paymentscustomers_customerid_fkey;

ALTER TABLE PaymentsCustomers
  ADD CONSTRAINT paymentscustomers_customerid_fkey
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE;


-----------
-- Видалення існуючої процедури (якщо така є)
DROP PROCEDURE IF EXISTS calculatepaymentforcustomer(integer, date);

-- Оголошення процедури для нарахування оплати для одного покупця
CREATE OR REPLACE PROCEDURE CalculatePaymentForCustomer(
    p_customer_id INT,  -- Ідентифікатор покупця
    p_month DATE        -- Місяць для якого потрібно нарахувати оплату
)
LANGUAGE plpgsql
AS $$
DECLARE
    total_amount NUMERIC := 0;  -- Змінна для збереження обчисленої суми
BEGIN
    -- Підрахунок суми всіх продажів для покупця за вказаний місяць
    SELECT COALESCE(SUM(td.Quantity * td.SalePrice), 0)  -- Використовуємо COALESCE, щоб уникнути NULL, якщо не знайдено результатів
    INTO total_amount
    FROM Transactions t
    JOIN TransactionDetails td ON t.TransactionID = td.TransactionID  -- Об'єднуємо таблиці транзакцій
    WHERE t.CustomerID = p_customer_id  -- Фільтруємо лише за покупцем
      AND t.Type = 'Sale'  -- Беремо лише транзакції типу "Sale"
      AND t.Date >= date_trunc('month', p_month)  -- Вибираємо всі транзакції починаючи з першого дня місяця
      AND t.Date < date_trunc('month', p_month) + INTERVAL '1 month';  -- Обмежуємо до кінця місяця

    -- Якщо сума більша за 0, оновлюємо баланс і додаємо запис про платіж
    IF total_amount > 0 THEN
        -- Оновлення балансу покупця
        UPDATE Customers
        SET Balance = Balance - total_amount
        WHERE CustomerID = p_customer_id;

        -- Вставка записи про платіж покупця
        INSERT INTO PaymentsCustomers (CustomerID, Amount, Date, Type)
        VALUES (p_customer_id, total_amount, CURRENT_DATE, 'Outgoing');

        -- Виведення повідомлення для підтвердження операції
        RAISE NOTICE 'Оплата нарахована для покупця ID: %, сума: %', p_customer_id, total_amount;
    ELSE
        -- Якщо сума = 0, виводимо попередження
        RAISE NOTICE 'Немає продажів для покупця ID: %, оплата не нарахована', p_customer_id;
    END IF;
END;
$$;

-- Оголошення процедури для нарахування оплат для всіх покупців за певний місяць
CREATE OR REPLACE PROCEDURE CalculatePaymentForAllCustomers(
    p_month DATE  -- Місяць для якого потрібно нарахувати оплату
)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;  -- Змінна для зберігання ідентифікатора кожного покупця
BEGIN
    -- Цикл по всіх покупцях
    FOR rec IN SELECT CustomerID FROM Customers
    LOOP
        -- Виклик процедури для кожного покупця через CALL
        CALL CalculatePaymentForCustomer(rec.CustomerID, p_month);
    END LOOP;

    -- Підтвердження нарахування оплат для всіх покупців
    RAISE NOTICE 'Оплати нараховані для всіх покупців за місяць: %', p_month;
END;
$$;

-- Виклик процедури для нарахування оплат за квітень 2025 року
CALL CalculatePaymentForAllCustomers('2025-04-01');

-- Перегляд змін у таблицях Customers і PaymentsCustomers
SELECT * FROM Customers;
SELECT * FROM PaymentsCustomers;



-------лаб 4---
-- Додаємо службові поля
ALTER TABLE Products ADD COLUMN UCR TEXT, ADD COLUMN DCR TIMESTAMP, ADD COLUMN ULC TEXT, ADD COLUMN DLC TIMESTAMP;
ALTER TABLE Suppliers ADD COLUMN UCR TEXT, ADD COLUMN DCR TIMESTAMP, ADD COLUMN ULC TEXT, ADD COLUMN DLC TIMESTAMP;
ALTER TABLE Customers ADD COLUMN UCR TEXT, ADD COLUMN DCR TIMESTAMP, ADD COLUMN ULC TEXT, ADD COLUMN DLC TIMESTAMP;
ALTER TABLE ProductSuppliers ADD COLUMN UCR TEXT, ADD COLUMN DCR TIMESTAMP, ADD COLUMN ULC TEXT, ADD COLUMN DLC TIMESTAMP;
ALTER TABLE Transactions ADD COLUMN UCR TEXT, ADD COLUMN DCR TIMESTAMP, ADD COLUMN ULC TEXT, ADD COLUMN DLC TIMESTAMP;
ALTER TABLE TransactionDetails ADD COLUMN UCR TEXT, ADD COLUMN DCR TIMESTAMP, ADD COLUMN ULC TEXT, ADD COLUMN DLC TIMESTAMP;
ALTER TABLE Payments ADD COLUMN UCR TEXT, ADD COLUMN DCR TIMESTAMP, ADD COLUMN ULC TEXT, ADD COLUMN DLC TIMESTAMP;
ALTER TABLE WriteOffs ADD COLUMN UCR TEXT, ADD COLUMN DCR TIMESTAMP, ADD COLUMN ULC TEXT, ADD COLUMN DLC TIMESTAMP;
ALTER TABLE PaymentsCustomers ADD COLUMN UCR TEXT, ADD COLUMN DCR TIMESTAMP, ADD COLUMN ULC TEXT, ADD COLUMN DLC TIMESTAMP;
CREATE OR REPLACE FUNCTION set_audit_fields()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.DCR := now();-- дата створення
    NEW.UCR := current_user;-- користувач, який створив
    NEW.DLC := now();-- дата останньої зміни
    NEW.ULC := current_user;-- користувач, який останнім змінив
  ELSIF TG_OP = 'UPDATE' THEN
    NEW.DLC := now(); -- дата останньої зміни
    NEW.ULC := current_user; -- користувач, який останнім змінив
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Створення тригерів
CREATE TRIGGER trg_products_audit BEFORE INSERT OR UPDATE ON Products FOR EACH ROW EXECUTE FUNCTION set_audit_fields();
CREATE TRIGGER trg_suppliers_audit BEFORE INSERT OR UPDATE ON Suppliers FOR EACH ROW EXECUTE FUNCTION set_audit_fields();
CREATE TRIGGER trg_customers_audit BEFORE INSERT OR UPDATE ON Customers FOR EACH ROW EXECUTE FUNCTION set_audit_fields();
CREATE TRIGGER trg_productsuppliers_audit BEFORE INSERT OR UPDATE ON ProductSuppliers FOR EACH ROW EXECUTE FUNCTION set_audit_fields();
CREATE TRIGGER trg_transactions_audit BEFORE INSERT OR UPDATE ON Transactions FOR EACH ROW EXECUTE FUNCTION set_audit_fields();
CREATE TRIGGER trg_transactiondetails_audit BEFORE INSERT OR UPDATE ON TransactionDetails FOR EACH ROW EXECUTE FUNCTION set_audit_fields();
CREATE TRIGGER trg_payments_audit BEFORE INSERT OR UPDATE ON Payments FOR EACH ROW EXECUTE FUNCTION set_audit_fields();
CREATE TRIGGER trg_writeoffs_audit BEFORE INSERT OR UPDATE ON WriteOffs FOR EACH ROW EXECUTE FUNCTION set_audit_fields();
CREATE TRIGGER trg_paymentscustomers_audit BEFORE INSERT OR UPDATE ON PaymentsCustomers FOR EACH ROW EXECUTE FUNCTION set_audit_fields();
-- Створюємо послідовність для сурогатного ключа
CREATE SEQUENCE inventory_log_seq START 1000;---Встановлює, що перше значення послідовності буде 1000, а не стандартне 1.


-- Створюємо таблицю
CREATE TABLE InventoryLogs (----зберігає історію змін кількості товару на складі
  LogID INTEGER PRIMARY KEY DEFAULT nextval('inventory_log_seq'),
  ProductID INTEGER REFERENCES Products(ProductID),
  ChangeType VARCHAR(50),  -- 'income', 'sale', 'write_off'
  QuantityChange INTEGER,  -- додатнє або від’ємне значення
  LogDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION trg_inventorylogs_logid_filler()-----Ця функція створює тригерну логіку
-- для автоматичного заповнення поля LogID, якщо його не вказано вручну
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.LogID IS NULL THEN----Якщо поле LogID у новому записі (який вставляється або оновлюється) не заповнене (тобто NULL)
    NEW.LogID := nextval('inventory_log_seq');------то функція призначає наступне значення з послідовності inventory_log_seq.
----Це і є сурогатний ключ, який автоматично зростає.
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inventorylogs_logid-----Ця функція перевіряє, чи поле LogID не заповнене,
-- і якщо так — призначає йому значення з послідовності inventory_log_seq.
BEFORE INSERT ON InventoryLogs
FOR EACH ROW
EXECUTE FUNCTION trg_inventorylogs_logid_filler();
------
INSERT INTO InventoryLogs (ProductID, ChangeType, QuantityChange)
VALUES (1, 'sale', -5);

INSERT INTO InventoryLogs (ProductID, ChangeType, QuantityChange)
VALUES (1, 'income', 10);

INSERT INTO InventoryLogs (ProductID, ChangeType, QuantityChange, LogID)
VALUES (2, 'write_off', -2, NULL);

SELECT * FROM InventoryLogs;----В подивитися поточний стан логів
CREATE OR REPLACE FUNCTION check_stock_before_sale()
RETURNS TRIGGER AS $$
DECLARE-----Оголошення змінної current_stock типу INTEGER
  current_stock INTEGER;
BEGIN
  SELECT StockQuantity INTO current_stock
  FROM Products
  WHERE ProductID = NEW.ProductID;

  IF NEW.Quantity > current_stock THEN----Перевіряємо, чи кількість товару у новому записі (продажі) більша, ніж залишок на складі
    RAISE EXCEPTION 'Недостатньо товару на складі. Доступно: %, потрібно: %',
      current_stock, NEW.Quantity;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_check_stock_before_sale---перевірка залишку товару перед продажем
BEFORE INSERT ON TransactionDetails
FOR EACH ROW
EXECUTE FUNCTION check_stock_before_sale();
CREATE OR REPLACE FUNCTION update_stock_after_sale()----ця функція оновлює запас товару на складі,
-- віднімаючи продану кількість після успішної операції продажу
RETURNS TRIGGER AS $$
BEGIN
  UPDATE Products
  SET StockQuantity = StockQuantity - NEW.Quantity ----віднімаємо кількість товару, що була продана (NEW.Quantity)
  WHERE ProductID = NEW.ProductID;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stock_after_sale
AFTER INSERT ON TransactionDetails---Цей тригер спрацьовує після вставки (AFTER INSERT) нового рядка в таблицю TransactionDetails
FOR EACH ROW
EXECUTE FUNCTION update_stock_after_sale();

-------тест----
SELECT Name, UCR, DCR, ULC, DLC FROM Products WHERE Name = 'Молоко';---Перевірка аудиту
UPDATE Products----Оновлення
SET SalePrice = 160
WHERE Name = 'Молоко';


SELECT ProductID, Name, StockQuantity FROM Products WHERE ProductID = 2;---Перевірка залишку на складі

INSERT INTO TransactionDetails (TransactionID, ProductID, Quantity, PurchasePrice, SalePrice)
VALUES (1, 2, 5, 100, 150);

---INSERT INTO TransactionDetails (TransactionID, ProductID, Quantity, PurchasePrice, SalePrice)
---VALUES (1, 1, 9999, 100, 150);-----тут має бути помилка бо кількість більша ніж є на складі

SELECT * FROM InventoryLogs WHERE ProductID = 1 ORDER BY LogDate DESC LIMIT 5;--- Перегляд історії змін складу



---------лаб 5
-- 1) Створення користувачів БД (LOGIN з паролями)
DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'admin_user') THEN
      CREATE ROLE admin_user WITH LOGIN PASSWORD 'admin_pass';
   END IF;
END
$$;

DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'sales_manager') THEN
      CREATE ROLE sales_manager WITH LOGIN PASSWORD 'sales_pass';
   END IF;
END
$$;

DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'accountant_user') THEN
      CREATE ROLE accountant_user WITH LOGIN PASSWORD 'accountant_pass';
   END IF;
END
$$;

DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'analyst_user') THEN
      CREATE ROLE analyst_user WITH LOGIN PASSWORD 'analyst_pass';
   END IF;
END
$$;

-- 2) Створення типових ролей без LOGIN
DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'admin_role') THEN
      CREATE ROLE admin_role NOLOGIN;
   END IF;

   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'sales_manager_role') THEN
      CREATE ROLE sales_manager_role NOLOGIN;
   END IF;

   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'accountant_role') THEN
      CREATE ROLE accountant_role NOLOGIN;
   END IF;

   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'analyst_role') THEN
      CREATE ROLE analyst_role NOLOGIN;
   END IF;
END
$$;

-- 3) Надання прав ролям

-- Адміністратор: повний контроль
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin_role;
GRANT USAGE, CREATE ON SCHEMA public TO admin_role;

-- Менеджер з продажу: читання, додавання, оновлення в ключових таблицях
GRANT USAGE ON SCHEMA public TO sales_manager_role;
GRANT SELECT, INSERT, UPDATE ON products, customers, transactions, transactiondetails TO sales_manager_role;

-- Бухгалтер: робота з платежами
GRANT USAGE ON SCHEMA public TO accountant_role;
GRANT SELECT, UPDATE ON payments, paymentscustomers TO accountant_role;

-- Аналітик: лише читання
GRANT USAGE ON SCHEMA public TO analyst_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst_role;

-- 4) Надання базових прав підключення користувачам
GRANT CONNECT ON DATABASE mydatabase TO admin_user;
GRANT CONNECT ON DATABASE mydatabase TO sales_manager;
GRANT CONNECT ON DATABASE mydatabase TO accountant_user;
GRANT CONNECT ON DATABASE mydatabase TO analyst_user;

-- 5) Призначення ролей користувачам
GRANT admin_role TO admin_user;
GRANT sales_manager_role TO sales_manager;
GRANT accountant_role TO accountant_user;
GRANT analyst_role TO analyst_user;

-- 6) Текстовий опис типових задач

-- Адміністратор (admin_user/admin_role):
/*
 - Повний контроль над базою даних: створення, змінення, видалення таблиць і об’єктів.
 - Управління доступами користувачів.
 - Резервне копіювання і відновлення.
 - Моніторинг безпеки та продуктивності.
*/

-- Менеджер з продажу (sales_manager/sales_manager_role):
/*
 - Введення і оновлення інформації про клієнтів, товари та замовлення.
 - Оновлення статусів замовлень.
 - Отримання звітів про продажі.
*/

-- Бухгалтер (accountant_user/accountant_role):
/*
 - Перегляд і оновлення фінансових транзакцій та платежів.
 - Формування фінансових звітів для керівництва.
*/

-- Аналітик (analyst_user/analyst_role):
/*
 - Виконання складних SELECT-запитів для аналізу даних.
 - Побудова звітів і виявлення трендів продажів.
 - Не має права змінювати дані.
*/


-- Типові задачі для ролей:

-- Адміністратор (admin_user/admin_role):
/*
  - Повний контроль над базою даних: створення, зміна, видалення об'єктів.
  - Управління доступом користувачів і ролей.
  - Резервне копіювання та відновлення.
  - Налаштування безпеки та продуктивності.
*/

-- Менеджер з продажу (sales_manager/sales_manager_role):
/*
  - Перегляд даних про товари, клієнтів, транзакції.
  - Додавання нових записів про клієнтів, товари та замовлення.
  - Оновлення даних про клієнтів і замовлення.
  - Формування звітів про продажі.
*/

-- Бухгалтер (accountant_user/accountant_role):
/*
  - Перегляд і оновлення фінансових транзакцій (платежі, звіти).
  - Перевірка і корекція даних про платежі.
  - Підготовка фінансової звітності для керівництва.
*/

-- Аналітик (analyst_user/analyst_role):
/*
  - Виконання складних SELECT-запитів для аналітики.
  - Побудова звітів і виявлення трендів продажів і фінансів.
  - Робота виключно з читанням даних (немає прав на зміну).
  - Підготовка даних для прийняття рішень керівництвом.
*/


-----тест
-- Перевірити наявність користувачів-----Фільтрує лише ті ролі, які мають імена:
SELECT rolname FROM pg_roles WHERE rolname IN ('admin_user','sales_manager','accountant_user','analyst_user');

-- Перевірити наявність ролей
SELECT rolname FROM pg_roles WHERE rolname IN ('admin_role','sales_manager_role','accountant_role','analyst_role');
-- Перевірити, які ролі належать користувачу admin_user
SELECT r.rolname AS role_name-- Вибираємо назву ролі, яку має користувач (буде показано як 'role_name')
FROM pg_roles r-- Таблиця з усіма ролями у PostgreSQL (роль, яка була призначена комусь)
JOIN pg_auth_members m ON r.oid = m.roleid-- З'єднуємо з таблицею членства в ролях, де зберігається хто є учасником якої ролі
JOIN pg_roles u ON u.oid = m.member-- Ще одне з'єднання з pg_roles, цього разу для користувача/члена ролі
WHERE u.rolname = 'admin_user';-- Фільтруємо лише ті записи, де ім’я користувача дорівнює 'admin_user'

SELECT r.rolname AS role_name
FROM pg_roles r
JOIN pg_auth_members m ON r.oid = m.roleid
JOIN pg_roles u ON u.oid = m.member
WHERE u.rolname = 'sales_manager';


/*
SELECT
    nspname AS schema_name,
    rolname AS grantee,
    has_schema_privilege(rolname, nspname, 'USAGE') AS has_usage,
    has_schema_privilege(rolname, nspname, 'CREATE') AS has_create
FROM pg_namespace
CROSS JOIN pg_roles
WHERE nspname = 'public' -- ім'я схеми
  AND rolname IN ('sales_manager_role', 'sales_manager'); -- ролі, які перевіряєш


SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('sales_manager_role', 'sales_manager')
ORDER BY table_name, privilege_type;


 */
-- Аналогічно для інших:
-- sales_manager, accountant_user, analyst_user
------
    /*
-- 1. Надаємо пряме право INSERT користувачу sales_manager
GRANT INSERT ON products TO sales_manager;
-- sales_manager тепер може додавати записи у таблицю products

-- 2. Активуємо роль sales_manager для тесту вставки
SET ROLE sales_manager;

-- 3. Пробуємо додати запис (успішно, бо є право INSERT)
INSERT INTO products (productid, name) VALUES (1004, 'Test Insert by sales_manager');

-- 4. Повертаємося до початкової ролі
RESET ROLE;


     */
-- 5. Перевіряємо які саме права має користувач sales_manager безпосередньо на products
---
/*
SELECT privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'sales_manager'
  AND table_name = 'products';
*/
/*
-- 6. Перевіряємо права ролі sales_manager_role (якщо така існує)
SELECT privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'sales_manager_role'
  AND table_name = 'products';


 */
-- 7. Забираємо право INSERT у користувача sales_manager
REVOKE INSERT ON products FROM sales_manager;
/*
-- 8. Перевіряємо права користувача sales_manager на таблицю products після відкликання INSERT
SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'sales_manager'
  AND table_name = 'products';

-- 9. Перевірка права UPDATE для користувача sales_manager (має або ні)
SELECT has_table_privilege('sales_manager', 'public.products', 'UPDATE');

-- 10. Активуємо роль sales_manager і пробуємо оновити запис
SET ROLE sales_manager;
UPDATE products SET name = 'Test update' WHERE productid = 1;
RESET ROLE;

-- 11. Перевірка, які ролі має користувач sales_user (щоб розуміти ієрархію)
SELECT r.rolname
FROM pg_roles r
JOIN pg_auth_members m ON r.oid = m.roleid
JOIN pg_roles u ON u.oid = m.member
WHERE u.rolname = 'sales_user';

-- 12. Перевірка права INSERT для користувача sales_manager (має або ні)
SELECT has_table_privilege('sales_manager', 'public.products', 'INSERT');
*/
-- 13. Відкликаємо роль sales_manager_role від користувача sales_manager
REVOKE sales_manager_role FROM sales_manager;
/*
-- 14. Перевіряємо залишкові права користувача sales_manager
SELECT grantee, privilege_type, table_name
FROM information_schema.role_table_grants
WHERE grantee = 'sales_manager';



-- 15. Пробуємо оновити запис у ролі sales_manager (якщо UPDATE залишився персонально, буде успіх)
SET ROLE sales_manager;
UPDATE products SET name = 'Update Test' WHERE productid = 2000;
RESET ROLE;


 */


-- Привілеї користувача
SELECT grantee, privilege_type, table_name
FROM information_schema.role_table_grants
WHERE grantee = 'sales_manager' AND table_name = 'products';

-- Привілеї ролей
SELECT grantee, privilege_type, table_name
FROM information_schema.role_table_grants
WHERE grantee IN (
    SELECT rolname
    FROM pg_roles
    WHERE pg_has_role('sales_manager', oid, 'member')
) AND table_name = 'products';
-- Наприклад, перевірка, чи є роль 'sales_manager_role' у користувача
SELECT pg_has_role('sales_manager', 'sales_manager_role', 'member') AS has_role;
SELECT has_table_privilege('sales_manager', 'public.products', 'INSERT') AS can_insert;
SELECT has_table_privilege('sales_manager', 'public.products', 'UPDATE') AS can_update;
  -----упевнемось що всі привілеї надані
GRANT sales_manager_role TO sales_manager;
GRANT INSERT, UPDATE ON products TO sales_manager_role;
GRANT INSERT ON products TO sales_manager;

    -- Перевірка прав перед відкликанням
SELECT grantee, privilege_type, table_name
FROM information_schema.role_table_grants
WHERE grantee IN ('sales_manager', 'sales_manager_role') AND table_name = 'products';

-- Відкликаємо пряме право INSERT у користувача
REVOKE INSERT ON products FROM sales_manager;

-- Перевіряємо чи користувач все ще має право INSERT (має через роль)
SELECT has_table_privilege('sales_manager', 'public.products', 'INSERT') AS can_insert;

-- Тут має бути TRUE, бо право є через роль

    -- Відкликаємо роль від користувача
REVOKE sales_manager_role FROM sales_manager;

-- Перевіряємо, чи користувач має право INSERT, яке було призначене персонально
SELECT has_table_privilege('sales_manager', 'public.products', 'INSERT') AS can_insert;

-- Перевіряємо права, які були лише через роль (наприклад, UPDATE)
SELECT has_table_privilege('sales_manager', 'public.products', 'UPDATE') AS can_update;
SELECT has_table_privilege('sales_manager', 'public.products', 'SELECT') AS can_update;---FALSE
-- Очікуємо: can_insert = TRUE, can_update = FALSE (бо UPDATE було лише через роль)

--------видалення користувача і його ролі
----відкликаємо всі привілеї надані напряму
-- Схема public
REVOKE ALL PRIVILEGES ON SCHEMA public FROM sales_manager_role;

-- Таблиці
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM sales_manager_role;

-- Секвенції (якщо вони є)
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM sales_manager_role;

-- Функції (якщо є)
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM sales_manager_role;
-----перевірка чи привілегій немає
SELECT grantee, privilege_type, table_name
FROM information_schema.role_table_grants
WHERE grantee = 'sales_manager_role';
----знову видаляємо привілегії надані напряму
-- Схема public
REVOKE ALL PRIVILEGES ON SCHEMA public FROM sales_manager;

-- Таблиці
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM sales_manager;

-- Секвенції
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM sales_manager;

-- Функції
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM sales_manager;

-- Підключення до бази
REVOKE CONNECT ON DATABASE mydatabase FROM sales_manager;


DROP ROLE IF EXISTS sales_manager_role;--------видаляємо роль
DROP ROLE IF EXISTS sales_manager;-------видаляємо користувача
-- Перевіримо, чи їх більше немає
SELECT rolname FROM pg_roles WHERE rolname IN ('sales_manager', 'sales_manager_role');

