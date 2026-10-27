/*
===============================================================================
DDL Script: Create Gold Views & Dimensional Models (PostgreSQL)
===============================================================================
Script Purpose:
    This script creates the analytical Gold layer in the 'gold' schema.
    
    Medallion Architecture Gold Layer Rules:
    1. Business-level consumption layer structured into an Enterprise Star Schema.
    2. Implemented as performant analytical views over cleansed Silver tables.
    3. Optimized for Business Intelligence tools (Metabase, Power BI, Tableau).
===============================================================================
*/

CREATE SCHEMA IF NOT EXISTS gold;

-- =========================================================
-- 1. Dimension: Conformed Calendar & Tourism Seasonality
-- =========================================================
CREATE OR REPLACE VIEW gold.dim_date AS
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_key,
    d::DATE AS calendar_date,
    EXTRACT(YEAR FROM d)::INTEGER AS year,
    EXTRACT(QUARTER FROM d)::INTEGER AS quarter,
    EXTRACT(MONTH FROM d)::INTEGER AS month,
    TRIM(TO_CHAR(d, 'Month')) AS month_name,
    EXTRACT(WEEK FROM d)::INTEGER AS week_of_year,
    EXTRACT(DAY FROM d)::INTEGER AS day_of_month,
    EXTRACT(ISODOW FROM d)::INTEGER AS day_of_week,
    TRIM(TO_CHAR(d, 'Day')) AS day_name,
    CASE WHEN EXTRACT(ISODOW FROM d) IN (6, 7) THEN TRUE ELSE FALSE END AS is_weekend,
    CASE
        WHEN EXTRACT(MONTH FROM d) IN (12, 1, 2, 3, 4) THEN 'PEAK_WINTER'
        WHEN EXTRACT(MONTH FROM d) IN (7, 8) THEN 'SUMMER_PEAK'
        ELSE 'OFF_PEAK_MONSOON'
    END AS tourism_season
FROM generate_series('2022-01-01'::DATE, '2028-12-31'::DATE, '1 day'::INTERVAL) d;

-- =========================================================
-- 2. Dimension: Customers (Travelers)
-- =========================================================
CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT
    u.user_id AS customer_key,
    u.user_id AS customer_id,
    u.name AS customer_name,
    u.first_name,
    u.last_name,
    u.email,
    u.contact_number,
    u.country,
    u.auth_provider,
    u.is_active,
    u.created_at AS registered_at,
    COALESCE(b_stats.total_bookings, 0) AS total_bookings,
    COALESCE(b_stats.total_spend, 0.00) AS total_spend,
    CASE 
        WHEN COALESCE(b_stats.total_spend, 0) >= 3000 THEN 'VIP Traveler'
        WHEN COALESCE(b_stats.total_spend, 0) >= 1000 THEN 'Regular Traveler'
        WHEN COALESCE(b_stats.total_bookings, 0) > 0  THEN 'Standard Traveler'
        ELSE 'Prospect'
    END AS customer_tier,
    b_stats.first_booking_date,
    b_stats.last_booking_date
FROM silver."user" u
LEFT JOIN (
    SELECT 
        user_id,
        COUNT(booking_id) AS total_bookings,
        SUM(total_price) AS total_spend,
        MIN(booking_date) AS first_booking_date,
        MAX(booking_date) AS last_booking_date
    FROM silver.booking
    GROUP BY user_id
) b_stats ON b_stats.user_id = u.user_id
WHERE u.role = 'CUSTOMER';

-- =========================================================
-- 3. Dimension: Fleet & Vehicles
-- =========================================================
CREATE OR REPLACE VIEW gold.dim_vehicles AS
SELECT
    v.vehicle_id AS vehicle_key,
    v.vehicle_id,
    v.vehicle_number,
    v.name AS vehicle_name,
    vc.category_name,
    v.brand,
    v.model,
    v.color,
    v.manufactured_year,
    v.fuel_type,
    v.transmission,
    v.air_conditioning,
    v.adult_seats,
    v.baby_seats,
    v.luggage_capacity,
    v.price_per_day,
    vc.comfort_level,
    vc.best_for,
    v.vehicle_status,
    v.insurance_provider,
    v.is_insured
FROM silver.vehicle v
INNER JOIN silver.vehicle_category vc ON vc.category_id = v.category_id;

-- =========================================================
-- 4. Dimension: Destinations (Places & Tourist Hubs)
-- =========================================================
CREATE OR REPLACE VIEW gold.dim_destinations AS
SELECT
    p.place_id AS destination_key,
    p.place_id,
    p.place_name,
    p.latitude,
    p.longitude,
    p.description,
    p.image_url,
    COALESCE(pp_stats.package_inclusions, 0) AS total_package_routes,
    COALESCE(act_stats.total_activities, 0) AS available_activities
FROM silver.place p
LEFT JOIN (
    SELECT place_id, COUNT(*) AS package_inclusions
    FROM silver.package_place
    GROUP BY place_id
) pp_stats ON pp_stats.place_id = p.place_id
LEFT JOIN (
    SELECT place_id, COUNT(*) AS total_activities
    FROM silver.place_activity
    GROUP BY place_id
) act_stats ON act_stats.place_id = p.place_id;

-- =========================================================
-- 5. Dimension: Tour Packages
-- =========================================================
CREATE OR REPLACE VIEW gold.dim_packages AS
SELECT
    p.package_id AS package_key,
    p.package_id,
    p.title AS package_title,
    p.type AS package_type,
    p.days AS package_duration,
    p.availability_status,
    p.is_available,
    p.image_url,
    COALESCE(dest_stats.total_stops, 0) AS total_stops
FROM silver.package p
LEFT JOIN (
    SELECT package_id, COUNT(*) AS total_stops
    FROM silver.package_place
    GROUP BY package_id
) dest_stats ON dest_stats.package_id = p.package_id;

-- =========================================================
-- 6. Dimension: Tourist Activities & Experiences
-- =========================================================
CREATE OR REPLACE VIEW gold.dim_activities AS
SELECT
    a.activity_id AS activity_key,
    a.activity_id,
    a.activity_name,
    a.phone,
    a.description,
    COALESCE(pa_stats.total_hosted_places, 0) AS total_hosted_places,
    COALESCE(pkg_stats.total_package_inclusions, 0) AS total_package_inclusions,
    CASE
        WHEN LOWER(a.activity_name) LIKE '%safari%' OR LOWER(a.activity_name) LIKE '%wildlife%' OR LOWER(a.activity_name) LIKE '%whale%' THEN 'Wildlife & Nature'
        WHEN LOWER(a.activity_name) LIKE '%surf%' OR LOWER(a.activity_name) LIKE '%raft%' OR LOWER(a.activity_name) LIKE '%hik%' OR LOWER(a.activity_name) LIKE '%trek%' THEN 'Adventure & Sports'
        WHEN LOWER(a.activity_name) LIKE '%temple%' OR LOWER(a.activity_name) LIKE '%cultur%' OR LOWER(a.activity_name) LIKE '%herit%' OR LOWER(a.activity_name) LIKE '%tea%' THEN 'Cultural & Heritage'
        ELSE 'Leisure & Sightseeing'
    END AS activity_category
FROM silver.activity a
LEFT JOIN (
    SELECT activity_id, COUNT(DISTINCT place_id) AS total_hosted_places
    FROM silver.place_activity
    GROUP BY activity_id
) pa_stats ON pa_stats.activity_id = a.activity_id
LEFT JOIN (
    SELECT pa.activity_id, COUNT(DISTINCT pp.package_id) AS total_package_inclusions
    FROM silver.place_activity pa
    JOIN silver.package_place pp ON pp.place_id = pa.place_id
    GROUP BY pa.activity_id
) pkg_stats ON pkg_stats.activity_id = a.activity_id;

-- =========================================================
-- 7. Fact: Bookings Transactions
-- =========================================================
CREATE OR REPLACE VIEW gold.fact_bookings AS
SELECT
    b.booking_id,
    TO_CHAR(b.booking_date, 'YYYYMMDD')::INTEGER AS booking_date_key,
    b.user_id AS customer_key,
    b.vehicle_id AS vehicle_key,
    b.category_id,
    bp.package_id AS package_key,
    b.booking_date,
    b.start_date,
    b.end_date,
    b.total_days,
    b.days_required,
    b.tour_type,
    b.booking_status,
    b.is_confirmed,
    b.is_completed,
    b.total_passengers,
    b.no_of_adults,
    b.no_of_children,
    b.total_luggage_count,
    b.start_location,
    b.end_location,
    b.pickup_lat,
    b.pickup_lng,
    b.dropoff_lat,
    b.dropoff_lng,
    b.quoted_price,
    b.additional_charges,
    b.total_price,
    COALESCE(pay.total_paid, 0.00) AS total_paid,
    GREATEST(0, b.total_price - COALESCE(pay.total_paid, 0.00)) AS outstanding_balance,
    CASE
        WHEN COALESCE(pay.total_paid, 0) = 0 THEN 'UNPAID'
        WHEN COALESCE(pay.total_paid, 0) >= b.total_price THEN 'FULLY_PAID'
        ELSE 'PARTIALLY_PAID'
    END AS financial_status,
    rev.rating AS review_rating
FROM silver.booking b
LEFT JOIN silver.booking_package bp ON bp.booking_id = b.booking_id
LEFT JOIN (
    SELECT booking_id, SUM(amount) AS total_paid
    FROM silver.payment
    WHERE is_approved = TRUE
    GROUP BY booking_id
) pay ON pay.booking_id = b.booking_id
LEFT JOIN silver.review rev ON rev.booking_id = b.booking_id;

-- =========================================================
-- 8. Fact: Payment Transactions
-- =========================================================
CREATE OR REPLACE VIEW gold.fact_payments AS
SELECT
    p.payment_id,
    p.booking_id,
    b.user_id AS customer_key,
    TO_CHAR(p.received_date, 'YYYYMMDD')::INTEGER AS payment_date_key,
    p.installment,
    p.amount,
    p.payment_method,
    p.received_date,
    p.status AS payment_status,
    p.is_approved,
    p.created_at AS payment_timestamp
FROM silver.payment p
INNER JOIN silver.booking b ON b.booking_id = p.booking_id;

-- =========================================================
-- 9. Fact: Booking Status Lifecycle & Turnaround
-- =========================================================
CREATE OR REPLACE VIEW gold.fact_booking_lifecycle AS
SELECT
    h.history_id,
    h.booking_id,
    b.user_id AS customer_key,
    b.vehicle_id AS vehicle_key,
    h.old_status,
    h.new_status,
    ROW_NUMBER() OVER (PARTITION BY h.booking_id ORDER BY h.changed_at) AS transition_step,
    ROUND(EXTRACT(EPOCH FROM (h.changed_at - LAG(h.changed_at) OVER (PARTITION BY h.booking_id ORDER BY h.changed_at))) / 3600.0, 2) AS hours_since_prior_status,
    CASE WHEN h.new_status IN ('COMPLETED', 'CANCELLED') THEN TRUE ELSE FALSE END AS is_terminal_status,
    h.admin_note,
    h.changed_at AS transition_timestamp,
    TO_CHAR(h.changed_at, 'YYYYMMDD')::INTEGER AS transition_date_key
FROM silver.booking_status_history h
INNER JOIN silver.booking b ON b.booking_id = h.booking_id;

-- =========================================================
-- 10. Fact: Customer Inquiries & Lead Support SLA
-- =========================================================
CREATE OR REPLACE VIEW gold.fact_customer_inquiries AS
SELECT
    i.inquiry_id,
    i.sender_name,
    i.sender_email,
    i.subject,
    i.status AS inquiry_status,
    i.is_read,
    u.user_id AS customer_key,
    CASE WHEN u.user_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_registered_customer,
    COALESCE(r_stats.reply_count, 0) AS total_replies_sent,
    r_stats.first_reply_at,
    ROUND(EXTRACT(EPOCH FROM (r_stats.first_reply_at - i.submitted_at)) / 3600.0, 2) AS response_latency_hours,
    CASE 
        WHEN r_stats.first_reply_at IS NOT NULL AND EXTRACT(EPOCH FROM (r_stats.first_reply_at - i.submitted_at)) > 86400 THEN TRUE
        ELSE FALSE
    END AS is_sla_breached_24h,
    i.submitted_at,
    TO_CHAR(i.submitted_at, 'YYYYMMDD')::INTEGER AS submission_date_key
FROM silver.contact_inquiry i
LEFT JOIN silver."user" u ON LOWER(u.email) = LOWER(i.sender_email)
LEFT JOIN (
    SELECT 
        inquiry_id,
        COUNT(reply_id) AS reply_count,
        MIN(sent_at) AS first_reply_at
    FROM silver.contact_reply
    GROUP BY inquiry_id
) r_stats ON r_stats.inquiry_id = i.inquiry_id;

-- =========================================================
-- 11. Fact: Reviews & Customer Feedback Sentiment
-- =========================================================
CREATE OR REPLACE VIEW gold.fact_reviews AS
SELECT
    r.review_id,
    r.booking_id,
    r.user_id AS customer_key,
    b.vehicle_id AS vehicle_key,
    bp.package_id AS package_key,
    r.rating,
    CASE
        WHEN r.rating = 5 THEN 'EXCELLENT'
        WHEN r.rating = 4 THEN 'GOOD'
        WHEN r.rating = 3 THEN 'AVERAGE'
        ELSE 'POOR'
    END AS sentiment_label,
    r.driver_name,
    r.title AS review_title,
    r.feedback AS review_feedback,
    COALESCE(img_stats.photo_count, 0) AS photo_count,
    CASE WHEN COALESCE(img_stats.photo_count, 0) > 0 THEN TRUE ELSE FALSE END AS has_photos,
    r.created_at AS review_timestamp,
    TO_CHAR(r.created_at, 'YYYYMMDD')::INTEGER AS review_date_key
FROM silver.review r
INNER JOIN silver.booking b ON b.booking_id = r.booking_id
LEFT JOIN silver.booking_package bp ON bp.booking_id = b.booking_id
LEFT JOIN (
    SELECT review_id, COUNT(*) AS photo_count
    FROM silver.review_image
    GROUP BY review_id
) img_stats ON img_stats.review_id = r.review_id;

-- =========================================================
-- 12. Fact / Analytical Mart: Daily Business Performance
-- =========================================================
CREATE OR REPLACE VIEW gold.mart_daily_performance AS
SELECT
    b.booking_date,
    TO_CHAR(b.booking_date, 'YYYYMMDD')::INTEGER AS booking_date_key,
    COUNT(b.booking_id) AS total_bookings_received,
    SUM(CASE WHEN b.is_confirmed THEN 1 ELSE 0 END) AS confirmed_bookings,
    SUM(CASE WHEN b.is_completed THEN 1 ELSE 0 END) AS completed_tours,
    SUM(CASE WHEN b.booking_status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_bookings,
    SUM(b.total_price) AS potential_revenue,
    SUM(CASE WHEN b.is_confirmed THEN b.total_price ELSE 0 END) AS confirmed_revenue,
    ROUND(AVG(b.total_price), 2) AS avg_booking_value,
    SUM(b.total_passengers) AS total_passengers
FROM silver.booking b
GROUP BY b.booking_date
ORDER BY b.booking_date DESC;
