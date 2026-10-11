/*
===============================================================================
AUTOMATED TRANSFORMATION PIPELINE
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ELT transformation from Bronze to Silver.
    It cleanses, normalizes, deduplicates, and enriches data:
    - Truncates destination silver tables in safe dependency order.
    - Standardizes text casing (INITCAP, LOWER, UPPER) and trims whitespace.
    - Handles NULLs and establishes resilient default values.
    - Enriches records with derived business flags and calculated metrics.
    - Deduplicates records to ensure strict primary key uniqueness.
    - Records runtime diagnostics and loaded row counts.

Usage:
    CALL silver.load_silver();
===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time     TIMESTAMPTZ;
    v_end_time       TIMESTAMPTZ;
    v_batch_start    TIMESTAMPTZ;
    v_batch_end      TIMESTAMPTZ;
    v_row_count      INTEGER;
    v_total_rows     INTEGER := 0;
BEGIN
    v_batch_start := clock_timestamp();
    RAISE NOTICE '==================================================';
    RAISE NOTICE 'Starting Silver Transformation: %', v_batch_start;
    RAISE NOTICE '==================================================';

    -- ------------------------------------------------------------------
    -- 1. "user"
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.user';
    TRUNCATE TABLE silver."user" CASCADE;

    INSERT INTO silver."user" (
        user_id, name, first_name, last_name, email, password_hash,
        role, contact_number, street_address, country, zipcode,
        emergency_name, emergency_phone, emergency_relationship,
        auth_provider, provider_id, status, is_active,
        created_at, updated_at, _loaded_at
    )
    SELECT
        user_id,
        TRIM(name) AS name,
        NULLIF(SPLIT_PART(TRIM(name), ' ', 1), '') AS first_name,
        NULLIF(SUBSTRING(TRIM(name) FROM LENGTH(SPLIT_PART(TRIM(name), ' ', 1)) + 2), '') AS last_name,
        LOWER(TRIM(email)) AS email,
        password_hash,
        COALESCE(UPPER(TRIM(role)), 'CUSTOMER') AS role,
        TRIM(contact_number) AS contact_number,
        TRIM(street_address) AS street_address,
        INITCAP(TRIM(country)) AS country,
        UPPER(TRIM(zipcode)) AS zipcode,
        INITCAP(TRIM(emergency_name)) AS emergency_name,
        TRIM(emergency_phone) AS emergency_phone,
        INITCAP(TRIM(emergency_relationship)) AS emergency_relationship,
        COALESCE(UPPER(TRIM(auth_provider)), 'LOCAL') AS auth_provider,
        provider_id,
        COALESCE(UPPER(TRIM(status)), 'ACTIVE') AS status,
        CASE WHEN UPPER(TRIM(status)) = 'ACTIVE' THEN TRUE ELSE FALSE END AS is_active,
        created_at,
        updated_at,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY user_id 
                   ORDER BY COALESCE(updated_at, created_at, _ingested_at) DESC
               ) AS rn
        FROM bronze."user"
        WHERE user_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 2. vehicle_category
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.vehicle_category';
    TRUNCATE TABLE silver.vehicle_category CASCADE;

    INSERT INTO silver.vehicle_category (
        category_id, category_name, description, image_url, passenger_capacity,
        luggage_capacity, best_for, comfort_level, ac_available, ideal_trip_types, _loaded_at
    )
    SELECT
        category_id,
        INITCAP(TRIM(category_name)) AS category_name,
        TRIM(description) AS description,
        TRIM(image_url) AS image_url,
        TRIM(passenger_capacity) AS passenger_capacity,
        TRIM(luggage_capacity) AS luggage_capacity,
        TRIM(best_for) AS best_for,
        INITCAP(TRIM(comfort_level)) AS comfort_level,
        COALESCE(ac_available, FALSE) AS ac_available,
        TRIM(ideal_trip_types) AS ideal_trip_types,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.vehicle_category
        WHERE category_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 3. vehicle
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.vehicle';
    TRUNCATE TABLE silver.vehicle CASCADE;

    INSERT INTO silver.vehicle (
        vehicle_id, category_id, vehicle_number, vehicle_license, name,
        color, manufactured_year, adult_seats, baby_seats, luggage_capacity,
        price_per_day, insurance_provider, insurance_start_date, insurance_end_date,
        is_insured, is_valid_insurance_dates, image_url, vehicle_status, brand, model, fuel_type,
        transmission, air_conditioning, mileage, engine_capacity, features, _loaded_at
    )
    SELECT
        vehicle_id,
        category_id,
        UPPER(TRIM(vehicle_number)) AS vehicle_number,
        UPPER(TRIM(vehicle_license)) AS vehicle_license,
        INITCAP(TRIM(name)) AS name,
        INITCAP(TRIM(color)) AS color,
        manufactured_year,
        GREATEST(COALESCE(adult_seats, 1), 1) AS adult_seats,
        GREATEST(COALESCE(baby_seats, 0), 0) AS baby_seats,
        GREATEST(COALESCE(luggage_capacity, 0), 0) AS luggage_capacity,
        ROUND(GREATEST(COALESCE(price_per_day, 0.00), 0.00), 2) AS price_per_day,
        INITCAP(TRIM(insurance_provider)) AS insurance_provider,
        insurance_start_date,
        insurance_end_date,
        CASE 
            WHEN insurance_start_date IS NOT NULL AND insurance_end_date IS NOT NULL
                 AND insurance_end_date >= insurance_start_date
                 AND CURRENT_DATE BETWEEN insurance_start_date AND insurance_end_date 
            THEN TRUE 
            ELSE FALSE 
        END AS is_insured,
        CASE 
            WHEN insurance_start_date IS NOT NULL AND insurance_end_date IS NOT NULL 
                 AND insurance_end_date < insurance_start_date THEN FALSE
            ELSE TRUE 
        END AS is_valid_insurance_dates,
        TRIM(image_url) AS image_url,
        COALESCE(UPPER(TRIM(vehicle_status)), 'AVAILABLE') AS vehicle_status,
        INITCAP(TRIM(brand)) AS brand,
        INITCAP(TRIM(model)) AS model,
        INITCAP(TRIM(fuel_type)) AS fuel_type,
        INITCAP(TRIM(transmission)) AS transmission,
        COALESCE(air_conditioning, FALSE) AS air_conditioning,
        GREATEST(COALESCE(mileage, 0), 0) AS mileage,
        TRIM(engine_capacity) AS engine_capacity,
        TRIM(features) AS features,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY vehicle_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.vehicle
        WHERE vehicle_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 4. city
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.city';
    TRUNCATE TABLE silver.city CASCADE;

    INSERT INTO silver.city (id, name, created_at, _loaded_at)
    SELECT
        id,
        INITCAP(TRIM(name)) AS name,
        created_at,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.city
        WHERE id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 5. place
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.place';
    TRUNCATE TABLE silver.place CASCADE;

    INSERT INTO silver.place (place_id, place_name, image_url, description, _loaded_at)
    SELECT
        place_id,
        INITCAP(TRIM(place_name)) AS place_name,
        TRIM(image_url) AS image_url,
        TRIM(description) AS description,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY place_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.place
        WHERE place_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 6. activity
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.activity';
    TRUNCATE TABLE silver.activity CASCADE;

    INSERT INTO silver.activity (activity_id, activity_name, phone, description, _loaded_at)
    SELECT
        activity_id,
        INITCAP(TRIM(activity_name)) AS activity_name,
        TRIM(phone) AS phone,
        TRIM(description) AS description,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY activity_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.activity
        WHERE activity_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 7. place_activity
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.place_activity';
    TRUNCATE TABLE silver.place_activity CASCADE;

    INSERT INTO silver.place_activity (id, place_id, activity_id, _loaded_at)
    SELECT
        id,
        place_id,
        activity_id,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY place_id, activity_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.place_activity
        WHERE place_id IS NOT NULL AND activity_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 8. package
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.package';
    TRUNCATE TABLE silver.package CASCADE;

    INSERT INTO silver.package (
        package_id, title, type, days, description, image_url, availability_status, is_available, _loaded_at
    )
    SELECT
        package_id,
        INITCAP(TRIM(title)) AS title,
        UPPER(TRIM(type)) AS type,
        UPPER(TRIM(days)) AS days,
        TRIM(description) AS description,
        TRIM(image_url) AS image_url,
        COALESCE(UPPER(TRIM(availability_status)), 'AVAILABLE') AS availability_status,
        CASE WHEN UPPER(TRIM(availability_status)) = 'AVAILABLE' THEN TRUE ELSE FALSE END AS is_available,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY package_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.package
        WHERE package_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 9. package_place
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.package_place';
    TRUNCATE TABLE silver.package_place CASCADE;

    INSERT INTO silver.package_place (id, package_id, place_id, day_number, _loaded_at)
    SELECT
        id,
        package_id,
        place_id,
        GREATEST(COALESCE(day_number, 1), 1) AS day_number,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY package_id, place_id, day_number ORDER BY _ingested_at DESC) AS rn
        FROM bronze.package_place
        WHERE package_id IS NOT NULL AND place_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 10. booking
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.booking';
    TRUNCATE TABLE silver.booking CASCADE;

    INSERT INTO silver.booking (
        booking_id, user_id, customer_name, contact_platform, contact_number,
        contact_platform2, contact_number2, tour_type, category_id, vehicle_id,
        start_date, end_date, pickup_time, start_location, end_location,
        total_days, days_required, total_passengers, no_of_adults, no_of_children,
        ages_of_children, total_luggage_count, luggage_10kg, luggage_25kg, luggage_35kg,
        quoted_price, additional_charges, total_price, notes, tour_thoughts,
        admin_note, booking_date, booking_status, is_confirmed, is_completed, is_valid_date_range,
        quoted_at, confirmed_at, tour_started_at, completed_at, closed_at, _loaded_at
    )
    SELECT
        booking_id,
        user_id,
        INITCAP(TRIM(customer_name)) AS customer_name,
        COALESCE(LOWER(TRIM(contact_platform)), 'mobile') AS contact_platform,
        TRIM(contact_number) AS contact_number,
        LOWER(TRIM(contact_platform2)) AS contact_platform2,
        TRIM(contact_number2) AS contact_number2,
        UPPER(TRIM(tour_type)) AS tour_type,
        category_id,
        vehicle_id,
        start_date,
        end_date,
        pickup_time,
        INITCAP(TRIM(start_location)) AS start_location,
        INITCAP(TRIM(end_location)) AS end_location,
        GREATEST(COALESCE(total_days, 1), 1) AS total_days,
        GREATEST(COALESCE(days_required, 1), 1) AS days_required,
        (GREATEST(COALESCE(no_of_adults, 1), 1) + GREATEST(COALESCE(no_of_children, 0), 0)) AS total_passengers,
        GREATEST(COALESCE(no_of_adults, 1), 1) AS no_of_adults,
        GREATEST(COALESCE(no_of_children, 0), 0) AS no_of_children,
        TRIM(ages_of_children) AS ages_of_children,
        (GREATEST(COALESCE(luggage_10kg, 0), 0) + GREATEST(COALESCE(luggage_25kg, 0), 0) + GREATEST(COALESCE(luggage_35kg, 0), 0)) AS total_luggage_count,
        GREATEST(COALESCE(luggage_10kg, 0), 0) AS luggage_10kg,
        GREATEST(COALESCE(luggage_25kg, 0), 0) AS luggage_25kg,
        GREATEST(COALESCE(luggage_35kg, 0), 0) AS luggage_35kg,
        ROUND(GREATEST(COALESCE(quoted_price, 0.00), 0.00), 2) AS quoted_price,
        ROUND(GREATEST(COALESCE(additional_charges, 0.00), 0.00), 2) AS additional_charges,
        ROUND((GREATEST(COALESCE(quoted_price, 0.00), 0.00) + GREATEST(COALESCE(additional_charges, 0.00), 0.00)), 2) AS total_price,
        TRIM(notes) AS notes,
        TRIM(tour_thoughts) AS tour_thoughts,
        TRIM(admin_note) AS admin_note,
        booking_date,
        COALESCE(UPPER(TRIM(booking_status)), 'PENDING') AS booking_status,
        CASE WHEN UPPER(TRIM(booking_status)) IN ('CONFIRMED', 'TOUR_STARTED', 'COMPLETED', 'CLOSED') THEN TRUE ELSE FALSE END AS is_confirmed,
        CASE WHEN UPPER(TRIM(booking_status)) = 'COMPLETED' THEN TRUE ELSE FALSE END AS is_completed,
        CASE 
            WHEN end_date < start_date THEN FALSE
            WHEN start_date IS NULL OR end_date IS NULL THEN FALSE
            ELSE TRUE 
        END AS is_valid_date_range,
        quoted_at,
        confirmed_at,
        tour_started_at,
        completed_at,
        closed_at,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY booking_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.booking
        WHERE booking_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 11. booking_package
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.booking_package';
    TRUNCATE TABLE silver.booking_package CASCADE;

    INSERT INTO silver.booking_package (id, booking_id, package_id, _loaded_at)
    SELECT
        id,
        booking_id,
        package_id,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY booking_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.booking_package
        WHERE booking_id IS NOT NULL AND package_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 12. payment
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.payment';
    TRUNCATE TABLE silver.payment CASCADE;

    INSERT INTO silver.payment (
        payment_id, booking_id, installment, amount, payment_method, received_date, recorded_by, notes, _loaded_at
    )
    SELECT
        payment_id,
        booking_id,
        COALESCE(UPPER(TRIM(installment)), 'FULL') AS installment,
        ROUND(GREATEST(COALESCE(amount, 0.00), 0.00), 2) AS amount,
        COALESCE(UPPER(TRIM(payment_method)), 'CASH') AS payment_method,
        received_date,
        recorded_by,
        TRIM(notes) AS notes,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.payment
        WHERE payment_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 13. review
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.review';
    TRUNCATE TABLE silver.review CASCADE;

    INSERT INTO silver.review (
        review_id, user_id, booking_id, rating, driver_name, title, feedback, created_at, _loaded_at
    )
    SELECT
        review_id,
        user_id,
        booking_id,
        GREATEST(1, LEAST(5, COALESCE(rating, 5))) AS rating,
        INITCAP(TRIM(driver_name)) AS driver_name,
        TRIM(title) AS title,
        TRIM(feedback) AS feedback,
        created_at,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY booking_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.review
        WHERE review_id IS NOT NULL AND booking_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 14. review_image
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.review_image';
    TRUNCATE TABLE silver.review_image CASCADE;

    INSERT INTO silver.review_image (image_id, review_id, image_url, _loaded_at)
    SELECT
        image_id,
        review_id,
        TRIM(image_url) AS image_url,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY image_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.review_image
        WHERE image_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 15. contact_inquiry
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.contact_inquiry';
    TRUNCATE TABLE silver.contact_inquiry CASCADE;

    INSERT INTO silver.contact_inquiry (
        inquiry_id, sender_name, sender_email, sender_phone, subject, message, is_read, status, submitted_at, _loaded_at
    )
    SELECT
        inquiry_id,
        INITCAP(TRIM(sender_name)) AS sender_name,
        LOWER(TRIM(sender_email)) AS sender_email,
        TRIM(sender_phone) AS sender_phone,
        TRIM(subject) AS subject,
        TRIM(message) AS message,
        COALESCE(is_read, FALSE) AS is_read,
        COALESCE(LOWER(TRIM(status)), 'new') AS status,
        submitted_at,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY inquiry_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.contact_inquiry
        WHERE inquiry_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 16. contact_reply
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.contact_reply';
    TRUNCATE TABLE silver.contact_reply CASCADE;

    INSERT INTO silver.contact_reply (
        reply_id, inquiry_id, sender_role, sender_name, message, sent_at, _loaded_at
    )
    SELECT
        reply_id,
        inquiry_id,
        COALESCE(LOWER(TRIM(sender_role)), 'customer') AS sender_role,
        INITCAP(TRIM(sender_name)) AS sender_name,
        TRIM(message) AS message,
        sent_at,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY reply_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.contact_reply
        WHERE reply_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 17. chat_topic
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.chat_topic';
    TRUNCATE TABLE silver.chat_topic CASCADE;

    INSERT INTO silver.chat_topic (topic_id, user_id, subject, created_at, _loaded_at)
    SELECT
        topic_id,
        user_id,
        TRIM(subject) AS subject,
        created_at,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY topic_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.chat_topic
        WHERE topic_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- ------------------------------------------------------------------
    -- 18. chat_message
    -- ------------------------------------------------------------------
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Transforming: silver.chat_message';
    TRUNCATE TABLE silver.chat_message CASCADE;

    INSERT INTO silver.chat_message (message_id, topic_id, sender_id, message, sent_at, _loaded_at)
    SELECT
        message_id,
        topic_id,
        sender_id,
        TRIM(message) AS message,
        sent_at,
        clock_timestamp() AS _loaded_at
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY message_id ORDER BY _ingested_at DESC) AS rn
        FROM bronze.chat_message
        WHERE message_id IS NOT NULL
    ) src
    WHERE rn = 1;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- Batch Completion Summary
    v_batch_end := clock_timestamp();
    RAISE NOTICE '==================================================';
    RAISE NOTICE 'Silver Transformation Completed Successfully!';
    RAISE NOTICE 'Total Rows Transformed: %', v_total_rows;
    RAISE NOTICE 'Total Duration: % ms', ROUND(EXTRACT(EPOCH FROM (v_batch_end - v_batch_start)) * 1000);
    RAISE NOTICE '==================================================';
END;
$$;
