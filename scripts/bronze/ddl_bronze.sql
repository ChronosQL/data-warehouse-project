/*
===============================================================================
DDL Script: Create Bronze Tables (PostgreSQL)
===============================================================================
Script Purpose:
    This script creates raw landing tables in the 'bronze' schema.
    
    Medallion Architecture Bronze Layer Rules:
    1. Mirrors the structure of the operational source system.
    2. Drops existing tables before recreation for idempotent builds.
    3. Excludes restrictive Foreign Key constraints to ensure raw ingestion
       never fails on dirty or out-of-sequence source records.
    4. Includes the '_ingested_at' audit column (TIMESTAMPTZ) recording the exact arrival timestamp.
===============================================================================
*/

-- Ensure Warehouse Schemas and Extensions Exist
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- =========================================================
-- Drop Existing Bronze Tables
-- =========================================================
DROP TABLE IF EXISTS bronze.chat_message CASCADE;
DROP TABLE IF EXISTS bronze.chat_topic CASCADE;
DROP TABLE IF EXISTS bronze.contact_reply CASCADE;
DROP TABLE IF EXISTS bronze.contact_inquiry CASCADE;
DROP TABLE IF EXISTS bronze.review_image CASCADE;
DROP TABLE IF EXISTS bronze.review CASCADE;
DROP TABLE IF EXISTS bronze.payment CASCADE;
DROP TABLE IF EXISTS bronze.booking_package CASCADE;
DROP TABLE IF EXISTS bronze.booking CASCADE;
DROP TABLE IF EXISTS bronze.package_place CASCADE;
DROP TABLE IF EXISTS bronze.package CASCADE;
DROP TABLE IF EXISTS bronze.place_activity CASCADE;
DROP TABLE IF EXISTS bronze.activity CASCADE;
DROP TABLE IF EXISTS bronze.place CASCADE;
DROP TABLE IF EXISTS bronze.vehicle CASCADE;
DROP TABLE IF EXISTS bronze.vehicle_category CASCADE;
DROP TABLE IF EXISTS bronze."user" CASCADE;

-- =========================================================
-- Bronze: User & Authentication
-- =========================================================
CREATE TABLE bronze."user" (
    user_id                 INTEGER,
    name                    VARCHAR(100),
    email                   VARCHAR(100),
    password_hash           VARCHAR(255),
    role                    VARCHAR(50),
    contact_number          VARCHAR(20),
    street_address          VARCHAR(255),
    country                 VARCHAR(100),
    zipcode                 VARCHAR(20),
    emergency_name          VARCHAR(150),
    emergency_phone         VARCHAR(30),
    emergency_relationship  VARCHAR(50),
    auth_provider           VARCHAR(50),
    provider_id             VARCHAR(255),
    status                  VARCHAR(50),
    created_at              TIMESTAMPTZ,
    updated_at              TIMESTAMPTZ,
    _ingested_at            TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Bronze: Fleet & Vehicles
-- =========================================================
CREATE TABLE bronze.vehicle_category (
    category_id         INTEGER,
    category_name       VARCHAR(50),
    description         TEXT,
    image_url           TEXT,
    passenger_capacity  VARCHAR(50),
    luggage_capacity    VARCHAR(50),
    best_for            VARCHAR(255),
    comfort_level       VARCHAR(100),
    ac_available        BOOLEAN,
    ideal_trip_types    VARCHAR(255),
    _ingested_at        TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE bronze.vehicle (
    vehicle_id           INTEGER,
    category_id          INTEGER,
    vehicle_number       VARCHAR(50),
    vehicle_license      VARCHAR(100),
    name                 VARCHAR(255),
    color                VARCHAR(50),
    manufactured_year    INTEGER,
    adult_seats          INTEGER,
    baby_seats           INTEGER,
    luggage_capacity     INTEGER,
    price_per_day        NUMERIC(10,2),
    insurance_provider   VARCHAR(100),
    insurance_start_date DATE,
    insurance_end_date   DATE,
    image_url            VARCHAR(255),
    vehicle_status       VARCHAR(50),
    brand                VARCHAR(100),
    model                VARCHAR(100),
    fuel_type            VARCHAR(50),
    transmission         VARCHAR(50),
    air_conditioning     BOOLEAN,
    mileage              INTEGER,
    engine_capacity      VARCHAR(50),
    features             TEXT,
    _ingested_at         TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Bronze: Places & Activities
-- =========================================================
CREATE TABLE bronze.place (
    place_id     INTEGER,
    place_name   VARCHAR(100),
    image_url    VARCHAR(255),
    description  TEXT,
    latitude     NUMERIC(10, 7),
    longitude    NUMERIC(10, 7),
    geom         GEOMETRY(Point, 4326),
    _ingested_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE bronze.activity (
    activity_id   INTEGER,
    activity_name VARCHAR(100),
    phone         VARCHAR(20),
    description   TEXT,
    _ingested_at  TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE bronze.place_activity (
    id           INTEGER,
    place_id     INTEGER,
    activity_id  INTEGER,
    _ingested_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Bronze: Packages
-- =========================================================
CREATE TABLE bronze.package (
    package_id          INTEGER,
    title               VARCHAR(150),
    type                VARCHAR(50),
    days                VARCHAR(50),
    description         TEXT,
    weather             JSON,
    image_url           VARCHAR(255),
    availability_status VARCHAR(50),
    _ingested_at        TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE bronze.package_place (
    id           INTEGER,
    package_id   INTEGER,
    place_id     INTEGER,
    day_number   INTEGER,
    _ingested_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Bronze: Bookings & Payments
-- =========================================================
CREATE TABLE bronze.booking (
    booking_id         INTEGER,
    user_id            INTEGER,
    customer_name      VARCHAR(100),
    contact_platform   VARCHAR(30),
    contact_number     VARCHAR(150),
    contact_platform2  VARCHAR(30),
    contact_number2    VARCHAR(150),
    tour_type          VARCHAR(50),
    category_id        INTEGER,
    vehicle_id         INTEGER,
    start_date         DATE,
    end_date           DATE,
    pickup_time        TIME,
    start_location     VARCHAR(100),
    end_location       VARCHAR(100),
    total_days         INTEGER,
    days_required      INTEGER,
    luggage_10kg       INTEGER,
    luggage_25kg       INTEGER,
    luggage_35kg       INTEGER,
    no_of_adults       INTEGER,
    no_of_children     INTEGER,
    ages_of_children   TEXT,
    quoted_price       NUMERIC(10,2),
    additional_charges NUMERIC(10,2),
    notes              TEXT,
    tour_thoughts      TEXT,
    admin_note         TEXT,
    booking_date       DATE,
    booking_status     VARCHAR(50),
    quoted_at          TIMESTAMPTZ,
    confirmed_at       TIMESTAMPTZ,
    tour_started_at    TIMESTAMPTZ,
    completed_at       TIMESTAMPTZ,
    closed_at          TIMESTAMPTZ,
    _ingested_at       TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE bronze.booking_package (
    id           INTEGER,
    booking_id   INTEGER,
    package_id   INTEGER,
    _ingested_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE bronze.payment (
    payment_id     INTEGER,
    booking_id     INTEGER,
    amount         NUMERIC(10,2),
    payment_method VARCHAR(50),
    received_date  DATE,
    recorded_by    INTEGER,
    notes          TEXT,
    _ingested_at   TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Bronze: Reviews
-- =========================================================
CREATE TABLE bronze.review (
    review_id    INTEGER,
    user_id      INTEGER,
    booking_id   INTEGER,
    rating       INTEGER,
    driver_name  VARCHAR(100),
    title        VARCHAR(150),
    feedback     TEXT,
    created_at   TIMESTAMPTZ,
    _ingested_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE bronze.review_image (
    image_id     INTEGER,
    review_id    INTEGER,
    image_url    VARCHAR(255),
    _ingested_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Bronze: Support & Inquiries
-- =========================================================
CREATE TABLE bronze.contact_inquiry (
    inquiry_id   INTEGER,
    sender_name  VARCHAR(100),
    sender_email VARCHAR(100),
    sender_phone VARCHAR(20),
    subject      VARCHAR(100),
    message      TEXT,
    is_read      BOOLEAN,
    status       VARCHAR(50),
    submitted_at TIMESTAMPTZ,
    _ingested_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE bronze.contact_reply (
    reply_id     INTEGER,
    inquiry_id   INTEGER,
    sender_role  VARCHAR(50),
    sender_name  VARCHAR(100),
    message      TEXT,
    sent_at      TIMESTAMPTZ,
    _ingested_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- =========================================================
-- Bronze: Chat System
-- =========================================================
CREATE TABLE bronze.chat_topic (
    topic_id     INTEGER,
    user_id      INTEGER,
    subject      VARCHAR(100),
    created_at   TIMESTAMPTZ,
    _ingested_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE TABLE bronze.chat_message (
    message_id   INTEGER,
    topic_id     INTEGER,
    sender_id    INTEGER,
    message      TEXT,
    sent_at      TIMESTAMPTZ,
    _ingested_at TIMESTAMPTZ DEFAULT clock_timestamp()
);
