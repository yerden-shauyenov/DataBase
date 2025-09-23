-- Task 1.1
CREATE DATABASE university_main
	WITH
	TEMPLATE = template0
	ENCODING = 'UTF8'
	CONNECTION LIMIT = -1;

CREATE DATABASE unniversity_archive
	WITH
	TEMPLATE = template0
	CONNECTION LIMIT = 50;

CREATE DATABASE university_test
	WITH
	TEMPLATE = template0
	CONNECTION LIMIT = 10
	IS_TEMPLATE = true;


-- Task 1.2
-- 1)
CREATE TABLESPACE student_data
	LOCATION '/data/students';

-- 2)
CREATE TABLESPACE course_data
	LOCATION '/data/courses'
	OWNER CURRENT_USER;

-- 3)
CREATE DATABASE university_distributed
	WITH
	TABLESPACE = student_data
	ENCODING = 'LATIN9'
	LC_CTYPE = 'C'
	LC_COLLATE = 'C'
    TEMPLATE = template0
	CONNECTION LIMIT = -1;


-- Task 2.1
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa DECIMAL(4, 2) CHECK (gpa >= 0 AND gpa <= 4.0),
    is_active BOOLEAN DEFAULT TRUE,
    graduation_year SMALLINT
);

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    office_number VARCHAR(20),
    hire_date DATE,
    salary DECIMAL(10, 2) CHECK (salary >= 0),
    is_tenured BOOLEAN DEFAULT FALSE,
    years_experience INTEGER DEFAULT 0
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8) UNIQUE NOT NULL,
    course_title VARCHAR(100) NOT NULL,
    description TEXT,
    credits SMALLINT CHECK (credits > 0 AND credits <= 10),
    max_enrollment INTEGER DEFAULT 30,
    course_fee DECIMAL(8, 2) DEFAULT 0.00,
    is_online BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL,
    professor_id INTEGER NOT NULL,
    classroom VARCHAR(20),
    class_date DATE NOT NULL,
    start_time TIME WITHOUT TIME ZONE NOT NULL,
    end_time TIME WITHOUT TIME ZONE NOT NULL,
    duration INTERVAL GENERATED ALWAYS AS (end_time - start_time) STORED,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (professor_id) REFERENCES professors(professor_id),
    CHECK (end_time > start_time)
);

CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    semester VARCHAR(20) NOT NULL,
    year INTEGER NOT NULL CHECK (year >= 2000 AND year <= 2100),
    grade CHAR(2) CHECK (grade IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D')),
    attendance_percentage DECIMAL(4, 1) CHECK (attendance_percentage >= 0 AND attendance_percentage <= 100),
    submission_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE (student_id, course_id, semester, year)
);


-- Task 3.1
ALTER TABLE students
    ADD COLUMN middle_name VARCHAR(30),
    ADD COLUMN student_status VARCHAR(20),
    ALTER COLUMN phone TYPE VARCHAR(20),
    ALTER COLUMN student_status SET DEFAULT 'ACTIVE',
    ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors
    ADD COLUMN department_code CHAR(5),
    ADD COLUMN research_area TEXT,
    ALTER COLUMN years_experience TYPE SMALLINT,
    ALTER COLUMN is_tenured SET DEFAULT FALSE,
    ADD COLUMN last_promotion_date DATE;

ALTER TABLE courses
    ADD COLUMN prerequisite_course_id INTEGER,
    ADD COLUMN difficulty_level SMALLINT,
    ALTER COLUMN course_code TYPE VARCHAR(10),
    ALTER COLUMN credits SET DEFAULT 3,
    ADD COLUMN lab_required BOOLEAN DEFAULT FALSE;


-- Task 3.2
ALTER TABLE class_schedule
    ADD COLUMN room_capacity INTEGER,
    DROP COLUMN duration,
    ADD COLUMN session_type VARCHAR(15),
    ALTER COLUMN classroom TYPE VARCHAR(30),
    ADD COLUMN equipment_needed TEXT;

ALTER TABLE student_records
    ADD COLUMN extra_credit_points DECIMAL(4, 1),
    ALTER COLUMN grade TYPE VARCHAR(5),
    ALTER COLUMN extra_credit_points SET DEFAULT 0.0,
    ADD COLUMN final_exam_date DATE,
    DROP COLUMN last_updated;


-- Task 4.1
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_code CHAR(5) UNIQUE NOT NULL,
    building VARCHAR(50),
    phone VARCHAR(15),
    budget DECIMAL(12, 2) CHECK (budget >= 0),
    established_year INTEGER CHECK (established_year >= 1800 AND established_year <= EXTRACT(YEAR FROM CURRENT_DATE))
);

CREATE TABLE library_books (
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    publisher VARCHAR(100),
    publication_date DATE,
    price DECIMAL(8, 2) CHECK (price >= 0),
    is_available BOOLEAN DEFAULT TRUE,
    acquisition_timestamp TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE student_book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    loan_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    return_date DATE,
    fine_amount DECIMAL(8, 2) DEFAULT 0.00 CHECK (fine_amount >= 0),
    loan_status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (loan_status IN ('ACTIVE', 'RETURNED', 'OVERDUE', 'LOST')),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (book_id) REFERENCES library_books(book_id),
    CHECK (due_date > loan_date),
    CHECK (return_date IS NULL OR return_date >= loan_date)
);


-- Task 4.2
ALTER TABLE professors
    ADD COLUMN department_id INTEGER;

ALTER TABLE students
    ADD COLUMN advisor_id INTEGER;

ALTER TABLE courses
    ADD COLUMN department_id INTEGER;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2) UNIQUE NOT NULL,
    min_percentage DECIMAL(4, 1) CHECK (min_percentage >= 0 AND min_percentage <= 100),
    max_percentage DECIMAL(4, 1) CHECK (max_percentage >= 0 AND max_percentage <= 100),
    gpa_points DECIMAL(3, 2) CHECK (gpa_points >= 0 AND gpa_points <= 4.0),
    CHECK (min_percentage <= max_percentage)
);

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20) NOT NULL,
    academic_year INTEGER NOT NULL CHECK (academic_year >= 2000 AND academic_year <= 2100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN DEFAULT FALSE,
    CHECK (end_date > start_date),
    CHECK (registration_deadline IS NULL OR registration_deadline <= start_date),
    UNIQUE (semester_name, academic_year)
);


-- Task 5.1
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2) UNIQUE NOT NULL,
    min_percentage DECIMAL(4, 1) CHECK (min_percentage >= 0 AND min_percentage <= 100),
    max_percentage DECIMAL(4, 1) CHECK (max_percentage >= 0 AND max_percentage <= 100),
    gpa_points DECIMAL(3, 2) CHECK (gpa_points >= 0 AND gpa_points <= 4.0),
    description TEXT,
    CHECK (min_percentage <= max_percentage)
);

DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20) NOT NULL,
    academic_year INTEGER NOT NULL CHECK (academic_year >= 2000 AND academic_year <= 2100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN DEFAULT FALSE,
    CHECK (end_date > start_date),
    CHECK (registration_deadline IS NULL OR registration_deadline <= start_date),
    UNIQUE (semester_name, academic_year)
);


-- Task 5.2
ALTER DATABASE university_test WITH IS_TEMPLATE = false;

DROP DATABASE IF EXISTS university_test;

DROP DATABASE IF EXISTS university_distributed

SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'university_main';

CREATE DATABASE university_backup
    WITH 
    TEMPLATE = university_main
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;