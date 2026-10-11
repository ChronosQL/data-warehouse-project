/*
===============================================================================
AUTOMATED INGESTION PIPELINE
Stored Procedure: Load Bronze Layer (Operational -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure ingests operational data into the 'bronze' schema.
    It performs the following:
    - Truncates each bronze table (full-refresh pattern).
    - Inserts raw records from the operational public tables.
    - Appends the audit timestamp (_ingested_at) using clock_timestamp().
    - Logs execution time and loaded row counts for each table.

Usage:
    CALL bronze.load_bronze();
===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
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
    RAISE NOTICE 'Starting Bronze Ingestion: %', v_batch_start;
    RAISE NOTICE '==================================================';

    -- 1. "user"
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.user';
    TRUNCATE TABLE bronze."user";
    INSERT INTO bronze."user" (
        user_id, name, email, password_hash, role, contact_number,
        street_address, country, zipcode, emergency_name, emergency_phone,
        emergency_relationship, auth_provider, provider_id, status,
        created_at, updated_at, _ingested_at
    )
    SELECT 
        user_id, name, email, password_hash, role::VARCHAR, contact_number,
        street_address, country, zipcode, emergency_name, emergency_phone,
        emergency_relationship, auth_provider::VARCHAR, provider_id, status::VARCHAR,
        created_at, updated_at, clock_timestamp()
    FROM public."user";
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 2. vehicle_category
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.vehicle_category';
    TRUNCATE TABLE bronze.vehicle_category;
    INSERT INTO bronze.vehicle_category (
        category_id, category_name, description, image_url, passenger_capacity,
        luggage_capacity, best_for, comfort_level, ac_available, ideal_trip_types, _ingested_at
    )
    SELECT 
        category_id, category_name, description, image_url, passenger_capacity,
        luggage_capacity, best_for, comfort_level, ac_available, ideal_trip_types, clock_timestamp()
    FROM public.vehicle_category;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 3. vehicle
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.vehicle';
    TRUNCATE TABLE bronze.vehicle;
    INSERT INTO bronze.vehicle (
        vehicle_id, category_id, vehicle_number, vehicle_license, name,
        color, manufactured_year, adult_seats, baby_seats, luggage_capacity,
        price_per_day, insurance_provider, insurance_start_date, insurance_end_date,
        image_url, vehicle_status, brand, model, fuel_type, transmission,
        air_conditioning, mileage, engine_capacity, features, _ingested_at
    )
    SELECT 
        vehicle_id, category_id, vehicle_number, vehicle_license, name,
        color, manufactured_year, adult_seats, baby_seats, luggage_capacity,
        price_per_day, insurance_provider, insurance_start_date, insurance_end_date,
        image_url, vehicle_status::VARCHAR, brand, model, fuel_type, transmission,
        air_conditioning, mileage, engine_capacity, features, clock_timestamp()
    FROM public.vehicle;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 4. city
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.city';
    TRUNCATE TABLE bronze.city;
    INSERT INTO bronze.city (id, name, created_at, _ingested_at)
    SELECT id, name, created_at, clock_timestamp()
    FROM public.city;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 5. place
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.place';
    TRUNCATE TABLE bronze.place;
    INSERT INTO bronze.place (place_id, place_name, image_url, description, _ingested_at)
    SELECT place_id, place_name, image_url, description, clock_timestamp()
    FROM public.place;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 6. activity
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.activity';
    TRUNCATE TABLE bronze.activity;
    INSERT INTO bronze.activity (activity_id, activity_name, phone, description, _ingested_at)
    SELECT activity_id, activity_name, phone, description, clock_timestamp()
    FROM public.activity;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 7. place_activity
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.place_activity';
    TRUNCATE TABLE bronze.place_activity;
    INSERT INTO bronze.place_activity (id, place_id, activity_id, _ingested_at)
    SELECT id, place_id, activity_id, clock_timestamp()
    FROM public.place_activity;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 8. package
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.package';
    TRUNCATE TABLE bronze.package;
    INSERT INTO bronze.package (
        package_id, title, type, days, description, image_url, availability_status, _ingested_at
    )
    SELECT 
        package_id, title, type::VARCHAR, days::VARCHAR, description, image_url, availability_status::VARCHAR, clock_timestamp()
    FROM public.package;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 9. package_place
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.package_place';
    TRUNCATE TABLE bronze.package_place;
    INSERT INTO bronze.package_place (id, package_id, place_id, day_number, _ingested_at)
    SELECT id, package_id, place_id, day_number, clock_timestamp()
    FROM public.package_place;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 10. booking
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.booking';
    TRUNCATE TABLE bronze.booking;
    INSERT INTO bronze.booking (
        booking_id, user_id, customer_name, contact_platform, contact_number,
        contact_platform2, contact_number2, tour_type, category_id, vehicle_id,
        start_date, end_date, pickup_time, start_location, end_location,
        total_days, days_required, luggage_10kg, luggage_25kg, luggage_35kg,
        no_of_adults, no_of_children, ages_of_children, quoted_price, additional_charges,
        notes, tour_thoughts, admin_note, booking_date, booking_status,
        quoted_at, confirmed_at, tour_started_at, completed_at, closed_at, _ingested_at
    )
    SELECT 
        booking_id, user_id, customer_name, contact_platform, contact_number,
        contact_platform2, contact_number2, tour_type::VARCHAR, category_id, vehicle_id,
        start_date, end_date, pickup_time, start_location, end_location,
        total_days, days_required, luggage_10kg, luggage_25kg, luggage_35kg,
        no_of_adults, no_of_children, ages_of_children, quoted_price, additional_charges,
        notes, tour_thoughts, admin_note, booking_date, booking_status::VARCHAR,
        quoted_at, confirmed_at, tour_started_at, completed_at, closed_at, clock_timestamp()
    FROM public.booking;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 11. booking_package
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.booking_package';
    TRUNCATE TABLE bronze.booking_package;
    INSERT INTO bronze.booking_package (id, booking_id, package_id, _ingested_at)
    SELECT id, booking_id, package_id, clock_timestamp()
    FROM public.booking_package;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 12. payment
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.payment';
    TRUNCATE TABLE bronze.payment;
    INSERT INTO bronze.payment (
        payment_id, booking_id, installment, amount, payment_method, received_date, recorded_by, notes, _ingested_at
    )
    SELECT 
        payment_id, booking_id, installment::VARCHAR, amount, payment_method::VARCHAR, received_date, recorded_by, notes, clock_timestamp()
    FROM public.payment;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 13. review
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.review';
    TRUNCATE TABLE bronze.review;
    INSERT INTO bronze.review (
        review_id, user_id, booking_id, rating, driver_name, title, feedback, created_at, _ingested_at
    )
    SELECT 
        review_id, user_id, booking_id, rating, driver_name, title, feedback, created_at, clock_timestamp()
    FROM public.review;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 14. review_image
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.review_image';
    TRUNCATE TABLE bronze.review_image;
    INSERT INTO bronze.review_image (image_id, review_id, image_url, _ingested_at)
    SELECT image_id, review_id, image_url, clock_timestamp()
    FROM public.review_image;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 15. contact_inquiry
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.contact_inquiry';
    TRUNCATE TABLE bronze.contact_inquiry;
    INSERT INTO bronze.contact_inquiry (
        inquiry_id, sender_name, sender_email, sender_phone, subject, message, is_read, status, submitted_at, _ingested_at
    )
    SELECT 
        inquiry_id, sender_name, sender_email, sender_phone, subject, message, is_read, status::VARCHAR, submitted_at, clock_timestamp()
    FROM public.contact_inquiry;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 16. contact_reply
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.contact_reply';
    TRUNCATE TABLE bronze.contact_reply;
    INSERT INTO bronze.contact_reply (
        reply_id, inquiry_id, sender_role, sender_name, message, sent_at, _ingested_at
    )
    SELECT 
        reply_id, inquiry_id, sender_role::VARCHAR, sender_name, message, sent_at, clock_timestamp()
    FROM public.contact_reply;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 17. chat_topic
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.chat_topic';
    TRUNCATE TABLE bronze.chat_topic;
    INSERT INTO bronze.chat_topic (topic_id, user_id, subject, created_at, _ingested_at)
    SELECT topic_id, user_id, subject, created_at, clock_timestamp()
    FROM public.chat_topic;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- 18. chat_message
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Ingesting: bronze.chat_message';
    TRUNCATE TABLE bronze.chat_message;
    INSERT INTO bronze.chat_message (message_id, topic_id, sender_id, message, sent_at, _ingested_at)
    SELECT message_id, topic_id, sender_id, message, sent_at, clock_timestamp()
    FROM public.chat_message;
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    v_total_rows := v_total_rows + v_row_count;
    v_end_time := clock_timestamp();
    RAISE NOTICE '   Loaded % rows in % ms', v_row_count, 
        ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000);

    -- Batch Completion Summary
    v_batch_end := clock_timestamp();
    RAISE NOTICE '==================================================';
    RAISE NOTICE 'Bronze Ingestion Completed Successfully!';
    RAISE NOTICE 'Total Rows Ingested: %', v_total_rows;
    RAISE NOTICE 'Total Duration: % ms', ROUND(EXTRACT(EPOCH FROM (v_batch_end - v_batch_start)) * 1000);
    RAISE NOTICE '==================================================';
END;
$$;
