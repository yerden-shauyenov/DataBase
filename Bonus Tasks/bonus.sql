CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    iin VARCHAR(12) UNIQUE NOT NULL CHECK (LENGTH(tin) = 12 AND tin ~ '^[0-9]+$'),
    full_name VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active' 
        CHECK (status IN ('active', 'blocked', 'frozen')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    daily_limit_kzt DECIMAL(15,2) DEFAULT 1000000.00
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    account_number VARCHAR(34) UNIQUE NOT NULL,
    currency VARCHAR(3) NOT NULL CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP,
	CONSTRAINT valid_account_number CHECK (account_number ~ '^KZ[0-9]{18}$'),
	CONSTRAINT account_closure_check CHECK (
        (closed_at IS NULL AND is_active = TRUE) OR 
        (closed_at IS NOT NULL AND is_active = FALSE)
    )
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    from_account_id INTEGER REFERENCES accounts(account_id),
    to_account_id INTEGER REFERENCES accounts(account_id),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) NOT NULL CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    exchange_rate DECIMAL(10,6),
    amount_kzt DECIMAL(15,2) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('transfer', 'deposit', 'withdrawal')),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    description VARCHAR(200)
);

CREATE TABLE exchange_rates (
    rate_id SERIAL PRIMARY KEY,
    from_currency VARCHAR(3) NOT NULL,
    to_currency VARCHAR(3) NOT NULL,
    rate DECIMAL(10,6) NOT NULL,
    valid_from TIMESTAMP NOT NULL,
    valid_to TIMESTAMP
);

CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id INTEGER NOT NULL,
    action VARCHAR(10) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45)
);

-- customers
INSERT INTO customers (tin, full_name, phone, email, status, daily_limit_kzt) VALUES
('123456789012', 'Нургалиев Аслан Бахытжанович', '+77011234567', 'aslan.nurgaliev@email.kz', 'active', 5000000.00),
('234567890123', 'Садыкова Гульмира Канатовна', '+77022345678', 'gulmira.sadykova@email.kz', 'active', 3000000.00),
('345678901234', 'Жумабеков Данияр Серикович', '+77033456789', 'daniyar.zhumabekov@email.kz', 'active', 10000000.00),
('456789012345', 'Искакова Айгуль Талгатовна', '+77044567890', 'aigul.iskakova@email.kz', 'active', 2000000.00),
('567890123456', 'Кенжебаев Арман Нурланович', '+77055678901', 'arman.kenzhebayev@email.kz', 'blocked', 500000.00),
('678901234567', 'Оразбаева Сания Маратовна', '+77066789012', 'saniya.orazbayeva@email.kz', 'active', 4000000.00),
('789012345678', 'Ташенов Бауыржан Кайратович', '+77077890123', 'bauyrzhan.tashenov@email.kz', 'frozen', 1000000.00),
('890123456789', 'Шарипова Мерей Данияровна', '+77088901234', 'merey.sharipova@email.kz', 'active', 6000000.00),
('901234567890', 'Сулеймен Ерлан Бауржанович', '+77099012345', 'yerlan.suleimen@email.kz', 'active', 8000000.00),
('012345678901', 'Абдуллина Айжан Руслановна', '+77100123456', 'aizhan.abdullina@email.kz', 'active', 3500000.00),
('112345678902', 'Бекмухамедов Нурлан Сагинтаевич', '+77111234567', 'nurlan.bekmuhamedov@email.kz', 'active', 2500000.00),
('212345678903', 'Карсыбекова Гулдана Тимуровна', '+77122345678', 'guldana.karsybekova@email.kz', 'active', 1500000.00);

-- accounts
INSERT INTO accounts (customer_id, account_number, currency, balance, is_active) VALUES
(1, 'KZ123456789012345678', 'KZT', 15000000.00, true),
(1, 'KZ123456789012345679', 'USD', 50000.00, true),
(2, 'KZ234567890123456789', 'KZT', 8000000.00, true),
(2, 'KZ234567890123456790', 'EUR', 25000.00, true),
(3, 'KZ345678901234567890', 'KZT', 25000000.00, true),
(3, 'KZ345678901234567891', 'USD', 100000.00, true),
(4, 'KZ456789012345678901', 'KZT', 5000000.00, true),
(5, 'KZ567890123456789012', 'KZT', 2000000.00, true),
(6, 'KZ678901234567890123', 'KZT', 12000000.00, true),
(6, 'KZ678901234567890124', 'RUB', 500000.00, true),
(7, 'KZ789012345678901234', 'KZT', 6000000.00, true),
(8, 'KZ890123456789012345', 'KZT', 9000000.00, true),
(9, 'KZ901234567890123456', 'KZT', 18000000.00, true),
(10, 'KZ012345678901234567', 'KZT', 7000000.00, true),
(10, 'KZ012345678901234568', 'USD', 40000.00, true),
(11, 'KZ112345678901234569', 'KZT', 4500000.00, true),
(12, 'KZ212345678901234570', 'KZT', 3000000.00, true);

-- exchange_rates
INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from) VALUES
('USD', 'KZT', 450.00, '2024-01-01 00:00:00'),
('USD', 'KZT', 452.50, '2024-03-01 00:00:00'),
('EUR', 'KZT', 490.00, '2024-01-01 00:00:00'),
('EUR', 'KZT', 492.75, '2024-03-01 00:00:00'),
('RUB', 'KZT', 5.00, '2024-01-01 00:00:00'),
('RUB', 'KZT', 5.15, '2024-03-01 00:00:00'),
('KZT', 'USD', 0.002222, '2024-01-01 00:00:00'),
('KZT', 'EUR', 0.002041, '2024-01-01 00:00:00'),
('KZT', 'RUB', 0.20, '2024-01-01 00:00:00'),
('USD', 'EUR', 0.92, '2024-01-01 00:00:00'),
('EUR', 'USD', 1.087, '2024-01-01 00:00:00');

-- transactions
INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, description, created_at, completed_at) VALUES
(1, 3, 1000000.00, 'KZT', 1.0, 1000000.00, 'transfer', 'completed', 'Оплата за оборудование', '2024-03-10 09:30:00', '2024-03-10 09:30:05'),
(2, 6, 5000.00, 'USD', 450.00, 2250000.00, 'transfer', 'completed', 'Международный перевод', '2024-03-10 10:15:00', '2024-03-10 10:15:10'),
(3, 1, 500000.00, 'KZT', 1.0, 500000.00, 'transfer', 'completed', 'Возврат долга', '2024-03-10 11:45:00', '2024-03-10 11:45:05'),
(NULL, 5, 2000000.00, 'KZT', 1.0, 2000000.00, 'deposit', 'completed', 'Депозит на счет', '2024-03-10 12:30:00', '2024-03-10 12:30:10'),
(7, NULL, 500000.00, 'KZT', 1.0, 500000.00, 'withdrawal', 'completed', 'Снятие наличных', '2024-03-10 13:15:00', '2024-03-10 13:15:05'),
(4, 8, 10000.00, 'EUR', 490.00, 4900000.00, 'transfer', 'completed', 'Оплата недвижимости', '2024-03-10 14:00:00', '2024-03-10 14:00:10'),
(9, 10, 3000000.00, 'KZT', 1.0, 3000000.00, 'transfer', 'failed', 'Недостаточно средств', '2024-03-10 14:45:00', NULL),
(11, 12, 100000.00, 'KZT', 1.0, 100000.00, 'transfer', 'pending', 'Ожидает подтверждения', '2024-03-10 15:30:00', NULL),
(NULL, 13, 1500000.00, 'KZT', 1.0, 1500000.00, 'deposit', 'completed', 'Зарплата', '2024-03-10 16:15:00', '2024-03-10 16:15:10'),
(14, NULL, 1000000.00, 'KZT', 1.0, 1000000.00, 'withdrawal', 'completed', 'Снятие в банкомате', '2024-03-10 17:00:00', '2024-03-10 17:00:05'),
(1, 4, 200000.00, 'KZT', 1.0, 200000.00, 'transfer', 'completed', 'Оплата услуг', '2024-03-10 18:30:00', '2024-03-10 18:30:05'),
(3, 5, 1500000.00, 'KZT', 1.0, 1500000.00, 'transfer', 'completed', 'Инвестиции', '2024-03-10 19:15:00', '2024-03-10 19:15:10'),
(6, 7, 800000.00, 'KZT', 1.0, 800000.00, 'transfer', 'completed', 'Перевод родственникам', '2024-03-10 20:00:00', '2024-03-10 20:00:05');

-- audit_log
INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address) VALUES
('customers', 1, 'INSERT', NULL, '{"tin": "123456789012", "full_name": "Нургалиев Аслан Бахытжанович", "status": "active"}', 'admin', '2024-01-15 09:00:00', '192.168.1.1'),
('accounts', 1, 'INSERT', NULL, '{"account_number": "KZ123456789012345678", "balance": 15000000.00}', 'admin', '2024-01-15 09:05:00', '192.168.1.1'),
('transactions', 1, 'INSERT', NULL, '{"amount": 1000000.00, "status": "completed"}', 'system', '2024-03-10 09:30:00', '10.0.0.1'),
('customers', 2, 'UPDATE', '{"status": "active"}', '{"status": "active", "daily_limit_kzt": 4000000.00}', 'manager', '2024-02-20 14:30:00', '192.168.1.2'),
('accounts', 3, 'UPDATE', '{"balance": 7500000.00}', '{"balance": 8000000.00}', 'system', '2024-03-10 09:30:05', '10.0.0.1'),
('transactions', 2, 'INSERT', NULL, '{"amount": 5000.00, "currency": "USD"}', 'system', '2024-03-10 10:15:00', '10.0.0.1'),
('customers', 5, 'UPDATE', '{"status": "active"}', '{"status": "blocked"}', 'security', '2024-02-15 11:20:00', '192.168.1.3'),
('accounts', 7, 'UPDATE', '{"balance": 4500000.00}', '{"balance": 5000000.00}', 'system', '2024-03-10 12:30:10', '10.0.0.1'),
('transactions', 4, 'UPDATE', '{"status": "pending"}', '{"status": "completed"}', 'system', '2024-03-10 12:30:10', '10.0.0.1'),
('customers', 7, 'UPDATE', '{"status": "active"}', '{"status": "frozen"}', 'security', '2024-03-01 16:45:00', '192.168.1.3'),
('accounts', 9, 'UPDATE', '{"balance": 11500000.00}', '{"balance": 12000000.00}', 'system', '2024-03-05 10:00:00', '10.0.0.2'),
('transactions', 7, 'UPDATE', '{"status": "pending"}', '{"status": "failed"}', 'system', '2024-03-10 14:45:05', '10.0.0.1'),
('exchange_rates', 2, 'INSERT', NULL, '{"from_currency": "USD", "to_currency": "KZT", "rate": 452.50}', 'admin', '2024-03-01 00:00:00', '192.168.1.1');

-- Проверка количества записей
SELECT 'customers' as table_name, COUNT(*) as record_count FROM customers
UNION ALL
SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'exchange_rates', COUNT(*) FROM exchange_rates
UNION ALL
SELECT 'audit_log', COUNT(*) FROM audit_log;


-- Task 1: Transaction Management
CREATE OR REPLACE PROCEDURE process_transfer(
    p_from_account_number VARCHAR,
    p_to_account_number VARCHAR,
    p_amount DECIMAL,
    p_currency VARCHAR,
    p_description TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_from_account_id INTEGER;
    v_to_account_id INTEGER;
    v_from_customer_id INTEGER;
    v_to_customer_id INTEGER;
    v_from_balance DECIMAL;
    v_from_currency VARCHAR;
    v_to_currency VARCHAR;
    v_exchange_rate DECIMAL;
    v_amount_kzt DECIMAL;
    v_daily_limit_kzt DECIMAL;
    v_today_total DECIMAL;
    v_customer_status VARCHAR;
    v_transaction_id INTEGER;
    v_error_code INTEGER DEFAULT 0;
    v_error_message TEXT;
BEGIN
    BEGIN
        -- 1. We receive information about the sender's account
        SELECT a.account_id, a.customer_id, a.balance, a.currency, c.status, c.daily_limit_kzt
        INTO v_from_account_id, v_from_customer_id, v_from_balance, v_from_currency, v_customer_status, v_daily_limit_kzt
        FROM accounts a
        JOIN customers c ON a.customer_id = c.customer_id
        WHERE a.account_number = p_from_account_number
        FOR UPDATE OF a;
        
        -- Verification of the existence of the sender's account
        IF v_from_account_id IS NULL THEN
            RAISE EXCEPTION 'ERR001: Sender account was not found';
        END IF;
        
        -- 2. We receive information about the recipient's account
        SELECT a.account_id, a.customer_id, a.currency
        INTO v_to_account_id, v_to_customer_id, v_to_currency
        FROM accounts a
        WHERE a.account_number = p_to_account_number
        FOR UPDATE OF a;
        
        -- Verification of the recipient's account existence
        IF v_to_account_id IS NULL THEN
            RAISE EXCEPTION 'ERR002: Recipient account was not found';
        END IF;
        
        -- 3. Checking account activity
        IF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = v_from_account_id AND is_active = TRUE) THEN
            RAISE EXCEPTION 'ERR003: The sender account is inactive';
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = v_to_account_id AND is_active = TRUE) THEN
            RAISE EXCEPTION 'ERR004: The recipient account is inactive';
        END IF;
        
        -- 4. Checking the status of the sender's client
        IF v_customer_status != 'active' THEN
            RAISE EXCEPTION 'ERR005: The sender client has the status %', v_customer_status;
        END IF;
        
        -- 5. Calculating the amount in KZT to check the limit
        IF p_currency = 'KZT' THEN
            v_amount_kzt := p_amount;
            v_exchange_rate := 1.0;
        ELSE
            SELECT rate INTO v_exchange_rate
            FROM exchange_rates
            WHERE from_currency = p_currency
                AND to_currency = 'KZT'
                AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
                AND valid_from <= CURRENT_TIMESTAMP
            ORDER BY valid_from DESC
            LIMIT 1;
            
            IF v_exchange_rate IS NULL THEN
                RAISE EXCEPTION 'ERR006: Currency exchange rate % not found', p_currency;
            END IF;
            
            v_amount_kzt := p_amount * v_exchange_rate;
        END IF;
        
        -- 6. Checking the daily limit
        SELECT COALESCE(SUM(amount_kzt), 0)
        INTO v_today_total
        FROM transactions
        WHERE from_account_id = v_from_account_id
            AND status = 'completed'
            AND created_at::DATE = CURRENT_DATE;
        
        IF v_today_total + v_amount_kzt > v_daily_limit_kzt THEN
            RAISE EXCEPTION 'ERR007: The daily limit has been exceeded. Used: %, limit: %, required: %',
                v_today_total, v_daily_limit_kzt, v_amount_kzt;
        END IF;
        
        -- 7. Checking the adequacy of funds
        DECLARE
            v_required_amount DECIMAL;
            v_conversion_rate DECIMAL;
        BEGIN
            IF v_from_currency != p_currency THEN
                SELECT rate INTO v_conversion_rate
                FROM exchange_rates
                WHERE from_currency = p_currency
                    AND to_currency = v_from_currency
                    AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
                    AND valid_from <= CURRENT_TIMESTAMP
                ORDER BY valid_from DESC
                LIMIT 1;
                
                IF v_conversion_rate IS NULL THEN
                    RAISE EXCEPTION 'ERR008: The conversion rate from % to % was not found', p_currency, v_from_currency;
                END IF;
                
                v_required_amount := p_amount * v_conversion_rate;
                
                IF v_from_balance < v_required_amount THEN
                    RAISE EXCEPTION 'ERR009: Insufficient funds. Balance: %, required: %',
                        v_from_balance, v_required_amount;
                END IF;
            ELSE
                v_required_amount := p_amount;
                
                IF v_from_balance < v_required_amount THEN
                    RAISE EXCEPTION 'ERR010: Insufficient funds. Balance: %, required: %',
                        v_from_balance, v_required_amount;
                END IF;
            END IF;
        END;
        
        SAVEPOINT before_transfer;
        
        -- 8. Create a record of the transaction
        INSERT INTO transactions (
            from_account_id,
            to_account_id,
            amount,
            currency,
            exchange_rate,
            amount_kzt,
            type,
            status,
            description,
            created_at
        ) VALUES (
            v_from_account_id,
            v_to_account_id,
            p_amount,
            p_currency,
            v_exchange_rate,
            v_amount_kzt,
            'transfer',
            'pending',
            p_description,
            CURRENT_TIMESTAMP
        ) RETURNING transaction_id INTO v_transaction_id;
        
        -- 9. Debiting funds from the sender's account
        DECLARE
            v_conversion_rate_to_account DECIMAL;
        BEGIN
            IF v_from_currency != p_currency THEN
                SELECT rate INTO v_conversion_rate_to_account
                FROM exchange_rates
                WHERE from_currency = p_currency
                    AND to_currency = v_from_currency
                    AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
                    AND valid_from <= CURRENT_TIMESTAMP
                ORDER BY valid_from DESC
                LIMIT 1;
                
                IF v_conversion_rate_to_account IS NULL THEN
                    RAISE EXCEPTION 'ERR011: The exchange rate for converting to the account currency was not found';
                END IF;
                
                UPDATE accounts 
                SET balance = balance - (p_amount * v_conversion_rate_to_account)
                WHERE account_id = v_from_account_id;
            ELSE
                UPDATE accounts 
                SET balance = balance - p_amount 
                WHERE account_id = v_from_account_id;
            END IF;
        END;
        
        -- 10. Crediting funds to the recipient's account
        DECLARE
            v_conversion_rate_to_target DECIMAL;
        BEGIN
            IF v_to_currency = p_currency THEN
                UPDATE accounts 
                SET balance = balance + p_amount 
                WHERE account_id = v_to_account_id;
            ELSE
                SELECT rate INTO v_conversion_rate_to_target
                FROM exchange_rates
                WHERE from_currency = p_currency
                    AND to_currency = v_to_currency
                    AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
                    AND valid_from <= CURRENT_TIMESTAMP
                ORDER BY valid_from DESC
                LIMIT 1;
                
                IF v_conversion_rate_to_target IS NULL THEN
                    RAISE EXCEPTION 'ERR012: The exchange rate for conversion to the recipient account currency was not found';
                END IF;
                
                UPDATE accounts 
                SET balance = balance + (p_amount * v_conversion_rate_to_target)
                WHERE account_id = v_to_account_id;
            END IF;
        END;
        
        -- 11. Updating the transaction status to completed
        UPDATE transactions 
        SET status = 'completed',
            completed_at = CURRENT_TIMESTAMP
        WHERE transaction_id = v_transaction_id;
        
        -- 12. Logging a successful operation
        INSERT INTO audit_log (
            table_name,
            record_id,
            action,
            new_values,
            changed_by,
            changed_at
        ) VALUES (
            'transactions',
            v_transaction_id,
            'INSERT',
            jsonb_build_object(
                'transaction_id', v_transaction_id,
                'status', 'completed',
                'amount', p_amount,
                'currency', p_currency,
                'message', 'The transaction was completed successfully'
            ),
            CURRENT_USER,
            CURRENT_TIMESTAMP
        );
        
        COMMIT;
        
        RAISE NOTICE 'Transaction % completed successfully. Amount: % %, Converted to KZT: %',
            v_transaction_id, p_amount, p_currency, v_amount_kzt;
            
    EXCEPTION
        WHEN OTHERS THEN
            -- We receive information about the error
            GET STACKED DIAGNOSTICS 
                v_error_code = RETURNED_SQLSTATE,
                v_error_message = MESSAGE_TEXT;
            
            -- Logging the error
            INSERT INTO audit_log (
                table_name,
                record_id,
                action,
                new_values,
                changed_by,
                changed_at
            ) VALUES (
                'transactions',
                COALESCE(v_transaction_id, 0),
                'INSERT',
                jsonb_build_object(
                    'error_code', v_error_code,
                    'error_message', v_error_message,
                    'from_account', p_from_account_number,
                    'to_account', p_to_account_number,
                    'amount', p_amount,
                    'currency', p_currency,
                    'status', 'failed'
                ),
                CURRENT_USER,
                CURRENT_TIMESTAMP
            );
            
            IF v_transaction_id IS NOT NULL THEN
                ROLLBACK TO before_transfer;
            END IF;
            
            ROLLBACK;
            
            RAISE EXCEPTION 'Error %: %', v_error_code, v_error_message;
    END;
END;
$$;


-- Task 2
-- View 1: customer_balance_summary
CREATE OR REPLACE VIEW customer_balance_summary AS
WITH customer_balances AS (
    SELECT 
        c.customer_id,
        c.iin,
        c.full_name,
        c.daily_limit_kzt,
        a.account_id,
        a.account_number,
        a.currency,
        a.balance,
        CASE 
            WHEN a.currency = 'KZT' THEN a.balance
            WHEN a.currency = 'USD' THEN a.balance * er_usd.rate
            WHEN a.currency = 'EUR' THEN a.balance * er_eur.rate
            WHEN a.currency = 'RUB' THEN a.balance * er_rub.rate
            ELSE a.balance
        END as balance_kzt
    FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id
    LEFT JOIN LATERAL (
        SELECT rate 
        FROM exchange_rates 
        WHERE from_currency = 'USD' 
            AND to_currency = 'KZT'
            AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
            AND valid_from <= CURRENT_TIMESTAMP
        ORDER BY valid_from DESC
        LIMIT 1
    ) er_usd ON a.currency = 'USD'
    LEFT JOIN LATERAL (
        SELECT rate 
        FROM exchange_rates 
        WHERE from_currency = 'EUR' 
            AND to_currency = 'KZT'
            AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
            AND valid_from <= CURRENT_TIMESTAMP
        ORDER BY valid_from DESC
        LIMIT 1
    ) er_eur ON a.currency = 'EUR'
    LEFT JOIN LATERAL (
        SELECT rate 
        FROM exchange_rates 
        WHERE from_currency = 'RUB' 
            AND to_currency = 'KZT'
            AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
            AND valid_from <= CURRENT_TIMESTAMP
        ORDER BY valid_from DESC
        LIMIT 1
    ) er_rub ON a.currency = 'RUB'
    WHERE a.is_active = TRUE
),
daily_transactions AS (
    SELECT 
        from_account_id,
        SUM(amount_kzt) as daily_total_kzt
    FROM transactions
    WHERE status = 'completed'
        AND created_at::DATE = CURRENT_DATE
        AND type = 'transfer'
    GROUP BY from_account_id
)
SELECT 
    cb.customer_id,
    cb.iin,
    cb.full_name,
    COUNT(cb.account_id) as account_count,
    SUM(cb.balance) as total_balance_original,
    SUM(cb.balance_kzt) as total_balance_kzt,
    cb.daily_limit_kzt,
    COALESCE(dt.daily_total_kzt, 0) as today_spent_kzt,
    ROUND(
        CASE 
            WHEN cb.daily_limit_kzt > 0 
            THEN (COALESCE(dt.daily_total_kzt, 0) / cb.daily_limit_kzt * 100) 
            ELSE 0 
        END, 2
    ) as limit_utilization_percent,
    RANK() OVER (ORDER BY SUM(cb.balance_kzt) DESC) as balance_rank
FROM customer_balances cb
LEFT JOIN daily_transactions dt ON EXISTS (
    SELECT 1 FROM accounts a 
    WHERE a.account_id = dt.from_account_id 
        AND a.customer_id = cb.customer_id
)
GROUP BY cb.customer_id, cb.iin, cb.full_name, cb.daily_limit_kzt, dt.daily_total_kzt;

-- View 2: daily_transaction_report
CREATE OR REPLACE VIEW daily_transaction_report AS
WITH daily_stats AS (
    SELECT 
        DATE(created_at) as transaction_date,
        type,
        COUNT(*) as transaction_count,
        SUM(amount_kzt) as total_volume_kzt,
        AVG(amount_kzt) as avg_amount_kzt,
        SUM(amount) as total_volume_original,
        AVG(amount) as avg_amount_original,
        currency
    FROM transactions
    WHERE status = 'completed'
    GROUP BY DATE(created_at), type, currency
)
SELECT 
    transaction_date,
    type,
    currency,
    transaction_count,
    total_volume_kzt,
    avg_amount_kzt,
    total_volume_original,
    avg_amount_original,
    SUM(total_volume_kzt) OVER (
        PARTITION BY type, currency 
        ORDER BY transaction_date
    ) as running_total_kzt,
    SUM(transaction_count) OVER (
        PARTITION BY type, currency 
        ORDER BY transaction_date
    ) as running_count,
    ROUND(
        CASE 
            WHEN LAG(total_volume_kzt) OVER (PARTITION BY type, currency ORDER BY transaction_date) > 0
            THEN ((total_volume_kzt - LAG(total_volume_kzt) OVER (PARTITION BY type, currency ORDER BY transaction_date)) / 
                  LAG(total_volume_kzt) OVER (PARTITION BY type, currency ORDER BY transaction_date) * 100)
            ELSE 0
        END, 2
    ) as daily_growth_percent
FROM daily_stats
ORDER BY transaction_date DESC, type, currency;

-- View 3: suspicious_activity_view (WITH SECURITY BARRIER)
CREATE OR REPLACE VIEW suspicious_activity_view WITH (security_barrier = true) AS
WITH large_transactions AS (
    -- Transactions over 5,000,000 KZT
    SELECT 
        t.transaction_id,
        t.created_at,
        t.amount_kzt,
        t.from_account_id,
        t.to_account_id,
        'large_transaction' as suspicion_type,
        jsonb_build_object(
            'amount_kzt', t.amount_kzt,
            'threshold', 5000000
        ) as details
    FROM transactions t
    WHERE t.status = 'completed'
        AND t.amount_kzt > 5000000
),
frequent_transactions AS (
    -- Customers with >10 transactions per hour
    SELECT 
        c.customer_id,
        DATE_TRUNC('hour', t.created_at) as hour_start,
        COUNT(*) as transaction_count,
        'high_frequency' as suspicion_type,
        jsonb_build_object(
            'transaction_count', COUNT(*),
            'threshold', 10,
            'hour', DATE_TRUNC('hour', t.created_at)
        ) as details
    FROM transactions t
    JOIN accounts a ON t.from_account_id = a.account_id
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE t.status = 'completed'
        AND t.type = 'transfer'
    GROUP BY c.customer_id, DATE_TRUNC('hour', t.created_at)
    HAVING COUNT(*) > 10
),
rapid_transfers AS (
    -- Fast sequential transfers
    SELECT 
        t1.transaction_id,
        t1.from_account_id,
        t1.created_at as first_transfer_time,
        t2.created_at as second_transfer_time,
        EXTRACT(EPOCH FROM (t2.created_at - t1.created_at)) as seconds_between,
        'rapid_sequential' as suspicion_type,
        jsonb_build_object(
            'time_between_seconds', EXTRACT(EPOCH FROM (t2.created_at - t1.created_at)),
            'threshold_seconds', 60
        ) as details
    FROM transactions t1
    JOIN transactions t2 ON t1.from_account_id = t2.from_account_id
        AND t1.transaction_id < t2.transaction_id
        AND t2.created_at - t1.created_at < INTERVAL '1 minute'
    WHERE t1.status = 'completed'
        AND t2.status = 'completed'
        AND t1.type = 'transfer'
        AND t2.type = 'transfer'
)
SELECT 
    'large_transaction' as category,
    lt.transaction_id as record_id,
    lt.created_at,
    lt.suspicion_type,
    lt.details
FROM large_transactions lt

UNION ALL

SELECT 
    'high_frequency' as category,
    ft.customer_id as record_id,
    ft.hour_start as created_at,
    ft.suspicion_type,
    ft.details
FROM frequent_transactions ft

UNION ALL

SELECT 
    'rapid_sequential' as category,
    rt.transaction_id as record_id,
    rt.first_transfer_time as created_at,
    rt.suspicion_type,
    rt.details
FROM rapid_transfers rt

ORDER BY created_at DESC;


-- Task 3
-- 1. B-tree index for searching by account number (the most frequent query)
CREATE INDEX idx_accounts_account_number ON accounts(account_number);
-- Speeding up account search by number in process_transfer

-- 2. Composite B-tree index for transactions by date and status
CREATE INDEX idx_transactions_date_status ON transactions(created_at, status);
-- Speeding up reports and checking daily limits

-- 3. Partial index for active accounts
CREATE INDEX idx_accounts_active ON accounts(account_id) WHERE is_active = TRUE;
-- Most operations work only with active accounts

-- 4. Expression index for case-independent email search
CREATE INDEX idx_customers_email_lower ON customers(LOWER(email));
-- Speeding up customer search by case-insensitive email

-- 5. GIN index for JSONB columns in audit_log
CREATE INDEX idx_audit_log_jsonb ON audit_log USING GIN(new_values);
-- Speeding up structured data search in JSONB

-- 6. Hash index for quick search by transaction type
CREATE INDEX idx_transactions_type_hash ON transactions USING HASH(type);
-- Hash indexes are faster for an exact match (=)

-- 7. Composite covering index for customer_balance_summary
CREATE INDEX idx_covering_transactions_report ON transactions
    (from_account_id, status, created_at, amount_kzt, type);
-- Covering index for daily reports without accessing the table


-- Task 4
-- Создание процедуры process_salary_batch
CREATE OR REPLACE PROCEDURE process_salary_batch(
    p_company_account_number VARCHAR,
    p_payments JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_company_account_id INTEGER;
    v_company_balance DECIMAL;
    v_total_amount DECIMAL := 0;
    v_successful_count INTEGER := 0;
    v_failed_count INTEGER := 0;
    v_failed_details JSONB := '[]'::JSONB;
    v_payment_record JSONB;
    v_payment_iin VARCHAR;
    v_payment_amount DECIMAL;
    v_payment_description TEXT;
    v_employee_account_id INTEGER;
    v_employee_account_number VARCHAR;
    v_lock_id BIGINT;
    v_batch_id INTEGER;
    v_error_message TEXT;
    v_error_code TEXT;
BEGIN
    v_lock_id := ('x' || substr(md5(p_company_account_number), 1, 16))::bit(64)::bigint;
    
    -- We are checking whether it is possible to set a lock to prevent parallel processing.
    IF NOT pg_try_advisory_lock(v_lock_id) THEN
        RAISE EXCEPTION 'ERR101: Batch processing is already underway for this account';
    END IF;
    
    BEGIN
        -- 1. We receive information about the company's account with a lock
        SELECT a.account_id, a.balance
        INTO v_company_account_id, v_company_balance
        FROM accounts a
        WHERE a.account_number = p_company_account_number
        FOR UPDATE;
        
        IF v_company_account_id IS NULL THEN
            RAISE EXCEPTION 'ERR102: The company account was not found';
        END IF;
        
        -- 2. Calculating the total amount of payments
        FOR v_payment_record IN SELECT * FROM jsonb_array_elements(p_payments)
        LOOP
            v_payment_amount := (v_payment_record->>'amount')::DECIMAL;
            v_total_amount := v_total_amount + v_payment_amount;
        END LOOP;
        
        -- 3. We check the sufficiency of funds
        IF v_company_balance < v_total_amount THEN
            RAISE EXCEPTION 'ERR103: There are insufficient funds in the company account. Balance: %, required: %',
                v_company_balance, v_total_amount;
        END IF;
        
        -- 5. We process every payment
        FOR v_payment_record IN SELECT * FROM jsonb_array_elements(p_payments)
        LOOP
            v_payment_iin := v_payment_record->>'iin';
            v_payment_amount := (v_payment_record->>'amount')::DECIMAL;
            v_payment_description := v_payment_record->>'description';
            v_employee_account_id := NULL;
            
            SAVEPOINT before_payment;
            
            BEGIN
                -- We are looking for an employee's account by IIN
                SELECT a.account_id, a.account_number
                INTO v_employee_account_id, v_employee_account_number
                FROM accounts a
                JOIN customers c ON a.customer_id = c.customer_id
                WHERE c.iin = v_payment_iin
                    AND a.currency = 'KZT'
                    AND a.is_active = TRUE;
                
                IF v_employee_account_id IS NULL THEN
                    RAISE EXCEPTION 'ERR104: The employee account with IIN % has not been found or is inactive', v_payment_iin;
                END IF;
                
                -- Creating a transaction
                INSERT INTO transactions (
                    from_account_id,
                    to_account_id,
                    amount,
                    currency,
                    exchange_rate,
                    amount_kzt,
                    type,
                    status,
                    description,
                    created_at,
                    completed_at
                ) VALUES (
                    v_company_account_id,
                    v_employee_account_id,
                    v_payment_amount,
                    'KZT',
                    1.0,
                    v_payment_amount,
                    'transfer',
                    'completed',
                    COALESCE(v_payment_description, 'Salary') || ' (batch processing)',
                    CURRENT_TIMESTAMP,
                    CURRENT_TIMESTAMP
                );
                
                -- Updating balances
                UPDATE accounts 
                SET balance = balance - v_payment_amount
                WHERE account_id = v_company_account_id;
                
                UPDATE accounts 
                SET balance = balance + v_payment_amount
                WHERE account_id = v_employee_account_id;
                
                v_successful_count := v_successful_count + 1;
                
            EXCEPTION
                WHEN OTHERS THEN
                    -- Rolling back to the point before this payment
                    ROLLBACK TO before_payment;
                    
                    GET STACKED DIAGNOSTICS 
                        v_error_message = MESSAGE_TEXT,
                        v_error_code = RETURNED_SQLSTATE;
                    
                    v_failed_count := v_failed_count + 1;
                    v_failed_details := v_failed_details || jsonb_build_object(
                        'iin', v_payment_iin,
                        'amount', v_payment_amount,
                        'error', v_error_message,
                        'error_code', v_error_code
                    );
                    
                    -- We continue processing the following payments
                    CONTINUE;
            END;
        END LOOP;
        
        -- 8. Log the result
        INSERT INTO audit_log (
            table_name,
            record_id,
            action,
            new_values,
            changed_by,
            changed_at
        ) VALUES (
            'batch_processing',
            v_company_account_id,
            'INSERT',
            jsonb_build_object(
                'company_account', p_company_account_number,
                'successful_count', v_successful_count,
                'failed_count', v_failed_count,
                'total_amount', v_total_amount,
                'failed_details', v_failed_details,
                'timestamp', CURRENT_TIMESTAMP
            ),
            CURRENT_USER,
            CURRENT_TIMESTAMP
        );
        
        RAISE NOTICE 'Batch processing is completed. Successful: %, Unsuccessful: %, Total amount: %KZT',
            v_successful_count, v_failed_count, v_total_amount;
            
        IF jsonb_array_length(v_failed_details) > 0 THEN
            RAISE NOTICE 'Error Details: %', v_failed_details;
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback the transaction in case of any error
            ROLLBACK;
            
            PERFORM pg_advisory_unlock(v_lock_id);
            RAISE;
    END;
    
    PERFORM pg_advisory_unlock(v_lock_id);
    
END;
$$;


-- Tests
-- 1. Successful transfer
CALL process_transfer('KZ123456789012345678', 'KZ234567890123456789', 100000, 'KZT', 'Тест 1: Успешный перевод');

-- 2. Error: the account was not found
CALL process_transfer('KZ000000000000000000', 'KZ234567890123456789', 100000, 'KZT', 'Тест 2: Счет не найден');

-- 3. Error: insufficient funds
CALL process_transfer('KZ123456789012345678', 'KZ234567890123456789', 100000000, 'KZT', 'Тест 3: Недостаточно средств');

-- 4. Error: the customer is blocked (customer_id = 5)
CALL process_transfer('KZ567890123456789012', 'KZ123456789012345678', 100000, 'KZT', 'Тест 4: Клиент заблокирован');

-- 5. Error: daily limit exceeded
CALL process_transfer('KZ123456789012345678', 'KZ234567890123456789', 4000000, 'KZT', 'Исчерпание лимита');
CALL process_transfer('KZ123456789012345678', 'KZ234567890123456789', 1000000, 'KZT', 'Тест 5: Лимит превышен');

-- 6. Inter-currency transfer
CALL process_transfer('KZ123456789012345679', 'KZ123456789012345678', 1000, 'USD', 'Тест 6: USD to KZT');


-- DESIGN DECISIONS
-- Task 1
--Using BEGIN/COMMIT/ROLLBACK for ACID
--SELECT ... FOR UPDATE blocks invoices from being changed at the same time
--SAVEPOINT allows you to roll back only part of the transaction in case of a currency conversion error.
--We check 6 conditions before the transfer (existence of accounts, activity, client status, balance, limit, exchange rate)
--All errors are logged with codes (ERR001-ERR012)
--Converting the currency at the current exchange rate

-- Task 2
--customer_balance_summary - summary of clients
--LEFT JOIN LATERAL gets the current exchange rate for each account
--RANK() sorts clients by wealth
--Converts all currencies to KZT for comparison

--daily_transaction_report - daily statistics
--PARTITION BY type, currency creates separate windows for each combination
--LAG() compares with the previous day
--SUM() OVER() counts the cumulative totals

--suspicious_activity_view - Fraud search
--WITH SECURITY BARRIER protects against security circumvention
--Searches for 3 types of suspicions: large amounts, frequent transactions, fast transfers

-- Task 3
--B-tree by account number - to search for transfers
--Composite B-tree by date and status - for reports
--Partial index of only active accounts - 80% of requests to them
--A case-free email expression index is used to find clients.
--JSONB GIN index - for quick search in audit logs
--Hash index by transaction type - exact match
--The covering index for reports is all the data in the index

-- Task 4
--Advisory lock does not allow you to launch two packages for one company
--The JSONB input parameter accepts a list of payments
--SAVEPOINT for each payment - an error in one does not spoil the entire package
--First, all checks, then one UPDATE - minimal locks
--Returns statistics - how many successful, how many with errors