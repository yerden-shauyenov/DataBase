-- Part 1
-- Task 1.1
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

--Task 1.2
CREATE TABLE products_catalog (
	product_id SERIAL PRIMARY KEY,
	product_name TEXT,
	regular_price NUMERIC,
	discount_price NUMERIC,
	CONSTRAINT valid_discount CHECK (
		regular_price > 0 AND
		discount_price > 0 AND
		discount_price < regular_price
	)
);

-- Task 1.3
CREATE TABLE bookings (
	booking_id SERIAL PRIMARY KEY,
	check_in_date DATE,
	check_out_date DATE,
	num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
	CHECK (check_out_date > check_in_date)
);

-- Task 1.4
INSERT INTO employees VALUES
(1, 'John', 'Doe', 30, 50000),
(2, 'Jane', 'Smith', 25, 45000);

INSERT INTO employees VALUES
(3, 'Mike', 'Brown', 17, 35000),
-- error: age check
(4, 'Sarah', 'Wilson', 23, -10000);
-- error: salary check


INSERT INTO products_catalog VALUES
(1, 'Laptop', 1000, 800),
(2, 'Mouse', 50, 35),
(3, 'Keyboard', 0, 25),  -- error: regular price > 0
(4, 'Monitor', 300, -50),  -- error: discount_price > 0
(5, 'Tablet', 400, 450); -- error: regular_price > discount_price


INSERT INTO bookings VALUES 
(1, '2024-01-15', '2024-01-20', 2),
(2, '2024-02-01', '2024-02-05', 4),
(3, '2024-03-10', '2024-03-15', 0), -- error: num_guests between 1 and 10
(4, '2024-05-10', '2024-05-05', 3); -- error: check_out_date > check_in_date


-- Part 2
-- Task 2.1
CREATE TABLE cusromers (
	customer_id INTEGER PRIMARY KEY NOT NULL,
	email TEXT NOT NULL,
	phone TEXT,
	registration_date DATE NOT NULL
);

-- Task 2.2
CREATE TABLE inventory (
	item_id INTEGER NOT NULL,
	item_name TEXT NOT NULL,
	quantity INTEGER NOT NULL CHECK(quantity >= 0),
	unit_price NUMERIC NOT NULL CHECK(unit_price > 0),
	ladt_updated TIMESTAMP NOT NULL
);

-- Task 2.3
INSERT INTO customers VALUES 
(1, 'john.doe@email.com', '+1234567890', '2024-01-15'),
(2, 'jane.smith@email.com', NULL, '2024-01-16'); --null insert

INSERT INTO customers VALUES 
(3, NULL, '+2222222222', '2024-01-19'), -- error: email is not null
(4, 'test@email.com', '+3333333333', NULL); -- error: registration_date is not null


-- Part 3
-- Task 3.1
CREATE TABLE users (
	user_id INTEGER PRIMARY KEY,
	username TEXT UNIQUE,
	email TEXT UNIQUE,
	created_date TIMESTAMP
);

-- Task 3.2
CREATE TABLE course_enrollments (
	erollment_id INTEGER PRIMARY KEY,
	student_id INTEGER,
	course_coed TEXT,
	semester TEXT,
	UNIQUE (student_id, course_coed, semester);
);

-- Task 3.3
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE(username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE(email);

INSERT INTO users VALUES 
(1, 'john_doe', 'john@example.com'),
(2, 'jane_smith', 'jane@example.com'),
(3, 'john_doe', 'new@example.com'), -- error: unique username
(4, 'new_user', 'john@example.com'); -- error: unique email


-- Part 4
-- Task 4.1
CREATE TABLE departments (
	dept_id INTEGER PRIMARY KEY,
	dept_name TEXT NOT NULL,
	dept_location TEXT
);

INSERT INTO departments (dept_id, dept_name, location) VALUES 
(1, 'IT', 'New York'),
(2, 'HR', 'Boston'),
(3, 'Finance', 'Chicago'),
(2, 'Marketing', 'Los Angeles'), -- error: unique dept_id
(NULL, 'Sales', 'Miami'); -- error: null dept_id

-- Task 4.2
CREATE TABLE student_courses (
	student_id INTEGER,
	course_id INTEGER,
	enrollment_date DATE,
	grade TEXT,
	PRIMARY KEY (student_id, course_id)
);

-- Task 4.3
--  A PRIMARY KEY is a special constraint that uniquely identifies each record in a table. It must contain UNIQUE values and cannot contain NULL values. A table can have only one PRIMARY KEY.
-- UNIQUE constraints can accept one NULL value, and a table can have multiple UNIQUE constraints.

-- Use a single-column PRIMARY KEY when you have a natural unique identifier or when using surrogate keys.
-- Use a composite PRIMARY KEY when uniqueness is determined by the combination of multiple columns.

-- A table can have only one PRIMARY KEY because it serves as the main identifier for records in the table.
-- Each UNIQUE constraint ensures data uniqueness in different aspects without claiming to be the primary identifier.


-- Part 5
-- Task 5.1
CREATE TABLE employees_dept (
	emp_id INTEGER PRIMARY KEY,
	emp_name TEXT NOT NULL,
	dept_id INTEGER REFERENCES departments(dept_id),
	hire_date DATE
);

INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date) VALUES 
(1, 'John Smith', 1, '2023-01-15'),
(2, 'Maria Garcia', 2, '2023-03-20');

INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date) VALUES 
(4, 'Sarah Wilson', 99, '2023-08-05'); -- error: foreign key

-- Task 5.2
CREATE TABLE authors (
	author_id INTEGER PRIMARY KEY,
	author_name TEXT NOT NULL,
	country TEXT
);

CREATE TABLE publishers (
	publisher_id INTEGER PRIMARY KEY,
	publisher_name TEXT NOT NULL,
	city TEXT
);

CREATE TABLE books (
	book_id INTEGER PRIMARY KEY,
	title TEXT NOT NULL,
	author_id INTEGER REFERENCES authors(author_id),
	publisher_id INTEGER REFERENCES publishers(publisher_id),
	publication_year INTEGER,
	isbn TEXT UNIQUE
);

INSERT INTO authors (author_id, author_name, country) VALUES 
(1, 'George Orwell', 'United Kingdom'),
(2, 'J.K. Rowling', 'United Kingdom');

INSERT INTO publishers (publisher_id, publisher_name, city) VALUES 
(1, 'Penguin Books', 'London'),
(2, 'Bloomsbury', 'London');

INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn) VALUES 
(1, '1984', 1, 1, 1949, '978-0451524935'),
(2, 'Animal Farm', 1, 1, 1945, '978-0451526342'),
(3, 'Harry Potter and the Philosopher''s Stone', 2, 2, 1997, '978-0747532699'),
(4, 'Harry Potter and the Chamber of Secrets', 2, 2, 1998, '978-0747538493');

INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn) VALUES 
(5, 'Unknown Book', 99, 1, 2020, '978-0000000000'); -- error: author_id

INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn) VALUES 
(6, 'Another Book', 1, 99, 2020, '978-0000000001'); -- error: publisher_id

-- Task 5.3
CREATE TABLE categories (
	category_id INTEGER PRIMARY KEY,
	category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
	product_id INTEGER PRIMARY KEY,
	product_name TEXT NOT NULL,
	category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT,
);

CREATE TABLE orders (
	order_id INTEGER PRIMARY KEY,
	order_date DATE NOT NULL
);

CREATE TABLE order_items (
	item_id INTEGER PRIMARY KEY,
	order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
	product_id INTEGER REFERENCES products_fk(product_id),
	quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories (category_id, category_name) VALUES 
(1, 'Electronics'),
(2, 'Books'),
(3, 'Clothing');

INSERT INTO products_fk (product_id, product_name, category_id) VALUES 
(1, 'Laptop', 1),
(2, 'Smartphone', 1),
(3, 'Novel', 2),
(4, 'T-Shirt', 3);

INSERT INTO orders (order_id, order_date) VALUES 
(101, '2024-01-15'),
(102, '2024-01-16'),
(103, '2024-01-17');

INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES 
(1, 101, 1, 1),
(2, 101, 3, 2),
(3, 102, 2, 1),
(4, 102, 4, 3),
(5, 103, 1, 1),
(6, 103, 3, 1);

DELETE FROM categories WHERE category_id = 1; -- error: RESTRICT

DELETE FROM orders WHERE order_id = 101;
SELECT * FROM order_items WHERE order_id = 101; -- deleted

-- RESTRICT prevents the deletion of a parent record if dependent child records exist.
-- CASCADE automatically deletes all child records when deleting the parent one.


-- Part 6
CREATE TABLE customers (
	customer_id SERIAL PRIMARY KEY,
	customer_name TEXT NOT NULL,
	email TEXT UNIQUE NOT NULL,
	phone TEXT,
	registration_date DATE
);

CREATE TABLE products (
	product_id SERIAL PRIMARY KEY,
	product_name TEXT NOT NULL,
	description TEXT,
	price NUMERIC(10, 2) CHECK (price >= 0),
	stock_quantity INTEGER CHECK (stock_quantity >= 0)
	
);

CREATE TABLE orders (
	order_id SERIAL PRIMARY KEY,
	customer_id INTEGER REFERENCES customers(customer_id) ON DELETE RESTRICT,
	order_date DATE,
	total_amount NUMERIC(10, 2) CHECK (total_amount >= 0),
	status TEXT CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_details (
	order_detail_id SERIAL PRIMARY KEY,
	order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
	product_id INTEGER REFERENCES products(product_id) ON DELETE RESTRICT,
	quantity INTEGER CHECK (quantity > 0),
	unit_price NUMERIC(10, 2) CHECK (unit_price >= 0)
);


INSERT INTO customers (customer_name, email, phone, registration_date) VALUES 
('John Smith', 'john.smith@email.com', '+1-555-0101', '2023-01-15'),
('Maria Garcia', 'maria.garcia@email.com', '+1-555-0102', '2023-02-20'),
('David Johnson', 'david.johnson@email.com', '+1-555-0103', '2023-03-10'),
('Sarah Wilson', 'sarah.wilson@email.com', '+1-555-0104', '2023-04-05'),
('Michael Brown', 'michael.brown@email.com', '+1-555-0105', '2023-05-12');

INSERT INTO products (product_name, description, price, stock_quantity) VALUES 
('iPhone 15 Pro', 'Latest Apple smartphone with advanced camera', 999.99, 50),
('Samsung Galaxy S24', 'Android flagship with AI features', 849.99, 75),
('MacBook Air M3', 'Lightweight laptop for professionals', 1199.99, 30),
('Sony WH-1000XM5', 'Noise-cancelling wireless headphones', 349.99, 100),
('iPad Air', 'Versatile tablet for work and entertainment', 599.99, 40);

INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES 
(1, '2024-01-10', 999.99, 'delivered'),
(2, '2024-01-12', 1849.98, 'processing'),
(3, '2024-01-15', 599.99, 'shipped'),
(4, '2024-01-18', 1349.98, 'pending'),
(1, '2024-01-20', 349.99, 'delivered');

INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES 
(1, 1, 1, 999.99),
(2, 2, 1, 849.99),
(2, 4, 1, 349.99),
(3, 5, 1, 599.99),
(4, 3, 1, 1199.99),
(4, 4, 1, 349.99),
(5, 4, 1, 349.99);


INSERT INTO customers (name, email, phone) VALUES 
('Duplicate Email', 'john.smith@email.com', '+1-555-9999'); -- error: unique email

INSERT INTO products (name, price, stock_quantity) VALUES 
('Invalid Product', -10.00, 5), -- error: negative price
('Invalid Stock', 50.00, -5); -- error: negative stock

INSERT INTO orders (customer_id, total_amount, status) VALUES 
(1, 100.00, 'invalid_status'); -- error: invalid status

INSERT INTO orders (customer_id, total_amount, status) VALUES 
(999, 100.00, 'pending'); -- error: foreign customer_id

INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES 
(1, 999, 1, 100.00); -- error: foreign product_id

DELETE FROM orders WHERE order_id = 1;
SELECT COUNT(*) FROM order_details WHERE order_id = 1; -- DELETE CASCADE

DELETE FROM customers WHERE customer_id = 1; -- DELETE RESTRICT

INSERT INTO customers (name, email) VALUES (NULL, 'test@email.com'); -- error: email NOT NULL