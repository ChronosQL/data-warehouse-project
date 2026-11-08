#!/bin/sh
set -e

# ==============================================================================
# AUTOMATED METABASE DASHBOARDS & RICH VISUALIZATIONS GENERATOR (v3.0)
# ==============================================================================
# Pure POSIX shell script running inside curlimages/curl
# - Generates 5 executive dashboards + 1 master Gold schema catalog landing hub
# - Mounts all 20 business queries into 2x2 grid layouts with live chart visualizers
# - Configures Metabase homepage to permanently show the Gold Data Warehouse
# ==============================================================================

MB_URL="http://metabase:3000"
SESSION_ID="$1"
DB_ID="$2"

echo "=========================================================="
echo ">>> STARTING AUTOMATED METABASE DASHBOARD GENERATOR <<<"
echo "=========================================================="

if [ -z "$SESSION_ID" ]; then
    echo "Acquiring Metabase session token..."
    SESSION_RESP=$(curl -s -X POST "$MB_URL/api/session" \
      -H "Content-Type: application/json" \
      -d '{"username":"admin@admin.com","password":"AdminPassword123!"}')
    SESSION_ID=$(echo "$SESSION_RESP" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
    if [ -z "$SESSION_ID" ]; then
        echo "Error: Could not acquire session token. Response: $SESSION_RESP"
        exit 1
    fi
fi

if [ -z "$DB_ID" ]; then
    echo "Locating 'Tours Data Warehouse' database ID..."
    DB_ID=$(curl -s -H "X-Metabase-Session: $SESSION_ID" "$MB_URL/api/database" | jq -r '(.data // .)[] | select(.name=="Tours Data Warehouse") | .id' 2>/dev/null | head -n 1)
    if [ -z "$DB_ID" ] || [ "$DB_ID" = "null" ]; then
        DB_ID=2
    fi
fi

echo "Metabase Session: [${SESSION_ID:0:8}...] | Warehouse DB ID: $DB_ID"

# ------------------------------------------------------------------------------
# Helper: Create or retrieve Dashboard ID
# ------------------------------------------------------------------------------
get_or_create_dashboard() {
    dash_name="$1"
    dash_desc="$2"
    
    existing_id=$(curl -s -H "X-Metabase-Session: $SESSION_ID" "$MB_URL/api/dashboard" | jq -r --arg n "$dash_name" '.[] | select(.name==$n) | .id' 2>/dev/null | head -n 1)
    
    if [ -n "$existing_id" ] && [ "$existing_id" != "null" ] && [ "$existing_id" -gt 0 ] 2>/dev/null; then
        echo "$existing_id"
        return 0
    fi
    
    create_resp=$(curl -s -X POST "$MB_URL/api/dashboard" \
      -H "Content-Type: application/json" \
      -H "X-Metabase-Session: $SESSION_ID" \
      -d "{
        \"name\": \"$dash_name\",
        \"description\": \"$dash_desc\",
        \"parameters\": []
      }")
    
    dash_id=$(echo "$create_resp" | jq -r .id 2>/dev/null || true)
    echo "$dash_id"
}

# ------------------------------------------------------------------------------
# Helper: Create SQL Card or retrieve if already exists
# ------------------------------------------------------------------------------
create_card() {
    card_name="$1"
    display_type="$2"
    sql_query="$3"
    viz_settings="${4:-{}}"
    
    existing_card_id=$(curl -s -H "X-Metabase-Session: $SESSION_ID" "$MB_URL/api/card" | jq -r --arg n "$card_name" '.[] | select(.name==$n) | .id' 2>/dev/null | head -n 1)
    
    if [ -n "$existing_card_id" ] && [ "$existing_card_id" != "null" ] && [ "$existing_card_id" -gt 0 ] 2>/dev/null; then
        echo "$existing_card_id"
        return 0
    fi
    
    escaped_sql=$(printf '%s' "$sql_query" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr '\n' ' ' | sed 's/  */ /g')
    
    card_payload="{
      \"name\": \"$card_name\",
      \"dataset_query\": {
        \"type\": \"native\",
        \"native\": {
          \"query\": \"$escaped_sql\",
          \"template-tags\": {}
        },
        \"database\": $DB_ID
      },
      \"display\": \"$display_type\",
      \"visualization_settings\": $viz_settings
    }"
    
    card_resp=$(curl -s -X POST "$MB_URL/api/card" \
      -H "Content-Type: application/json" \
      -H "X-Metabase-Session: $SESSION_ID" \
      -d "$card_payload")
    
    card_id=$(echo "$card_resp" | jq -r .id 2>/dev/null || true)
    echo "$card_id"
}

# ------------------------------------------------------------------------------
# Helper: Batch Mount 4 Cards onto a Dashboard (2x2 Grid)
# ------------------------------------------------------------------------------
mount_dashboard_cards() {
    dash_id="$1"
    card1="$2"
    card2="$3"
    card3="$4"
    card4="$5"
    
    if [ -z "$dash_id" ] || [ "$dash_id" = "null" ]; then
        echo "  -> Error: Dashboard ID is missing!" >&2
        return 1
    fi
    
    mount_body=$(cat <<EOF
{"cards":[{"id":-1,"card_id":$card1,"row":0,"col":0,"size_x":12,"size_y":8},{"id":-2,"card_id":$card2,"row":0,"col":12,"size_x":12,"size_y":8},{"id":-3,"card_id":$card3,"row":8,"col":0,"size_x":12,"size_y":8},{"id":-4,"card_id":$card4,"row":8,"col":12,"size_x":12,"size_y":8}]}
EOF
)
    
    mount_resp=$(curl -s -w "\n%{http_code}" -X PUT "$MB_URL/api/dashboard/$dash_id/cards" \
      -H "Content-Type: application/json" \
      -H "X-Metabase-Session: $SESSION_ID" \
      -d "$mount_body")
    http_code=$(echo "$mount_resp" | tail -n 1)
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo "  -> Successfully mounted 4 cards (IDs: $card1, $card2, $card3, $card4) to Dashboard #$dash_id"
    else
        echo "  -> Error mounting cards to Dashboard #$dash_id (HTTP $http_code)" >&2
    fi
}

# ==============================================================================
# DASHBOARD 1: Executive Revenue & Financial Intelligence
# ==============================================================================
echo ""
echo ">>> [1/5] Building Dashboard 1: Executive Revenue & Financial Intelligence <<<"
DASH1_ID=$(get_or_create_dashboard "1. Executive Revenue & Financial Intelligence" "Strategic financial health, seasonality fluctuations, MoM revenue trajectory, and receivables.")

Q01_SQL="WITH seasonal_performance AS (
    SELECT 
        d.tourism_season,
        COUNT(b.booking_id)           AS total_bookings,
        ROUND(SUM(b.total_price), 2)  AS total_revenue,
        ROUND(AVG(b.total_price), 2)  AS average_booking_value,
        SUM(b.total_passengers)       AS total_tourists_hosted
    FROM gold.fact_bookings b
    JOIN gold.dim_date d ON d.date_key = b.booking_date_key
    WHERE b.is_confirmed = TRUE
    GROUP BY d.tourism_season
)
SELECT 
    tourism_season AS \"Tourism Season\",
    total_bookings AS \"Confirmed Bookings\",
    total_revenue AS \"Total Revenue\",
    average_booking_value AS \"Avg Booking Value\",
    total_tourists_hosted AS \"Total Tourists Hosted\"
FROM seasonal_performance
ORDER BY total_revenue DESC;"

Q02_SQL="WITH monthly_revenue AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        ROUND(SUM(b.total_price), 2) AS monthly_revenue,
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
    year || ' ' || month_name AS \"Billing Month\",
    total_bookings AS \"Bookings Count\",
    monthly_revenue AS \"Monthly Revenue\",
    prior_month_revenue AS \"Prior Month Revenue\",
    COALESCE(ROUND(((monthly_revenue - prior_month_revenue) / NULLIF(prior_month_revenue, 0)) * 100.0, 2), 0.00) AS \"MoM Growth Pct\"
FROM mom_calculation
ORDER BY year ASC, month ASC;"

Q03_SQL="WITH daily_revenue AS (
    SELECT 
        d.year,
        d.calendar_date,
        ROUND(SUM(b.total_price), 2) AS daily_revenue
    FROM gold.fact_bookings b
    JOIN gold.dim_date d ON d.date_key = b.booking_date_key
    WHERE b.is_confirmed = TRUE
    GROUP BY d.year, d.calendar_date
)
SELECT 
    calendar_date AS \"Date\",
    daily_revenue AS \"Daily Revenue\",
    ROUND(SUM(daily_revenue) OVER (PARTITION BY year ORDER BY calendar_date), 2) AS \"YTD Cumulative Revenue\"
FROM daily_revenue
ORDER BY calendar_date ASC;"

Q04_SQL="WITH unpaid_balances AS (
    SELECT 
        c.customer_tier,
        COUNT(b.booking_id) AS unpaid_bookings_count,
        ROUND(SUM(b.total_price), 2) AS total_quoted_amount,
        ROUND(SUM(b.total_paid), 2) AS total_collected_amount,
        ROUND(SUM(b.outstanding_balance), 2) AS total_outstanding_debt
    FROM gold.fact_bookings b
    JOIN gold.dim_customers c ON c.customer_key = b.customer_key
    WHERE b.financial_status IN ('PARTIALLY_PAID', 'UNPAID')
      AND b.booking_status != 'CANCELLED'
    GROUP BY c.customer_tier
)
SELECT 
    customer_tier AS \"Customer Tier\",
    unpaid_bookings_count AS \"Unpaid Bookings\",
    total_quoted_amount AS \"Total Quoted Value\",
    total_collected_amount AS \"Total Collected\",
    total_outstanding_debt AS \"Pending Receivables\"
FROM unpaid_balances
ORDER BY total_outstanding_debt DESC;"

C01=$(create_card "Q01: Tourism Seasonality & Revenue Fluctuation" "bar" "$Q01_SQL" '{"graph.dimensions":["Tourism Season"],"graph.metrics":["Total Revenue (LKR)"]}')
C02=$(create_card "Q02: Month-over-Month (MoM) Revenue Growth Trajectory" "line" "$Q02_SQL" '{"graph.dimensions":["Billing Month"],"graph.metrics":["Monthly Revenue (LKR)"]}')
C03=$(create_card "Q03: Cumulative Annual Revenue Run-Rate vs Targets" "line" "$Q03_SQL" '{"graph.dimensions":["Date"],"graph.metrics":["YTD Cumulative Revenue (LKR)"]}')
C04=$(create_card "Q04: Accounts Receivable & Outstanding Balances" "bar" "$Q04_SQL" '{"graph.dimensions":["Customer Tier"],"graph.metrics":["Pending Receivables (LKR)"]}')

mount_dashboard_cards "$DASH1_ID" "$C01" "$C02" "$C03" "$C04"

# ==============================================================================
# DASHBOARD 2: Customer Segmentation & Lifetime Value (LTV)
# ==============================================================================
echo ""
echo ">>> [2/5] Building Dashboard 2: Customer Segmentation & Lifetime Value <<<"
DASH2_ID=$(get_or_create_dashboard "2. Customer Segmentation & Lifetime Value (LTV)" "Traveler demographics, international source markets, repeat retention, and churn prevention.")

Q05_SQL="SELECT 
    customer_tier AS \"Customer Segment\",
    COUNT(customer_key) AS \"Traveler Count\",
    ROUND(SUM(total_spend), 2) AS \"Total Segment Revenue\",
    ROUND(AVG(total_spend), 2) AS \"Avg Spend Per Traveler\",
    ROUND(AVG(total_bookings), 1) AS \"Avg Bookings Per Traveler\"
FROM gold.dim_customers
GROUP BY customer_tier
ORDER BY SUM(total_spend) DESC;"

Q06_SQL="SELECT 
    COALESCE(c.country, 'Unknown') AS \"Origin Country\",
    COUNT(DISTINCT c.customer_key) AS \"Total Travelers\",
    COUNT(b.booking_id) AS \"Total Tours Booked\",
    ROUND(SUM(b.total_price), 2) AS \"Total Inbound Revenue\",
    ROUND(AVG(b.total_price), 2) AS \"Avg Tour Value\"
FROM gold.fact_bookings b
JOIN gold.dim_customers c ON c.customer_key = b.customer_key
WHERE b.is_confirmed = TRUE
GROUP BY c.country
ORDER BY SUM(b.total_price) DESC
LIMIT 10;"

Q07_SQL="WITH customer_frequency AS (
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
    loyalty_category AS \"Loyalty Bracket\",
    COUNT(customer_key) AS \"Traveler Count\",
    ROUND((COUNT(customer_key) * 100.0) / SUM(COUNT(customer_key)) OVER (), 2) AS \"Share Pct\",
    ROUND(SUM(total_spend), 2) AS \"Total Revenue Generated\"
FROM customer_frequency
GROUP BY loyalty_category
ORDER BY COUNT(customer_key) DESC;"

Q08_SQL="SELECT 
    customer_name AS \"Traveler Name\",
    email AS \"Contact Email\",
    country AS \"Country\",
    customer_tier AS \"Tier\",
    ROUND(total_spend, 2) AS \"Lifetime Spend\",
    last_booking_date AS \"Last Trip Date\",
    CURRENT_DATE - last_booking_date AS \"Days Since Last Tour\"
FROM gold.dim_customers
WHERE customer_tier IN ('VIP Traveler', 'Regular Traveler')
  AND last_booking_date < (CURRENT_DATE - INTERVAL '180 days')
ORDER BY total_spend DESC
LIMIT 15;"

C05=$(create_card "Q05: Customer Tier Distribution & Segmentation" "bar" "$Q05_SQL" '{"graph.dimensions":["Customer Segment"],"graph.metrics":["Total Segment Revenue (LKR)"]}')
C06=$(create_card "Q06: Top 10 Inbound Source Countries by Spend" "bar" "$Q06_SQL" '{"graph.dimensions":["Origin Country"],"graph.metrics":["Total Inbound Revenue (LKR)"]}')
C07=$(create_card "Q07: Traveler Retention & Loyalty Distribution" "pie" "$Q07_SQL" '{"pie.dimension":"Loyalty Bracket","pie.metric":"Traveler Count"}')
C08=$(create_card "Q08: Lapsed High-Value Customers (Churn Risk)" "table" "$Q08_SQL")

mount_dashboard_cards "$DASH2_ID" "$C05" "$C06" "$C07" "$C08"

# ==============================================================================
# DASHBOARD 3: Fleet & Transportation Operations
# ==============================================================================
echo ""
echo ">>> [3/5] Building Dashboard 3: Fleet & Transportation Operations <<<"
DASH3_ID=$(get_or_create_dashboard "3. Fleet & Transportation Operations" "Vehicle category yields, idle capacity warnings, occupancy efficiency, and tour length correlations.")

Q09_SQL="SELECT 
    v.category_name AS \"Vehicle Class\",
    v.comfort_level AS \"Comfort Rating\",
    COUNT(b.booking_id) AS \"Total Trips Dispatched\",
    SUM(b.total_days) AS \"Total Operational Days\",
    ROUND(SUM(b.total_price), 2) AS \"Total Fleet Revenue\",
    ROUND(SUM(b.total_price) / NULLIF(SUM(b.total_days), 0), 2) AS \"Daily Revenue Yield\"
FROM gold.fact_bookings b
JOIN gold.dim_vehicles v ON v.vehicle_key = b.vehicle_key
WHERE b.is_confirmed = TRUE
GROUP BY v.category_name, v.comfort_level
ORDER BY SUM(b.total_price) DESC;"

Q10_SQL="WITH vehicle_recent_activity AS (
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
    vehicle_number AS \"Plate Number\",
    vehicle_name AS \"Model Name\",
    category_name AS \"Class\",
    COALESCE(TO_CHAR(last_dispatched_date, 'YYYY-MM-DD'), 'Never Dispatched') AS \"Last Trip Date\",
    COALESCE(CURRENT_DATE - last_dispatched_date, 999) AS \"Days Sitting Idle\"
FROM vehicle_recent_activity
WHERE last_dispatched_date IS NULL OR last_dispatched_date < (CURRENT_DATE - INTERVAL '30 days')
ORDER BY \"Days Sitting Idle\" DESC;"

Q11_SQL="WITH trip_occupancy AS (
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
    category_name AS \"Vehicle Category\",
    COUNT(booking_id) AS \"Total Dispatches\",
    ROUND(AVG(seat_occupancy_pct), 1) AS \"Avg Seat Occupancy Pct\",
    COUNT(CASE WHEN seat_occupancy_pct < 40.0 THEN 1 END) AS \"Trips Under 40pct Capacity\"
FROM trip_occupancy
GROUP BY category_name
ORDER BY AVG(seat_occupancy_pct) ASC;"

Q12_SQL="WITH trip_durations AS (
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
    trip_duration_bracket AS \"Trip Length\",
    category_name AS \"Vehicle Category\",
    COUNT(*) AS \"Bookings Chosen\",
    ROUND(AVG(total_price), 2) AS \"Avg Tour Revenue\"
FROM trip_durations
GROUP BY trip_duration_bracket, category_name
ORDER BY trip_duration_bracket, COUNT(*) DESC;"

C09=$(create_card "Q09: Vehicle Profitability & Daily Revenue Yield" "bar" "$Q09_SQL" '{"graph.dimensions":["Vehicle Class"],"graph.metrics":["Daily Revenue Yield (LKR)"]}')
C10=$(create_card "Q10: Idle Fleet Identification (>30 Days Idle)" "table" "$Q10_SQL")
C11=$(create_card "Q11: Seating Capacity Utilization & Over-Allocation" "bar" "$Q11_SQL" '{"graph.dimensions":["Vehicle Category"],"graph.metrics":["Avg Seat Occupancy Pct"]}')
C12=$(create_card "Q12: Vehicle Preference by Tour Duration" "table" "$Q12_SQL")

mount_dashboard_cards "$DASH3_ID" "$C09" "$C10" "$C11" "$C12"

# ==============================================================================
# DASHBOARD 4: Destinations & Tour Experience Analytics
# ==============================================================================
echo ""
echo ">>> [4/5] Building Dashboard 4: Destinations & Tour Experience Analytics <<<"
DASH4_ID=$(get_or_create_dashboard "4. Destinations & Tour Experience Analytics" "Top destinations, activity categories, package cancellation vulnerabilities, and corridor density.")

Q13_SQL="SELECT 
    d.place_name AS \"Destination\",
    d.total_package_routes AS \"Package Routes\",
    d.available_activities AS \"Local Activities\",
    COUNT(b.booking_id) AS \"Bookings Routed Here\",
    ROUND(SUM(b.total_price), 2) AS \"Linked Tour Revenue\"
FROM gold.dim_destinations d
JOIN silver.package_place pp ON pp.place_id = d.place_id
JOIN gold.fact_bookings b ON b.package_key = pp.package_id
WHERE b.is_confirmed = TRUE
GROUP BY d.place_id, d.place_name, d.total_package_routes, d.available_activities
ORDER BY SUM(b.total_price) DESC
LIMIT 10;"

Q14_SQL="SELECT 
    act.activity_category AS \"Experience Type\",
    COUNT(DISTINCT act.activity_key) AS \"Distinct Activities Offered\",
    SUM(act.total_hosted_places) AS \"Destination Inclusions\",
    SUM(act.total_package_inclusions) AS \"Package Inclusions\"
FROM gold.dim_activities act
GROUP BY act.activity_category
ORDER BY SUM(act.total_package_inclusions) DESC;"

Q15_SQL="WITH package_cancellations AS (
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
    package_title AS \"Package Title\",
    package_duration AS \"Duration\",
    total_requests AS \"Total Requests\",
    cancelled_requests AS \"Cancelled Tours\",
    ROUND((cancelled_requests::NUMERIC / NULLIF(total_requests, 0)) * 100.0, 1) AS \"Cancellation Rate Pct\"
FROM package_cancellations
WHERE total_requests >= 10
ORDER BY (cancelled_requests::NUMERIC / NULLIF(total_requests, 0)) DESC
LIMIT 10;"

Q16_SQL="SELECT 
    COALESCE(start_location, 'Unspecified Start') AS \"Pickup Point\",
    COALESCE(end_location, 'Unspecified End') AS \"Final Destination\",
    COUNT(booking_id) AS \"Trip Volume\",
    ROUND(SUM(total_price), 2) AS \"Corridor Revenue\",
    ROUND(AVG(total_price), 2) AS \"Average Trip Fare\"
FROM gold.fact_bookings
WHERE is_confirmed = TRUE
GROUP BY start_location, end_location
ORDER BY COUNT(booking_id) DESC
LIMIT 10;"

C13=$(create_card "Q13: Top 10 Destination Hotspots by Revenue" "bar" "$Q13_SQL" '{"graph.dimensions":["Destination"],"graph.metrics":["Linked Tour Revenue (LKR)"]}')
C14=$(create_card "Q14: Activity Category Revenue Contribution" "bar" "$Q14_SQL" '{"graph.dimensions":["Experience Type"],"graph.metrics":["Package Inclusions"]}')
C15=$(create_card "Q15: Tour Packages with Highest Cancellation Rate" "bar" "$Q15_SQL" '{"graph.dimensions":["Package Title"],"graph.metrics":["Cancellation Rate Pct"]}')
C16=$(create_card "Q16: Busiest Travel Corridors & Route Density" "table" "$Q16_SQL")

mount_dashboard_cards "$DASH4_ID" "$C13" "$C14" "$C15" "$C16"

# ==============================================================================
# DASHBOARD 5: Operations Funnel, Service SLAs & Quality
# ==============================================================================
echo ""
echo ">>> [5/5] Building Dashboard 5: Operations Funnel, Service SLAs & Quality <<<"
DASH5_ID=$(get_or_create_dashboard "5. Operations Funnel, Service SLAs & Quality" "Booking conversion funnel drop-offs, booking confirmation turnaround, 24h SLA compliance, and driver sentiment.")

Q17_SQL="SELECT 
    new_status AS \"Funnel Milestone\",
    COUNT(DISTINCT booking_id) AS \"Bookings Reached Stage\",
    ROUND((COUNT(DISTINCT booking_id) * 100.0) / (SELECT COUNT(DISTINCT booking_id) FROM gold.fact_booking_lifecycle), 1) AS \"Conversion Rate From Top Pct\",
    ROUND(AVG(hours_since_prior_status), 1) AS \"Avg Hours Spent In Prior Stage\"
FROM gold.fact_booking_lifecycle
GROUP BY new_status
ORDER BY COUNT(DISTINCT booking_id) DESC;"

Q18_SQL="WITH confirmation_latencies AS (
    SELECT 
        booking_id,
        hours_since_prior_status AS confirmation_hours
    FROM gold.fact_booking_lifecycle
    WHERE new_status = 'CONFIRMED'
      AND hours_since_prior_status IS NOT NULL
)
SELECT 
    CASE 
        WHEN confirmation_hours <= 4.0 THEN 'Fast (<= 4 Hours) [Met SLA]'
        WHEN confirmation_hours BETWEEN 4.0 AND 24.0 THEN 'Moderate (4 to 24 Hours)'
        ELSE 'Slow (> 24 Hours) [SLA Breached]'
    END AS sla_performance_tier,
    COUNT(booking_id) AS \"Bookings Processed\",
    ROUND((COUNT(booking_id) * 100.0) / SUM(COUNT(booking_id)) OVER (), 1) AS \"Share of Total Pct\"
FROM confirmation_latencies
GROUP BY 
    CASE 
        WHEN confirmation_hours <= 4.0 THEN 'Fast (<= 4 Hours) [Met SLA]'
        WHEN confirmation_hours BETWEEN 4.0 AND 24.0 THEN 'Moderate (4 to 24 Hours)'
        ELSE 'Slow (> 24 Hours) [SLA Breached]'
    END
ORDER BY COUNT(booking_id) DESC;"

Q19_SQL="SELECT 
    inquiry_status AS \"Inquiry Status\",
    COUNT(inquiry_id) AS \"Total Web Inquiries\",
    COUNT(CASE WHEN is_registered_customer THEN 1 END) AS \"Inquiries From Members\",
    ROUND(AVG(response_latency_hours), 1) AS \"Avg Response Time (Hours)\",
    COUNT(CASE WHEN is_sla_breached_24h THEN 1 END) AS \"SLA Breaches (>24h)\",
    ROUND((COUNT(CASE WHEN is_sla_breached_24h THEN 1 END) * 100.0) / NULLIF(COUNT(inquiry_id), 0), 1) AS \"SLA Breach Rate Pct\"
FROM gold.fact_customer_inquiries
GROUP BY inquiry_status
ORDER BY COUNT(inquiry_id) DESC;"

Q20_SQL="SELECT 
    COALESCE(driver_name, 'Unassigned / Independent') AS \"Driver Name\",
    COUNT(review_id) AS \"Total Reviews Received\",
    ROUND(AVG(rating), 2) AS \"Average Star Rating\",
    COUNT(CASE WHEN sentiment_label = 'EXCELLENT' THEN 1 END) AS \"5-Star Ratings\",
    COUNT(CASE WHEN sentiment_label = 'POOR' THEN 1 END) AS \"1-2 Star Ratings\",
    ROUND((COUNT(CASE WHEN sentiment_label = 'EXCELLENT' THEN 1 END) * 100.0) / COUNT(review_id), 1) AS \"Excellence Rate Pct\"
FROM gold.fact_reviews
GROUP BY driver_name
HAVING COUNT(review_id) >= 5
ORDER BY AVG(rating) DESC, COUNT(review_id) DESC
LIMIT 10;"

C17=$(create_card "Q17: Booking Funnel Conversion & Bottlenecks" "bar" "$Q17_SQL" '{"graph.dimensions":["Funnel Milestone"],"graph.metrics":["Conversion Rate From Top Pct"]}')
C18=$(create_card "Q18: Booking Confirmation Response Time SLA" "pie" "$Q18_SQL" '{"pie.dimension":"sla_performance_tier","pie.metric":"Bookings Processed"}')
C19=$(create_card "Q19: Web Inquiries Response Time & 24h SLA" "table" "$Q19_SQL")
C20=$(create_card "Q20: Driver Service Quality & Review Sentiment" "table" "$Q20_SQL")

mount_dashboard_cards "$DASH5_ID" "$C17" "$C18" "$C19" "$C20"

# ==============================================================================
# DASHBOARD 0: Enterprise Gold Data Warehouse - Schema Catalog & Architecture Hub
# ==============================================================================
echo ""
echo ">>> [0/5] Building Master Landing Dashboard: Gold Schema Catalog <<<"
DASH0_ID=$(get_or_create_dashboard "0. Enterprise Gold Data Warehouse - Schema Catalog & Architecture Hub" "Master landing catalog displaying all 6 Gold Dimensions, 5 Fact Tables, and 1 Analytical Mart.")

Q_DIMS_SQL="SELECT 
    '1. dim_date' AS \"Dimension Table\",
    'Calendar dates, tourism seasons & holidays' AS \"Business Context\",
    COUNT(*) AS \"Record Count\"
FROM gold.dim_date
UNION ALL
SELECT 
    '2. dim_customers',
    'Traveler master: demographics, VIP tiers & LTV',
    COUNT(*)
FROM gold.dim_customers
UNION ALL
SELECT 
    '3. dim_vehicles',
    'Fleet assets: categories, license plates & comfort',
    COUNT(*)
FROM gold.dim_vehicles
UNION ALL
SELECT 
    '4. dim_destinations',
    'Geographic landmarks: GIS lat/long & routes',
    COUNT(*)
FROM gold.dim_destinations
UNION ALL
SELECT 
    '5. dim_packages',
    'Tour catalog: Adventure, Cultural, Safari packages',
    COUNT(*)
FROM gold.dim_packages
UNION ALL
SELECT 
    '6. dim_activities',
    'Tour attractions: Safaris, Surfing, Trekking',
    COUNT(*)
FROM gold.dim_activities
ORDER BY 1;"

Q_FACTS_SQL="SELECT 
    '1. fact_bookings' AS \"Fact Table / Mart\",
    'Core transaction grain: Confirmed and quoted bookings' AS \"Business Grain\",
    COUNT(*) AS \"Total Records\"
FROM gold.fact_bookings
UNION ALL
SELECT 
    '2. fact_payments',
    'Financial grain: Cash and bank transfer payments',
    COUNT(*)
FROM gold.fact_payments
UNION ALL
SELECT 
    '3. fact_booking_lifecycle',
    'Audit grain: Status change transitions and latencies',
    COUNT(*)
FROM gold.fact_booking_lifecycle
UNION ALL
SELECT 
    '4. fact_customer_inquiries',
    'Support grain: Customer inquiries and response SLAs',
    COUNT(*)
FROM gold.fact_customer_inquiries
UNION ALL
SELECT 
    '5. fact_reviews',
    'Experience grain: Tour feedback and driver ratings',
    COUNT(*)
FROM gold.fact_reviews
UNION ALL
SELECT 
    '6. mart_daily_performance',
    'Executive Daily Mart: Daily revenue, pax, and tour counts',
    COUNT(*)
FROM gold.mart_daily_performance
ORDER BY 1;"

Q_KPI_BOOKINGS="SELECT COUNT(*) AS total_bookings FROM gold.fact_bookings WHERE is_confirmed = TRUE;"
Q_KPI_REVENUE="SELECT ROUND(SUM(total_price), 2) AS total_revenue FROM gold.fact_bookings WHERE is_confirmed = TRUE;"

C_DIMS=$(create_card "Catalog: 6 Gold Dimensions Master Registry" "table" "$Q_DIMS_SQL")
C_FACTS=$(create_card "Catalog: 5 Fact Tables & 1 Analytical Mart Registry" "table" "$Q_FACTS_SQL")
C_KPI_B=$(create_card "Metric: Confirmed Bookings Count" "scalar" "$Q_KPI_BOOKINGS")
C_KPI_R=$(create_card "Metric: Total Confirmed Revenue (LKR)" "scalar" "$Q_KPI_REVENUE")

cat_mount_body=$(cat <<EOF
{"cards":[{"id":-1,"card_id":$C_KPI_B,"row":0,"col":0,"size_x":12,"size_y":4},{"id":-2,"card_id":$C_KPI_R,"row":0,"col":12,"size_x":12,"size_y":4},{"id":-3,"card_id":$C_DIMS,"row":4,"col":0,"size_x":12,"size_y":10},{"id":-4,"card_id":$C_FACTS,"row":4,"col":12,"size_x":12,"size_y":10}]}
EOF
)

cat_mount_resp=$(curl -s -w "\n%{http_code}" -X PUT "$MB_URL/api/dashboard/$DASH0_ID/cards" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $SESSION_ID" \
  -d "$cat_mount_body")
cat_http_code=$(echo "$cat_mount_resp" | tail -n 1)

if [ "$cat_http_code" -ge 200 ] && [ "$cat_http_code" -lt 300 ]; then
    echo "  -> Successfully mounted Catalog cards (IDs: $C_KPI_B, $C_KPI_R, $C_DIMS, $C_FACTS) to Dashboard #$DASH0_ID"
else
    echo "  -> Error mounting Catalog cards to Dashboard #$DASH0_ID (HTTP $cat_http_code)" >&2
fi

# ------------------------------------------------------------------------------
# CONFIGURE METABASE DEFAULT HOMEPAGE
# ------------------------------------------------------------------------------
echo ""
echo ">>> Setting Dashboard #$DASH0_ID as Permanent Default Homepage <<<"
curl -s -X PUT "$MB_URL/api/setting/custom-homepage" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $SESSION_ID" \
  -d '{"value": true}' > /dev/null

curl -s -X PUT "$MB_URL/api/setting/custom-homepage-dashboard" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $SESSION_ID" \
  -d "{\"value\": $DASH0_ID}" > /dev/null

curl -s -X PUT "$MB_URL/api/setting/show-homepage-data" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $SESSION_ID" \
  -d '{"value": false}' > /dev/null

curl -s -X PUT "$MB_URL/api/setting/show-homepage-xrays" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $SESSION_ID" \
  -d '{"value": false}' > /dev/null

curl -s -X PUT "$MB_URL/api/setting/show-homepage-pin-message" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $SESSION_ID" \
  -d '{"value": false}' > /dev/null

echo "Homepage configured: Users now land directly on the Gold Warehouse Hub."

echo ""
echo "=========================================================="
echo ">>> ALL 5 DASHBOARDS, CATALOG HUB & 20 CARDS COMPLETED! <<<"
echo "=========================================================="
