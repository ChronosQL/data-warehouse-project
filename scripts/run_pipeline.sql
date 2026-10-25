/*
===============================================================================
Execution Script: Run Automatic Ingestion & Transformation Pipeline
===============================================================================
Script Purpose:
    This script is executed automatically upon container initialization 
    (via /docker-entrypoint-initdb.d/07_run_pipeline.sql).
    
    Pipeline Steps:
    1. CALL bronze.load_bronze() -> Ingests operational public tables to Bronze.
    2. CALL silver.load_silver() -> Cleanses, standardizes, and loads into Silver.
===============================================================================
*/

DO $$
BEGIN
    RAISE NOTICE '=======================================================';
    RAISE NOTICE '>>> STARTING AUTOMATED PIPELINE EXECUTION <<<';
    RAISE NOTICE '=======================================================';
END $$;

-- 1. Execute Bronze Layer Ingestion
CALL bronze.load_bronze();

-- 2. Execute Silver Layer Transformation
CALL silver.load_silver();

DO $$
BEGIN
    RAISE NOTICE '=======================================================';
    RAISE NOTICE '>>> AUTOMATED PIPELINE EXECUTION COMPLETED SUCCESSFULLY <<<';
    RAISE NOTICE '=======================================================';
END $$;
