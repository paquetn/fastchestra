#!/bin/bash

# Check if a custom path for the environment file is provided as the first argument
ENV_FILE="${1:-./fastchestra/fastchestra.env}"

# Load environment variables from the specified env file
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' $ENV_FILE | xargs)
    echo "Environment variables loaded from $ENV_FILE"
else
    echo "Error: $ENV_FILE file not found. Ensure the file exists and try again."
    exit 1
fi

# CONFIRMING DATABASE NAME FOR SETUP
echo "Database setup for $TEST_DB_NAME on $TEST_DB_HOST"

# CREATING TEST DATABASE
sqlcmd -S $FC_DB_HOST -U $FC_DB_USER -P $FC_DB_PASSWORD -Q "CREATE DATABASE [$TEST_DB_NAME];"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create database. Check if the database already exists."
    exit 1
fi

# CREATE LOGIN FOR TEST DATABASE
echo "Creating login for test database..."
sqlcmd -S $FC_DB_HOST -U $FC_DB_USER -P $FC_DB_PASSWORD -Q "
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = '$TEST_DB_USER')
BEGIN
    CREATE LOGIN [$TEST_DB_USER] WITH PASSWORD = '$TEST_DB_PASSWORD';
    PRINT 'Login $TEST_DB_USER created.';
END
ELSE
BEGIN
    PRINT 'Login $TEST_DB_USER already exists.';
END
"

# CREATE OR MAP THE TEST USER TO THE TEST DATABASE
echo "Creating test user..."

sqlcmd -S $FC_DB_HOST -U $FC_DB_USER -P $FC_DB_PASSWORD -Q "
USE [$TEST_DB_NAME];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '$TEST_DB_USER')
BEGIN
    CREATE USER [$TEST_DB_USER] FOR LOGIN [$TEST_DB_USER];
    PRINT 'User $TEST_DB_USER created.';
END
ELSE
BEGIN
    PRINT 'User $TEST_DB_USER already exists.';
END
"

# APPLY PERMISSIONS TO THE TEST USER
echo "Applying permissions to test user..."
sqlcmd -S $FC_DB_HOST -U $FC_DB_USER -P $FC_DB_PASSWORD -d $TEST_DB_NAME -Q "
ALTER ROLE db_owner ADD MEMBER [$TEST_DB_USER]; 
ALTER ROLE db_datareader ADD MEMBER [$TEST_DB_USER];
EXEC sp_addsrvrolemember '$TEST_DB_USER', 'dbcreator';
GRANT ALTER ON SCHEMA::dbo TO [$TEST_DB_USER];
GRANT CONTROL ON SCHEMA::dbo TO [$TEST_DB_USER];
"

if [ $? -ne 0 ]; then
    echo "Error: Failed to apply permissions to test user."
    exit 1
fi

# APPYING ALEMBIC MIGRATIONS
echo "Applying Alembic migrations..."

export TESTING=True

alembic upgrade head
if [ $? -ne 0 ]; then
    echo "Error: Failed to apply Alembic migrations."
    exit 1
fi

echo "Database setup complete."