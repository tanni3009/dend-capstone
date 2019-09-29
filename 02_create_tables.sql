/*
    This script contains all necessary SQL statements to create the student DB and related tables.
*/

-- creating the DB
DROP DATABASE IF EXISTS studentdb;
CREATE DATABASE studentdb WITH ENCODING 'utf8' TEMPLATE template0;

-- creating tables
DROP TABLE IF EXISTS fact_student_mobility;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_institution;


CREATE TABLE IF NOT EXISTS dim_institution (
    institution_code TEXT PRIMARY KEY,
    application_reference_number TEXT NOT NULL,
    organisation_name TEXT,
    country CHAR(2),
    city TEXT
);

CREATE TABLE IF NOT EXISTS dim_date (
    year_month_code CHAR(7) PRIMARY KEY,
    month_number SMALLINT NOT NULL,
    month_name TEXT NOT NULL,
    year_number SMALLINT NOT NULL,
    academic_year CHAR(7) NOT NULL
);

CREATE TABLE IF NOT EXISTS fact_student_mobility (
    home_institution_code TEXT NOT NULL,
    host_institution_code TEXT,
    mobility_type CHAR(1) NOT NULL,
    student_age SMALLINT,
    student_gender CHAR(1),
    student_nationality CHAR(2),
    student_level CHAR(1),
    student_years_prior SMALLINT,
    student_previous_participation CHAR(1),
    work_placement TEXT,
    work_placement_country CHAR(2),
    length_study DECIMAL(4,2),
    length_work DECIMAL(4,2),
    short_duration_reason CHAR(1),
    study_start_date CHAR(7) REFERENCES dim_date(year_month_code),
    work_start_date CHAR(7) REFERENCES dim_date(year_month_code),
    combined_start_date CHAR(7),
    ects_study SMALLINT,
    ects_work SMALLINT,
    ects_total SMALLINT,
    sn_supplement DECIMAL(8,2),
    study_grant DECIMAL(8,2),
    work_grant DECIMAL(8,2),
    total_grant DECIMAL(8,2)
);
