/*
===============================================================================
DDL Script: Create Silver Tables (PostgreSQL)
===============================================================================
Script Purpose:
    This script creates the cleansed, typed, and standardized tables in the 'silver' schema.
    
    Medallion Architecture Silver Layer Rules:
    1. Schema Enforcement: Strict data types, primary keys, and uniqueness constraints.
    2. Cleansed & Standardized: Casing normalized, whitespace trimmed, nulls handled.
    3. Enriched Columns: Derived business fields (e.g., total_price, total_passengers).
    4. Audit Metadata: Tracks when records were transformed into Silver via '_loaded_at'.
===============================================================================
*/

CREATE SCHEMA IF NOT EXISTS silver;

-- =========================================================
-- Drop Existing Silver Tables
-- =========================================================
DROP TABLE IF EXISTS silver.chat_message CASCADE;
DROP TABLE IF EXISTS silver.chat_topic CASCADE;
DROP TABLE IF EXISTS silver.contact_reply CASCADE;
DROP TABLE IF EXISTS silver.contact_inquiry CASCADE;
DROP TABLE IF EXISTS silver.review_image CASCADE;
DROP TABLE IF EXISTS silver.review CASCADE;
DROP TABLE IF EXISTS silver.payment CASCADE;
DROP TABLE IF EXISTS silver.booking_package CASCADE;
DROP TABLE IF EXISTS silver.booking CASCADE;
DROP TABLE IF EXISTS silver.package_place CASCADE;
DROP TABLE IF EXISTS silver.package CASCADE;
DROP TABLE IF EXISTS silver.place_activity CASCADE;
DROP TABLE IF EXISTS silver.activity CASCADE;
DROP TABLE IF EXISTS silver.place CASCADE;
DROP TABLE IF EXISTS silver.city CASCADE;
DROP TABLE IF EXISTS silver.vehicle CASCADE;
DROP TABLE IF EXISTS silver.vehicle_category CASCADE;
DROP TABLE IF EXISTS silver."user" CASCADE;

-- =========================================================
-- Silver: User & Authentication
-- =========================================================
CREATE TABLE silver."user" (
    user_id                 INTEGER PRIMARY KEY,
    name                    VARCHAR(100) NOT NULL,
    first_name              VARCHAR(50),
    last_name               VARCHAR(50),
    email                   VARCHAR(100) NOT NULL UNIQUE,
    password_hash           VARCHAR(255),
    role                    VARCHAR(50) NOT NULL DEFAULT 'CUSTOMER',
    contact_number          VARCHAR(20),
    street_address          VARCHAR(255),
    country                 VARCHAR(100),
    zipcode                 VARCHAR(20),
    emergency_name          VARCHAR(150),
    emergency_phone         VARCHAR(30),
    emergency_relationship  VARCHAR(50),
    auth_provider           VARCHAR(50) NOT NULL DEFAULT 'LOCAL',
    provider_id             VARCHAR(255),
    status                  VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMPTZ,
    updated_at              TIMESTAMPTZ,
    _loaded_at              TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Silver: Fleet & Vehicles
-- =========================================================
CREATE TABLE silver.vehicle_category (
    category_id         INTEGER PRIMARY KEY,
    category_name       VARCHAR(50) NOT NULL,
    description         TEXT,
    image_url           TEXT,
    passenger_capacity  VARCHAR(50),
    luggage_capacity    VARCHAR(50),
    best_for            VARCHAR(255),
    comfort_level       VARCHAR(100),
    ac_available        BOOLEAN NOT NULL DEFAULT FALSE,
    ideal_trip_types    VARCHAR(255),
    _loaded_at          TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE silver.vehicle (
    vehicle_id           INTEGER PRIMARY KEY,
    category_id          INTEGER NOT NULL REFERENCES silver.vehicle_category(category_id),
    vehicle_number       VARCHAR(50) NOT NULL UNIQUE,
    vehicle_license      VARCHAR(100),
    name                 VARCHAR(255),
    color                VARCHAR(50),
    manufactured_year    INTEGER,
    adult_seats          INTEGER NOT NULL DEFAULT 1,
    baby_seats           INTEGER NOT NULL DEFAULT 0,
    luggage_capacity     INTEGER NOT NULL DEFAULT 0,
    price_per_day        NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    insurance_provider   VARCHAR(100),
    insurance_start_date DATE,
    insurance_end_date   DATE,
    is_insured                 BOOLEAN DEFAULT FALSE,
    is_valid_insurance_dates   BOOLEAN NOT NULL DEFAULT TRUE,
    image_url            VARCHAR(255),
    vehicle_status       VARCHAR(50) NOT NULL DEFAULT 'AVAILABLE',
    brand                VARCHAR(100),
    model                VARCHAR(100),
    fuel_type            VARCHAR(50),
    transmission         VARCHAR(50),
    air_conditioning     BOOLEAN NOT NULL DEFAULT FALSE,
    mileage              INTEGER DEFAULT 0,
    engine_capacity      VARCHAR(50),
    features             TEXT,
    _loaded_at           TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Silver: Places & Activities
-- =========================================================
CREATE TABLE silver.city (
    id           INTEGER PRIMARY KEY,
    name         VARCHAR(100) NOT NULL UNIQUE,
    created_at   TIMESTAMPTZ,
    _loaded_at   TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE silver.place (
    place_id     INTEGER PRIMARY KEY,
    place_name   VARCHAR(100) NOT NULL,
    image_url    VARCHAR(255),
    description  TEXT,
    _loaded_at   TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE silver.activity (
    activity_id   INTEGER PRIMARY KEY,
    activity_name VARCHAR(100) NOT NULL,
    phone         VARCHAR(20),
    description   TEXT,
    _loaded_at    TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE silver.place_activity (
    id           INTEGER PRIMARY KEY,
    place_id     INTEGER NOT NULL REFERENCES silver.place(place_id),
    activity_id  INTEGER NOT NULL REFERENCES silver.activity(activity_id),
    _loaded_at   TIMESTAMPTZ DEFAULT clock_timestamp(),
    CONSTRAINT uq_silver_place_activity UNIQUE (place_id, activity_id)
);

-- =========================================================
-- Silver: Packages
-- =========================================================
CREATE TABLE silver.package (
    package_id          INTEGER PRIMARY KEY,
    title               VARCHAR(150) NOT NULL,
    type                VARCHAR(50) NOT NULL,
    days                VARCHAR(50) NOT NULL,
    description         TEXT,
    image_url           VARCHAR(255),
    availability_status VARCHAR(50) NOT NULL DEFAULT 'AVAILABLE',
    is_available        BOOLEAN NOT NULL DEFAULT TRUE,
    _loaded_at          TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE silver.package_place (
    id           INTEGER PRIMARY KEY,
    package_id   INTEGER NOT NULL REFERENCES silver.package(package_id),
    place_id     INTEGER NOT NULL REFERENCES silver.place(place_id),
    day_number   INTEGER NOT NULL,
    _loaded_at   TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Silver: Bookings & Payments
-- =========================================================
CREATE TABLE silver.booking (
    booking_id           INTEGER PRIMARY KEY,
    user_id              INTEGER NOT NULL REFERENCES silver."user"(user_id),
    customer_name        VARCHAR(100) NOT NULL,
    contact_platform     VARCHAR(30) NOT NULL DEFAULT 'mobile',
    contact_number       VARCHAR(150) NOT NULL,
    contact_platform2    VARCHAR(30),
    contact_number2      VARCHAR(150),
    tour_type            VARCHAR(50) NOT NULL,
    category_id          INTEGER NOT NULL REFERENCES silver.vehicle_category(category_id),
    vehicle_id           INTEGER REFERENCES silver.vehicle(vehicle_id),
    start_date           DATE NOT NULL,
    end_date             DATE NOT NULL,
    pickup_time          TIME,
    start_location       VARCHAR(100),
    end_location         VARCHAR(100),
    total_days           INTEGER NOT NULL,
    days_required        INTEGER NOT NULL,
    total_passengers     INTEGER NOT NULL DEFAULT 1,
    no_of_adults         INTEGER NOT NULL DEFAULT 1,
    no_of_children       INTEGER NOT NULL DEFAULT 0,
    ages_of_children     TEXT,
    total_luggage_count  INTEGER NOT NULL DEFAULT 0,
    luggage_10kg         INTEGER NOT NULL DEFAULT 0,
    luggage_25kg         INTEGER NOT NULL DEFAULT 0,
    luggage_35kg         INTEGER NOT NULL DEFAULT 0,
    quoted_price         NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    additional_charges   NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    total_price          NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    notes                TEXT,
    tour_thoughts        TEXT,
    admin_note           TEXT,
    booking_date         DATE NOT NULL,
    booking_status       VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    is_confirmed         BOOLEAN NOT NULL DEFAULT FALSE,
    is_completed         BOOLEAN NOT NULL DEFAULT FALSE,
    is_valid_date_range  BOOLEAN NOT NULL DEFAULT TRUE,
    quoted_at            TIMESTAMPTZ,
    confirmed_at         TIMESTAMPTZ,
    tour_started_at      TIMESTAMPTZ,
    completed_at         TIMESTAMPTZ,
    closed_at            TIMESTAMPTZ,
    _loaded_at           TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE silver.booking_package (
    id           INTEGER PRIMARY KEY,
    booking_id   INTEGER NOT NULL UNIQUE REFERENCES silver.booking(booking_id),
    package_id   INTEGER NOT NULL REFERENCES silver.package(package_id),
    _loaded_at   TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE silver.payment (
    payment_id     INTEGER PRIMARY KEY,
    booking_id     INTEGER NOT NULL REFERENCES silver.booking(booking_id),
    installment    VARCHAR(50) NOT NULL,
    amount         NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    payment_method VARCHAR(50) NOT NULL,
    received_date  DATE NOT NULL,
    recorded_by    INTEGER NOT NULL REFERENCES silver."user"(user_id),
    notes          TEXT,
    _loaded_at     TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Silver: Reviews
-- =========================================================
CREATE TABLE silver.review (
    review_id    INTEGER PRIMARY KEY,
    user_id      INTEGER NOT NULL REFERENCES silver."user"(user_id),
    booking_id   INTEGER NOT NULL UNIQUE REFERENCES silver.booking(booking_id),
    rating       INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    driver_name  VARCHAR(100),
    title        VARCHAR(150),
    feedback     TEXT,
    created_at   TIMESTAMPTZ,
    _loaded_at   TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE silver.review_image (
    image_id     INTEGER PRIMARY KEY,
    review_id    INTEGER NOT NULL REFERENCES silver.review(review_id),
    image_url    VARCHAR(255) NOT NULL,
    _loaded_at   TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Silver: Support & Inquiries
-- =========================================================
CREATE TABLE silver.contact_inquiry (
    inquiry_id   INTEGER PRIMARY KEY,
    sender_name  VARCHAR(100) NOT NULL,
    sender_email VARCHAR(100) NOT NULL,
    sender_phone VARCHAR(20),
    subject      VARCHAR(100),
    message      TEXT NOT NULL,
    is_read      BOOLEAN NOT NULL DEFAULT FALSE,
    status       VARCHAR(50) NOT NULL DEFAULT 'new',
    submitted_at TIMESTAMPTZ,
    _loaded_at   TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE silver.contact_reply (
    reply_id     INTEGER PRIMARY KEY,
    inquiry_id   INTEGER NOT NULL REFERENCES silver.contact_inquiry(inquiry_id) ON DELETE CASCADE,
    sender_role  VARCHAR(50) NOT NULL,
    sender_name  VARCHAR(100) NOT NULL,
    message      TEXT NOT NULL,
    sent_at      TIMESTAMPTZ,
    _loaded_at   TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Silver: Chat System
-- =========================================================
CREATE TABLE silver.chat_topic (
    topic_id     INTEGER PRIMARY KEY,
    user_id      INTEGER NOT NULL REFERENCES silver."user"(user_id),
    subject      VARCHAR(100),
    created_at   TIMESTAMPTZ,
    _loaded_at   TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE silver.chat_message (
    message_id   INTEGER PRIMARY KEY,
    topic_id     INTEGER NOT NULL REFERENCES silver.chat_topic(topic_id),
    sender_id    INTEGER NOT NULL REFERENCES silver."user"(user_id),
    message      TEXT NOT NULL,
    sent_at      TIMESTAMPTZ,
    _loaded_at   TIMESTAMPTZ DEFAULT clock_timestamp()
);
