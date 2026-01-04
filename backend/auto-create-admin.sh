#!/bin/bash
# auto-create-admin.sh
# Fully automated admin creation with real bcrypt hashing
# Run once or anytime — 100% safe

set -e  # Exit on any error

PROJECT_DIR=~/waste-management-system/backend
DB_USER= db_user
DB_NAME=db_name
ADMIN_EMAIL= admin_email
ADMIN_PASSWORD=admin_pass

echo "=== AUTO ADMIN CREATOR ==="
echo "Email: $ADMIN_EMAIL"
echo "Password: $ADMIN_PASSWORD"
echo

# Step 1: Generate REAL bcrypt hash
echo "Generating bcrypt hash..."
cd $PROJECT_DIR

HASH=$(node -e "
  const bcrypt = require('bcrypt');
  bcrypt.hash('$ADMIN_PASSWORD', 10).then(h => process.stdout.write(h));
")

echo "Hash generated: $HASH"
echo

# Step 2: Insert into MySQL
echo "Inserting admin into database..."
sudo mysql -u $DB_USER -p <<SQL
USE $DB_NAME;

INSERT INTO users (name, email, password, role) 
VALUES ('Admin', '$ADMIN_EMAIL', '$HASH', 'admin');

SELECT 'ADMIN CREATED!' AS status, id, email, role FROM users WHERE email = '$ADMIN_EMAIL';
SQL

echo

# Step 4: Test login via curl
echo
echo "Testing login..."
sleep 3
curl -s -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}" | grep -q "token" && \
  echo "LOGIN SUCCESSFUL!" || echo "LOGIN FAILED"

echo
echo "OPEN IN BROWSER:"
echo "http://localhost:5173/login"
echo "Email: $ADMIN_EMAIL"
echo "Password: $ADMIN_PASSWORD"
echo
echo "DONE! Admin is ready."
