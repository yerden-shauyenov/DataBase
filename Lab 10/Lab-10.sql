-- Task 1
BEGIN;
UPDATE accounts SET balance = balance - 100
	WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100
	WHERE name = 'Bob';
COMMIT;
--a) Alice: 900.00; Bob: 600.00
--b) These two UPDATES should be executed as a single unit to ensure atomicity.
--c) Without the transaction, the first UPDATE would have been saved to disk, and the second UPDATE would not have been executed. This would result in a loss of $100

-- Task 2
BEGIN;
UPDATE accounts SET balance = balance - 500.00
	WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';
--a) 400.00
--b) 900.00
--c) ROLLBACK is used for error handling, undoing user actions, maintaining data integrity, simultaneous operations, and testing.

-- Task 3
BEGIN;
UPDATE accounts SET balance = balance - 100.00
	WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
	WHERE name = 'Bob';
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
	WHERE name = 'Wally';
COMMIT;
--a) Alice: 800.00; Bob: 600.00; Wally: 850.00
--b) Yes, Bob's balance was temporarily increased to 700.00 after the first UPDATE, however, this UPDATE was cancelled using a ROLLBACK TO
--c) Saving resources, preserving context, flexibility, complex business logic, debugging

-- Task 4
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';

BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, products, price)
	VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;

SELECT * FROM products WHERE shop = 'Joe''s Shop';



BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM products WHERE shop = 'Joe''s Shop';

BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, products, price)
	VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;

SELECT * FROM products WHERE shop = 'Joe''s Shop';
--a) Before COMMIT Terminal 2: Terminal 1 sees the source data: Coke (2.50) and Pepsi (3.00)
--After COMMIT Terminal 2: Terminal 1 sees new data: Fanta only (3.50)
--b) In SERIALIZABLE mode, Terminal 1 sees the same data in both SELECT
--c) READ COMMITTED: Allows you to see the changes of other transactions immediately after their COMMIT.
--	 SERIALIZABLE: Ensures that all SELECTS in a transaction see the same data. Other transactions cannot change this data until the current transaction is completed.


-- Task 5
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';

BEGIN;
INSERT INTO products (shop, product, price)
 VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;

SELECT MAX(price), MIN(price) FROM products
 WHERE shop = 'Joe''s Shop';
COMMIT;
--a) No, Terminal 1 does not see the new Sprite product, even after Terminal 2 has committed the changes. In REPEATABLE READ mode, a transaction sees only the data that existed at the time it started.
--b) A phantom read is a situation where, within a single transaction, repeated execution of the same query returns a different number of rows.
--c) Only the SERIALIZABLE isolation level completely prevents phantom reads.


-- Task 6
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';

BEGIN;
UPDATE products SET price = 99.99
    WHERE product = 'Fanta';

SELECT * FROM products WHERE shop = 'Joe''s Shop';

ROLLBACK;

SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
--a) Yes, Terminal 1 saw the price of 99.99 in its second SELECT. This is problematic because it breaks the consistency of the data.
--b) Dirty read is the reading of uncommitted data from another transaction.
--c) Consistency issues, unpredictability, and debugging difficulties


-- Independent Exercises
-- Ex.1
UPDATE accounts SET balance = 500.00 WHERE name = 'Bob';
UPDATE accounts SET balance = 750.00 WHERE name = 'Wally';

BEGIN;
    SELECT balance FROM accounts WHERE name = 'Bob';
    IF (SELECT balance FROM accounts WHERE name = 'Bob') < 200.00 THEN
        RAISE NOTICE 'Недостаточно средств';
        ROLLBACK;
    ELSE
        UPDATE accounts SET balance = balance - 200.00 
        WHERE name = 'Bob';
        
        SAVEPOINT before_wally_update;
        
        UPDATE accounts SET balance = balance + 200.00 
        WHERE name = 'Wally';
        COMMIT;
    END IF;

SELECT * FROM accounts WHERE name IN ('Bob', 'Wally');

-- Ex.2
SELECT * FROM products ORDER BY id;

BEGIN;

    INSERT INTO products (shop, product, price) 
    VALUES ('My Shop', 'Coffee', 5.00);
    
    RAISE NOTICE '1. A new product has been inserted: Coffee for $5.00';
    SELECT * FROM products WHERE product = 'Coffee';

    SAVEPOINT after_insert;

    UPDATE products SET price = 6.50 
    WHERE product = 'Coffee';
    
    RAISE NOTICE '2. Updated price: Coffee is now for $6.50';
    SELECT * FROM products WHERE product = 'Coffee';

    SAVEPOINT after_update;

    DELETE FROM products 
    WHERE product = 'Coffee';
    
    RAISE NOTICE '3. The Coffee product has been removed';
    SELECT * FROM products WHERE product = 'Coffee';

    ROLLBACK TO after_insert;
    
    RAISE NOTICE '4. Rollback to the after_update point. Coffee должен быть с ценой $5.00';
    SELECT * FROM products WHERE product = 'Coffee';
    COMMIT;

RAISE NOTICE 'The final state of the products table:';
SELECT * FROM products ORDER BY id;

-- Ex.3
CREATE TABLE IF NOT EXISTS bank_account (
    account_id SERIAL PRIMARY KEY,
    account_holder VARCHAR(100),
    balance DECIMAL(10, 2)
);

TRUNCATE TABLE bank_account;
INSERT INTO bank_account (account_holder, balance) VALUES
    ('John Doe', 1000.00);

CREATE OR REPLACE FUNCTION withdraw_money(
    p_account_id INT,
    p_amount DECIMAL,
    p_wait_seconds INT DEFAULT 5
) RETURNS VARCHAR AS $$
DECLARE
    current_balance DECIMAL;
    result_message VARCHAR;
BEGIN
    PERFORM pg_sleep(p_wait_seconds);
    SELECT balance INTO current_balance 
    FROM bank_account 
    WHERE account_id = p_account_id;
    
    IF current_balance >= p_amount THEN
        UPDATE bank_account 
        SET balance = balance - p_amount 
        WHERE account_id = p_account_id;        
        result_message := 'Successfully withdrawn $' || p_amount || 
                         '. New balance: $' || (current_balance - p_amount);
    ELSE
        result_message := 'Error: Insufficient funds. Current balance: $' || current_balance;
    END IF;
    
    RETURN result_message;
END;
$$ LANGUAGE plpgsql;

--Session 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT withdraw_money(1, 600.00, 3);
SELECT * FROM bank_account;
--Wait
COMMIT;

--Session 2
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT withdraw_money(1, 500.00, 1);
SELECT * FROM bank_account;
COMMIT;


--Session 1
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT 'Initial balance:' || balance 
FROM bank_account WHERE account_id = 1;

SELECT pg_sleep(2);

UPDATE bank_account SET balance = balance - 600 
WHERE account_id = 1 
RETURNING 'Session 1: 600 withdrawn. Balance:' || balance;
COMMIT;

--Session 2
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT 'Initial balance:' || balance 
FROM bank_account WHERE account_id = 1;

SELECT pg_sleep(1);

UPDATE bank_account SET balance = balance - 500 
WHERE account_id = 1 
RETURNING 'Session 2: 500 withdrawn. Balance:' || balance;
COMMIT;


-- Ex.4
-- Session 1 - Joe
UPDATE sells SET price = 3.50 WHERE product = 'Coke';

UPDATE sells SET price = 2.50 WHERE product = 'Fanta';

-- Session 2 - Sally
SELECT MAX(price) as max_price, MIN(price) as min_price 
FROM sells 
WHERE shop = 'Joe''s Shop';

SELECT MAX(price) as max_price, MIN(price) as min_price 
FROM sells 
WHERE shop = 'Joe''s Shop';

-- Solution
-- Session 1 - Joe
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE sells SET price = 3.00 WHERE product = 'Coke';
UPDATE sells SET price = 1.00 WHERE product = 'Fanta';
COMMIT;

-- Session 2 - Sally
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price) as max_price, MIN(price) as min_price,
       COUNT(*) as product_count
FROM sells 
WHERE shop = 'Joe''s Shop';
COMMIT;


-- Questions for Self-Assessment
--1
-- Atomic: either full transfer or none
-- Consistent: constraints stay valid
-- Isolated: concurrent users don’t interfere
-- Durable: committed data survives crash
--2
-- COMMIT = save changes; ROLLBACK = undo
--3
-- SAVEPOINT = partial rollback inside transaction
--4
-- Read uncommitted – dirty reads allowed
-- Read committed – no dirty reads
-- Repeatable read – no non-repeatable reads
-- Serializable – no phantoms
--5
-- Dirty read = uncommitted read; allowed in READ UNCOMMITTED
--6
-- Non-repeatable read → same row read twice → values differ
-- 7
-- Phantom read = new rows appear; prevented only in SERIALIZABLE
-- 8
-- READ COMMITTED is faster; SERIALIZABLE is slow
-- 9
-- Transactions prevent race conditions & inconsistent updates
-- 10
-- Uncommitted data is lost on crash