/*
===============================================================================
SQL Script: 20 Human-Readable Business Intelligence Queries (Gold Layer)
===============================================================================
Database: tours_dw
Layer:    Gold (Enterprise Star Schema)
Author:   Data Engineering & Analytics Team

Overview:
    This script contains 20 production-ready, executive-grade analytical queries
    designed for business stakeholders (Executives, Operations Managers, Fleet
    Coordinators, and Marketing Leads).
    
    Structure per query:
    1. Formal Topic / Analytical Heading
    2. Plain-English Business Question
    3. Business Rationale ("Why It Matters")
    4. Actionable Management Decision
    5. Clean, readable CTE-based SQL with self-explanatory column aliases
===============================================================================
*/

-- ==============================================================================
-- DOMAIN 1: EXECUTIVE REVENUE & FINANCIAL INTELLIGENCE
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Query 01: Tourism Seasonality & Revenue Fluctuation Analysis
-- Question: "When is our busy season, and how bad is the off-season slump?"
-- Why It Matters: Tourism swings between sunny winter travel and monsoon rains.
--                 Knowing the drop-off prevents cash shortages during slow months.
-- Action: Time promotional bundles during monsoon and apply peak pricing in winter.
-- ------------------------------------------------------------------------------
WITH seasonal_performance AS (
    SELECT 
        d.tourism_season,
        COUNT(b.booking_id)           AS total_bookings,
        SUM(b.total_price)            AS total_revenue,
        ROUND(AVG(b.total_price), 2)  AS average_booking_value,
        SUM(b.total_passengers)       AS total_tourists_hosted
    FROM gold.fact_bookings b
    JOIN gold.dim_date d ON d.date_key = b.booking_date_key
    WHERE b.is_confirmed = TRUE
    GROUP BY d.tourism_season
)
SELECT 
    tourism_season                                AS "Tourism Season",
    total_bookings                                AS "Confirmed Bookings",
    TO_CHAR(total_revenue, '$999,999,999.00')     AS "Total Revenue",
    TO_CHAR(average_booking_value, '$999,999.00') AS "Avg Booking Value",
    total_tourists_hosted                         AS "Total Tourists Hosted"
FROM seasonal_performance
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------------------------
-- Query 02: Month-over-Month (MoM) Revenue Growth & Trajectory
-- Question: "Are we growing month-over-month, or is revenue slowing down?"
-- Why It Matters: Looking at one isolated month fails to indicate growth trends.
-- Action: Alerts leadership early when sales dip so marketing can act.
-- ------------------------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        SUM(b.total_price) AS monthly_revenue,
        COUNT(b.booking_id) AS total_bookings
    FROM gold.fact_bookings b
    JOIN gold.dim_date d ON d.date_key = b.booking_date_key
    WHERE b.is_confirmed = TRUE
    GROUP BY d.year, d.month, d.month_name
),
mom_calculation AS (
    SELECT 
        year,
        month,
        month_name,
        monthly_revenue,
        total_bookings,
        LAG(monthly_revenue) OVER (ORDER BY year, month) AS prior_month_revenue
    FROM monthly_revenue
)
SELECT 
    year || ' ' || month_name                     AS "Billing Month",
    total_bookings                                AS "Bookings Count",
    TO_CHAR(monthly_revenue, '$999,999,999.00')   AS "Monthly Revenue",
    TO_CHAR(prior_month_revenue, '$999,999,999.00') AS "Prior Month Revenue",
    COALESCE(
        ROUND(((monthly_revenue - prior_month_revenue) / NULLIF(prior_month_revenue, 0)) * 100.0, 2), 
        0.00
    ) || '%'                                      AS "MoM Growth %"
FROM mom_calculation
ORDER BY year DESC, month DESC;


-- ------------------------------------------------------------------------------
-- Query 03: Cumulative Annual Revenue Run-Rate vs. Targets
-- Question: "How much total revenue have we accumulated so far this year?"
-- Why It Matters: Confirms whether company is pacing to hit annual financial targets.
-- Action: Governs budget approvals for fleet expansion and year-end investments.
-- ------------------------------------------------------------------------------
WITH daily_revenue AS (
    SELECT 
        d.year,
        d.calendar_date,
        SUM(b.total_price) AS daily_revenue
    FROM gold.fact_bookings b
    JOIN gold.dim_date d ON d.date_key = b.booking_date_key
    WHERE b.is_confirmed = TRUE
    GROUP BY d.year, d.calendar_date
)
SELECT 
    calendar_date                                 AS "Date",
    TO_CHAR(daily_revenue, '$999,999.00')         AS "Daily Revenue",
    TO_CHAR(
        SUM(daily_revenue) OVER (PARTITION BY year ORDER BY calendar_date), 
        '$999,999,999.00'
    )                                             AS "YTD Cumulative Revenue"
FROM daily_revenue
ORDER BY calendar_date DESC
LIMIT 30;


-- ------------------------------------------------------------------------------
-- Query 04: Accounts Receivable & Outstanding Balance Aging
-- Question: "How much money are customers still owing us, and who owes it?"
-- Why It Matters: Quoted sales aren't real until paid. Unpaid balances hurt cash flow.
-- Action: Triggers automated balance collection emails for upcoming departures.
-- ------------------------------------------------------------------------------
WITH unpaid_balances AS (
    SELECT 
        c.customer_tier,
        COUNT(b.booking_id)       AS unpaid_bookings_count,
        SUM(b.total_price)        AS total_quoted_amount,
        SUM(b.total_paid)         AS total_collected_amount,
        SUM(b.outstanding_balance) AS total_outstanding_debt
    FROM gold.fact_bookings b
    JOIN gold.dim_customers c ON c.customer_key = b.customer_key
    WHERE b.financial_status IN ('PARTIALLY_PAID', 'UNPAID')
      AND b.booking_status != 'CANCELLED'
    GROUP BY c.customer_tier
)
SELECT 
    customer_tier                                     AS "Customer Tier",
    unpaid_bookings_count                             AS "Unpaid Bookings",
    TO_CHAR(total_quoted_amount, '$999,999,999.00')    AS "Total Quoted Value",
    TO_CHAR(total_collected_amount, '$999,999,999.00') AS "Total Collected",
    TO_CHAR(total_outstanding_debt, '$999,999,999.00') AS "Pending Receivables"
FROM unpaid_balances
ORDER BY total_outstanding_debt DESC;


-- ==============================================================================
-- DOMAIN 2: CUSTOMER SEGMENTATION & LIFETIME VALUE (LTV)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Query 05: Customer Tier Distribution & High-Value Traveler Segmentation
-- Question: "Who are our VIP high-spenders vs. regular travelers?"
-- Why It Matters: 20% of premium travelers generate over 70% of tour margins.
-- Action: Assign priority customer service and VIP airport perks to top tiers.
-- ------------------------------------------------------------------------------
SELECT 
    customer_tier                                 AS "Customer Segment",
    COUNT(customer_key)                           AS "Traveler Count",
    TO_CHAR(SUM(total_spend), '$999,999,999.00')  AS "Total Segment Revenue",
    TO_CHAR(AVG(total_spend), '$999,999.00')      AS "Avg Spend Per Traveler",
    ROUND(AVG(total_bookings), 1)                 AS "Avg Bookings Per Traveler"
FROM gold.dim_customers
GROUP BY customer_tier
ORDER BY SUM(total_spend) DESC;


-- ------------------------------------------------------------------------------
-- Query 06: Geographic Market Penetration & Spend by Country
-- Question: "Which countries bring us the most tourists and the highest spenders?"
-- Why It Matters: Untargeted international marketing burns budget on cold regions.
-- Action: Target ad spend to top 5 revenue countries (UK, Germany, Australia, etc.).
-- ------------------------------------------------------------------------------
SELECT 
    COALESCE(c.country, 'Unknown / Not Stated')    AS "Origin Country",
    COUNT(DISTINCT c.customer_key)                AS "Total Travelers",
    COUNT(b.booking_id)                           AS "Total Tours Booked",
    TO_CHAR(SUM(b.total_price), '$999,999,999.00') AS "Total Inbound Revenue",
    TO_CHAR(AVG(b.total_price), '$999,999.00')    AS "Avg Tour Value"
FROM gold.fact_bookings b
JOIN gold.dim_customers c ON c.customer_key = b.customer_key
WHERE b.is_confirmed = TRUE
GROUP BY c.country
ORDER BY SUM(b.total_price) DESC
LIMIT 10;


-- ------------------------------------------------------------------------------
-- Query 07: Repeat Traveler Retention Rate & Loyalty Analysis
-- Question: "Do travelers come back for a second trip, or are they one-and-done?"
-- Why It Matters: Retention costs 5x less than acquiring cold inbound tourists.
-- Action: Launch an alumni traveler loyalty club with exclusive return perks.
-- ------------------------------------------------------------------------------
WITH customer_frequency AS (
    SELECT 
        CASE 
            WHEN total_bookings = 1 THEN '1 Tour (One-and-Done)'
            WHEN total_bookings BETWEEN 2 AND 4 THEN '2 to 4 Tours (Repeat Traveler)'
            ELSE '5+ Tours (Loyal Advocate)'
        END AS loyalty_category,
        customer_key,
        total_spend
    FROM gold.dim_customers
    WHERE total_bookings > 0
)
SELECT 
    loyalty_category                              AS "Loyalty Bracket",
    COUNT(customer_key)                           AS "Traveler Count",
    ROUND((COUNT(customer_key) * 100.0) / SUM(COUNT(customer_key)) OVER (), 2) || '%' AS "Share of Traveler Base",
    TO_CHAR(SUM(total_spend), '$999,999,999.00')  AS "Total Revenue Generated"
FROM customer_frequency
GROUP BY loyalty_category
ORDER BY COUNT(customer_key) DESC;


-- ------------------------------------------------------------------------------
-- Query 08: High-Value Customer Churn & Dormancy Risk
-- Question: "Which past high-spenders haven't booked with us in over six months?"
-- Why It Matters: Premium travelers who lapse may have had issues or forgotten us.
-- Action: Direct account manager outreach with personalized discount offers.
-- ------------------------------------------------------------------------------
SELECT 
    customer_name                                 AS "Traveler Name",
    email                                         AS "Contact Email",
    contact_number                                AS "Phone Number",
    country                                       AS "Country",
    customer_tier                                 AS "Tier",
    TO_CHAR(total_spend, '$999,999.00')           AS "Lifetime Spend",
    last_booking_date                             AS "Last Trip Date",
    CURRENT_DATE - last_booking_date              AS "Days Since Last Tour"
FROM gold.dim_customers
WHERE customer_tier IN ('VIP Traveler', 'Regular Traveler')
  AND last_booking_date < (CURRENT_DATE - INTERVAL '180 days')
ORDER BY total_spend DESC
LIMIT 15;


-- ==============================================================================
-- DOMAIN 3: FLEET & ASSET UTILIZATION
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Query 09: Vehicle Profitability & Daily Revenue Yield
-- Question: "Which vehicle types bring in the most profit per day?"
-- Why It Matters: Luxury vans cost more to maintain; we need to verify their ROI.
-- Action: Informs which categories to purchase in the next fleet refresh cycle.
-- ------------------------------------------------------------------------------
SELECT 
    v.category_name                               AS "Vehicle Class",
    v.comfort_level                               AS "Comfort Rating",
    COUNT(b.booking_id)                           AS "Total Trips Dispatched",
    SUM(b.total_days)                             AS "Total Operational Days",
    TO_CHAR(SUM(b.total_price), '$999,999,999.00') AS "Total Fleet Revenue",
    TO_CHAR(
        ROUND(SUM(b.total_price) / NULLIF(SUM(b.total_days), 0), 2), 
        '$999,999.00'
    )                                             AS "Daily Revenue Yield"
FROM gold.fact_bookings b
JOIN gold.dim_vehicles v ON v.vehicle_key = b.vehicle_key
WHERE b.is_confirmed = TRUE
GROUP BY v.category_name, v.comfort_level
ORDER BY SUM(b.total_price) DESC;


-- ------------------------------------------------------------------------------
-- Query 10: Idle Fleet Identification & Depreciation Risk
-- Question: "Are any vehicles sitting in the garage idle and losing money?"
-- Why It Matters: Parked vehicles lose value while still costing registration/insurance.
-- Action: Reassign idle vehicles to busy regional depots or sell off dead stock.
-- ------------------------------------------------------------------------------
WITH vehicle_recent_activity AS (
    SELECT 
        v.vehicle_key,
        v.vehicle_number,
        v.vehicle_name,
        v.category_name,
        MAX(b.end_date) AS last_dispatched_date
    FROM gold.dim_vehicles v
    LEFT JOIN gold.fact_bookings b ON b.vehicle_key = v.vehicle_key
    WHERE v.vehicle_status = 'AVAILABLE'
    GROUP BY v.vehicle_key, v.vehicle_number, v.vehicle_name, v.category_name
)
SELECT 
    vehicle_number                                AS "Plate Number",
    vehicle_name                                  AS "Model Name",
    category_name                                 AS "Class",
    COALESCE(TO_CHAR(last_dispatched_date, 'YYYY-MM-DD'), 'Never Dispatched') AS "Last Trip Date",
    COALESCE(CURRENT_DATE - last_dispatched_date, 999) AS "Days Sitting Idle"
FROM vehicle_recent_activity
WHERE last_dispatched_date IS NULL OR last_dispatched_date < (CURRENT_DATE - INTERVAL '30 days')
ORDER BY "Days Sitting Idle" DESC;


-- ------------------------------------------------------------------------------
-- Query 11: Seating Capacity Utilization & Over-Allocation Inefficiencies
-- Question: "Are we dispatching large 14-seater vans for parties of only 2 people?"
-- Why It Matters: Oversized dispatches waste fuel and wear out expensive large vans.
-- Action: Tighten fleet scheduling rules to prevent sending large vans for small parties.
-- ------------------------------------------------------------------------------
WITH trip_occupancy AS (
    SELECT 
        b.booking_id,
        v.category_name,
        v.adult_seats,
        b.total_passengers,
        ROUND((b.total_passengers::NUMERIC / v.adult_seats::NUMERIC) * 100.0, 1) AS seat_occupancy_pct
    FROM gold.fact_bookings b
    JOIN gold.dim_vehicles v ON v.vehicle_key = b.vehicle_key
    WHERE b.is_confirmed = TRUE AND v.adult_seats > 0
)
SELECT 
    category_name                                 AS "Vehicle Category",
    COUNT(booking_id)                             AS "Total Completed Dispatches",
    ROUND(AVG(seat_occupancy_pct), 1) || '%'      AS "Average Seat Occupancy",
    COUNT(CASE WHEN seat_occupancy_pct < 40.0 THEN 1 END) AS "Trips With <40% Capacity",
    ROUND(
        (COUNT(CASE WHEN seat_occupancy_pct < 40.0 THEN 1 END) * 100.0) / COUNT(booking_id), 
        1
    ) || '%'                                      AS "Underutilized Trip %"
FROM trip_occupancy
GROUP BY category_name
ORDER BY AVG(seat_occupancy_pct) ASC;


-- ------------------------------------------------------------------------------
-- Query 12: Vehicle Preference Correlation by Tour Duration
-- Question: "What vehicles do people prefer for long cross-country tours vs. short day-trips?"
-- Why It Matters: Travelers demand luxury on 7-day trips, but care about cost on short runs.
-- Action: Personalize booking recommendations on the website based on trip length.
-- ------------------------------------------------------------------------------
WITH trip_durations AS (
    SELECT 
        CASE 
            WHEN total_days <= 2 THEN 'Short Day-Trip (1-2 Days)'
            WHEN total_days BETWEEN 3 AND 5 THEN 'Medium Tour (3-5 Days)'
            ELSE 'Grand Tour (6+ Days)'
        END AS trip_duration_bracket,
        v.category_name,
        b.total_price
    FROM gold.fact_bookings b
    JOIN gold.dim_vehicles v ON v.vehicle_key = b.vehicle_key
    WHERE b.is_confirmed = TRUE
)
SELECT 
    trip_duration_bracket                         AS "Trip Length",
    category_name                                 AS "Vehicle Category",
    COUNT(*)                                      AS "Bookings Chosen",
    TO_CHAR(AVG(total_price), '$999,999.00')      AS "Average Tour Revenue"
FROM trip_durations
GROUP BY trip_duration_bracket, category_name
ORDER BY trip_duration_bracket, COUNT(*) DESC;


-- ==============================================================================
-- DOMAIN 4: DESTINATIONS & TOUR EXPERIENCE ANALYTICS
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Query 13: Destination Popularity & Gross Merchandise Value (GMV) Ranking
-- Question: "What are our top 10 most popular tourist destinations by revenue?"
-- Why It Matters: Pinpoints landmark hubs (Sigiriya, Galle, Ella) driving sales.
-- Action: Negotiate volume discounts with partner hotels and restaurants in top hubs.
-- ------------------------------------------------------------------------------
SELECT 
    d.place_name                                  AS "Destination",
    d.total_package_routes                        AS "Package Itinerary Inclusions",
    d.available_activities                        AS "Local Activities Available",
    d.latitude                                    AS "Latitude",
    d.longitude                                   AS "Longitude",
    COUNT(b.booking_id)                           AS "Bookings Routed Here",
    TO_CHAR(SUM(b.total_price), '$999,999,999.00') AS "Linked Tour Revenue"
FROM gold.dim_destinations d
JOIN silver.package_place pp ON pp.place_id = d.place_id
JOIN gold.fact_bookings b ON b.package_key = pp.package_id
WHERE b.is_confirmed = TRUE
GROUP BY d.place_id, d.place_name, d.total_package_routes, d.available_activities, d.latitude, d.longitude
ORDER BY SUM(b.total_price) DESC
LIMIT 10;


-- ------------------------------------------------------------------------------
-- Query 14: Activity Category Revenue Contribution (Safari vs. Surf vs. Culture)
-- Question: "What activities generate the most interest: Wildlife, Adventure, or Culture?"
-- Why It Matters: Clarifies our key travel identity in the minds of travelers.
-- Action: Double down marketing budget on the highest-grossing experience category.
-- ------------------------------------------------------------------------------
SELECT 
    act.activity_category                         AS "Experience Type",
    COUNT(DISTINCT act.activity_key)              AS "Distinct Activities Offered",
    SUM(act.total_hosted_places)                  AS "Destination Inclusions",
    SUM(act.total_package_inclusions)             AS "Package Inclusions"
FROM gold.dim_activities act
GROUP BY act.activity_category
ORDER BY SUM(act.total_package_inclusions) DESC;


-- ------------------------------------------------------------------------------
-- Query 15: Tour Package Cancellation & Drop-Off Rates
-- Question: "Which tour packages suffer from the highest cancellation rates?"
-- Why It Matters: Cancellation rates >25% signal bad weather seasons, fatigue, or pricing.
-- Action: Audit, revamp, or retire packages that consistently fail to retain customers.
-- ------------------------------------------------------------------------------
WITH package_cancellations AS (
    SELECT 
        p.package_title,
        p.package_duration,
        COUNT(b.booking_id) AS total_requests,
        COUNT(CASE WHEN b.booking_status = 'CANCELLED' THEN 1 END) AS cancelled_requests
    FROM gold.dim_packages p
    JOIN gold.fact_bookings b ON b.package_key = p.package_key
    GROUP BY p.package_title, p.package_duration
)
SELECT 
    package_title                                 AS "Package Title",
    package_duration                              AS "Duration",
    total_requests                                AS "Total Inquiries/Bookings",
    cancelled_requests                            AS "Cancelled Tours",
    ROUND((cancelled_requests::NUMERIC / NULLIF(total_requests, 0)) * 100.0, 1) || '%' AS "Cancellation Rate"
FROM package_cancellations
WHERE total_requests >= 10
ORDER BY (cancelled_requests::NUMERIC / NULLIF(total_requests, 0)) DESC
LIMIT 10;


-- ------------------------------------------------------------------------------
-- Query 16: Spatial Travel Corridor & Route Density Analysis
-- Question: "Where are our busiest pickup and drop-off hubs?"
-- Why It Matters: High-traffic corridors allow pre-positioning drivers and support vans.
-- Action: Station on-call drivers near Colombo Airport and popular coastal hotels.
-- ------------------------------------------------------------------------------
SELECT 
    COALESCE(start_location, 'Unspecified Start') AS "Origin / Pickup Point",
    COALESCE(end_location, 'Unspecified End')     AS "Final Destination",
    COUNT(booking_id)                             AS "Trip Volume",
    TO_CHAR(SUM(total_price), '$999,999,999.00')  AS "Corridor Revenue",
    TO_CHAR(AVG(total_price), '$999,999.00')      AS "Average Trip Fare"
FROM gold.fact_bookings
WHERE is_confirmed = TRUE
GROUP BY start_location, end_location
ORDER BY COUNT(booking_id) DESC
LIMIT 10;


-- ==============================================================================
-- DOMAIN 5: OPERATIONS FUNNEL, SERVICE SLAS & QUALITY
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Query 17: Booking Funnel Conversion & Bottleneck Analysis
-- Question: "Where do we lose customers in the booking process (The Booking Funnel)?"
-- Why It Matters: Pinpoints whether drop-offs occur before approval or before payment.
-- Action: Fix checkout hurdles and follow up rapidly on unconfirmed requests.
-- ------------------------------------------------------------------------------
SELECT 
    new_status                                    AS "Funnel Milestone",
    COUNT(DISTINCT booking_id)                    AS "Bookings Reached Stage",
    ROUND(
        (COUNT(DISTINCT booking_id) * 100.0) / 
        (SELECT COUNT(DISTINCT booking_id) FROM gold.fact_booking_lifecycle), 
        1
    ) || '%'                                      AS "Conversion Rate From Top",
    ROUND(AVG(hours_since_prior_status), 1)       AS "Avg Hours Spent In Prior Stage"
FROM gold.fact_booking_lifecycle
GROUP BY new_status
ORDER BY COUNT(DISTINCT booking_id) DESC;


-- ------------------------------------------------------------------------------
-- Query 18: Staff Booking Confirmation Turnaround Time SLA
-- Question: "How long does our operations team take to confirm customer booking requests?"
-- Why It Matters: Slow confirmation drives eager tourists straight to competitors.
-- Action: Enforce a strict 4-hour confirmation SLA on the reservations desk.
-- ------------------------------------------------------------------------------
WITH confirmation_latencies AS (
    SELECT 
        booking_id,
        hours_since_prior_status AS confirmation_hours
    FROM gold.fact_booking_lifecycle
    WHERE new_status = 'CONFIRMED'
      AND hours_since_prior_status IS NOT NULL
)
SELECT 
    CASE 
        WHEN confirmation_hours <= 4.0 THEN 'Fast Response (<= 4 Hours) [Met SLA]'
        WHEN confirmation_hours BETWEEN 4.0 AND 24.0 THEN 'Moderate (4 to 24 Hours)'
        ELSE 'Slow (> 24 Hours) [SLA Breached]'
    END AS sla_performance_tier,
    COUNT(booking_id)                             AS "Bookings Processed",
    ROUND((COUNT(booking_id) * 100.0) / SUM(COUNT(booking_id)) OVER (), 1) || '%' AS "Share of Total"
FROM confirmation_latencies
GROUP BY 
    CASE 
        WHEN confirmation_hours <= 4.0 THEN 'Fast Response (<= 4 Hours) [Met SLA]'
        WHEN confirmation_hours BETWEEN 4.0 AND 24.0 THEN 'Moderate (4 to 24 Hours)'
        ELSE 'Slow (> 24 Hours) [SLA Breached]'
    END
ORDER BY COUNT(booking_id) DESC;


-- ------------------------------------------------------------------------------
-- Query 19: Customer Inquiry Response Latency & 24-Hour SLA Compliance
-- Question: "How fast does customer support respond to general inquiries?"
-- Why It Matters: Unanswered web contact inquiries are lost sales leads.
-- Action: Adjust weekend and evening support coverage to eliminate unanswered leads.
-- ------------------------------------------------------------------------------
SELECT 
    inquiry_status                                AS "Inquiry Status",
    COUNT(inquiry_id)                             AS "Total Web Inquiries",
    COUNT(CASE WHEN is_registered_customer THEN 1 END) AS "Inquiries From Registered Members",
    ROUND(AVG(response_latency_hours), 1)         AS "Avg Response Time (Hours)",
    COUNT(CASE WHEN is_sla_breached_24h THEN 1 END) AS "SLA Breaches (>24 Hours)",
    ROUND(
        (COUNT(CASE WHEN is_sla_breached_24h THEN 1 END) * 100.0) / NULLIF(COUNT(inquiry_id), 0), 
        1
    ) || '%'                                      AS "SLA Breach Rate"
FROM gold.fact_customer_inquiries
GROUP BY inquiry_status
ORDER BY COUNT(inquiry_id) DESC;


-- ------------------------------------------------------------------------------
-- Query 20: Driver Service Quality & Review Sentiment Impact
-- Question: "Which drivers get the best reviews, and what causes bad ratings?"
-- Why It Matters: Drivers represent the face of the business; top drivers drive repeat sales.
-- Action: Award bonuses to 5-star drivers; schedule customer-service coaching for low scores.
-- ------------------------------------------------------------------------------
SELECT 
    COALESCE(driver_name, 'Unassigned / Independent') AS "Driver Name",
    COUNT(review_id)                              AS "Total Reviews Received",
    ROUND(AVG(rating), 2)                         AS "Average Star Rating",
    COUNT(CASE WHEN sentiment_label = 'EXCELLENT' THEN 1 END) AS "5-Star Ratings",
    COUNT(CASE WHEN sentiment_label = 'POOR' THEN 1 END)      AS "1-2 Star Ratings",
    ROUND(
        (COUNT(CASE WHEN sentiment_label = 'EXCELLENT' THEN 1 END) * 100.0) / COUNT(review_id), 
        1
    ) || '%'                                      AS "5-Star Excellence Rate"
FROM gold.fact_reviews
GROUP BY driver_name
HAVING COUNT(review_id) >= 5
ORDER BY AVG(rating) DESC, COUNT(review_id) DESC
LIMIT 10;
