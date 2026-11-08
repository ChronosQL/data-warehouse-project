#!/bin/sh
set -e

echo "=========================================================="
echo ">>> METABASE AUTOMATED INITIALIZATION & SCHEMA SYNC <<<"
echo "=========================================================="

echo "Waiting for Metabase service on http://metabase:3000..."

# Wait until Metabase health endpoint returns 200
until curl -s -f --connect-timeout 2 http://metabase:3000/api/health > /dev/null 2>&1; do
    echo "Metabase is still starting up... waiting 2 seconds..."
    sleep 2
done

echo "Metabase is UP and HEALTHY!"

# Check if Metabase is already configured
PROPERTIES=$(curl -s http://metabase:3000/api/session/properties)
HAS_SETUP=$(echo "$PROPERTIES" | jq -r '."has-user-setup"' 2>/dev/null || true)

if [ "$HAS_SETUP" != "true" ]; then
    echo "Extracting dynamic setup token..."
    TOKEN=$(echo "$PROPERTIES" | jq -r '."setup-token"' 2>/dev/null || true)
    
    if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
        echo "Registering Admin account (admin@admin.com)..."
        curl -s -X POST http://metabase:3000/api/setup \
          -H "Content-Type: application/json" \
          -d "{
            \"token\": \"$TOKEN\",
            \"user\": {
              \"first_name\": \"Admin\",
              \"last_name\": \"User\",
              \"email\": \"admin@admin.com\",
              \"password\": \"AdminPassword123!\"
            },
            \"prefs\": {
              \"site_name\": \"Tours Data Warehouse Analytics\",
              \"allow_tracking\": false
            }
          }" > /dev/null
        echo "Admin user created successfully!"
    fi
fi

# Obtain session token
echo "Authenticating session..."
SESSION_RESP=$(curl -s -X POST http://metabase:3000/api/session \
  -H "Content-Type: application/json" \
  -d '{"username":"admin@admin.com","password":"AdminPassword123!"}')
SESSION_ID=$(echo "$SESSION_RESP" | jq -r .id 2>/dev/null || true)

if [ -z "$SESSION_ID" ] || [ "$SESSION_ID" = "null" ]; then
    echo "Failed to acquire session token. Response: $SESSION_RESP"
    exit 1
fi

echo "Session authenticated."

# Check if Tours Data Warehouse database is already connected
EXISTING_DBS=$(curl -s http://metabase:3000/api/database -H "X-Metabase-Session: $SESSION_ID")
DB_ID=$(echo "$EXISTING_DBS" | jq -r '(.data // .)[] | select(.name=="Tours Data Warehouse") | .id' 2>/dev/null | head -n 1)

if [ -n "$DB_ID" ] && [ "$DB_ID" != "null" ]; then
    echo "Database 'Tours Data Warehouse' is already registered in Metabase (ID: $DB_ID)."
else
    echo "Connecting PostgreSQL warehouse database 'tours_dw'..."
    ADD_DB_RESP=$(curl -s -X POST http://metabase:3000/api/database \
      -H "Content-Type: application/json" \
      -H "X-Metabase-Session: $SESSION_ID" \
      -d '{
        "name": "Tours Data Warehouse",
        "engine": "postgres",
        "details": {
          "host": "postgres",
          "port": 5432,
          "dbname": "tours_dw",
          "user": "admin",
          "password": "admin123",
          "ssl": false
        },
        "is_full_sync": true,
        "auto_run_queries": true
      }')
    DB_ID=$(echo "$ADD_DB_RESP" | jq -r .id 2>/dev/null || true)
    echo "Database registered successfully (ID: $DB_ID)! Metabase is now scanning 'gold' and 'silver' schemas."
fi

# Fallback DB_ID check
if [ -z "$DB_ID" ] || [ "$DB_ID" = "null" ]; then
    DB_ID=$(curl -s http://metabase:3000/api/database -H "X-Metabase-Session: $SESSION_ID" | jq -r '(.data // .)[] | select(.name=="Tours Data Warehouse") | .id' 2>/dev/null | head -n 1)
fi

# ------------------------------------------------------------------------------
# AUTOMATICALLY TRIGGER 5 DASHBOARDS & 20 QUESTIONS CREATION
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(dirname "$0")"
if [ -f "/create_dashboards.sh" ]; then
    echo ""
    echo "=========================================================="
    echo ">>> LAUNCHING AUTOMATED DASHBOARD BUILDER <<<"
    echo "=========================================================="
    /bin/sh /create_dashboards.sh "$SESSION_ID" "$DB_ID"
elif [ -f "$SCRIPT_DIR/create_dashboards.sh" ]; then
    echo ""
    echo "=========================================================="
    echo ">>> LAUNCHING AUTOMATED DASHBOARD BUILDER <<<"
    echo "=========================================================="
    /bin/sh "$SCRIPT_DIR/create_dashboards.sh" "$SESSION_ID" "$DB_ID"
fi

echo "=========================================================="
echo ">>> METABASE AUTO-CONFIGURATION COMPLETED SUCCESSFULLY! <<<"
echo "=========================================================="
