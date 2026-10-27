#!/bin/sh
set -e

echo "=========================================================="
echo ">>> METABASE AUTOMATED INITIALIZATION & SCHEMA SYNC <<<"
echo "=========================================================="

echo "Waiting for Metabase service on http://metabase:3000..."

# Wait until Metabase health endpoint returns 200
until curl -s -f http://metabase:3000/api/health > /dev/null 2>&1; do
    echo "Metabase is still starting up... waiting 5 seconds..."
    sleep 5
done

echo "Metabase is UP and HEALTHY!"

# Check if Metabase is already configured
PROPERTIES=$(curl -s http://metabase:3000/api/session/properties)
HAS_SETUP=$(echo "$PROPERTIES" | grep -o '"has-user-setup":true' || true)

if [ "$HAS_SETUP" != '"has-user-setup":true' ]; then
    echo "Extracting dynamic setup token..."
    TOKEN=$(curl -s http://metabase:3000/api/session/properties | grep -o '"setup-token":"[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$TOKEN" ]; then
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
SESSION_ID=$(echo "$SESSION_RESP" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')

if [ -z "$SESSION_ID" ]; then
    echo "Failed to acquire session token. Response: $SESSION_RESP"
    exit 1
fi

echo "Session authenticated."

# Check if Tours Data Warehouse database is already connected
EXISTING_DBS=$(curl -s http://metabase:3000/api/database -H "X-Metabase-Session: $SESSION_ID")
if echo "$EXISTING_DBS" | grep -q '"name":"Tours Data Warehouse"'; then
    echo "Database 'Tours Data Warehouse' is already registered in Metabase."
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
    echo "Database registered successfully! Metabase is now scanning 'gold' and 'silver' schemas."
fi

echo "=========================================================="
echo ">>> METABASE AUTO-CONFIGURATION COMPLETED SUCCESSFULLY! <<<"
echo "=========================================================="
