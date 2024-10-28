#!/bin/bash

# Load environment variables from .env or custom env file
if [ -f ../fastchestra.env ]; then
    export $(grep -v '^#' ../fastchestra.env | xargs)
else
    echo "Error: fastchestra.env file not found. Ensure the file exists and try again."
    exit 1
fi

# CREATING TEST DATABASE
sqlcmd -S $DB_HOST -U $DB_USER -P $DB_PASSWORD -Q "CREATE DATABASE [$DB_NAME];"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create database. Check if the database already exists."
    exit 1
fi

# CREATE OR MAP THE APPLICATION USER TO THE TEST DATABASE
echo "Creating application user..."
sqlcmd -S $DB_HOST -U $DB_USER -P $DB_PASSWORD -d $DB_NAME -Q "
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '$DB_APP_USER')
BEGIN
    CREATE USER [$DB_APP_USER] FOR LOGIN [$DB_APP_USER];
    PRINT 'User $DB_APP_USER created.';
END
ELSE
BEGIN
    PRINT 'User $DB_APP_USER already exists.';
END
"
# APPLY PERMISSIONS TO THE APPLICATION USER
echo "Applying permissions to application user..."
sqlcmd -S $DB_HOST -U $DB_USER -P $DB_PASSWORD -d $DB_NAME -Q "
ALTER ROLE db_owner ADD MEMBER [$DB_APP_USER]; 
ALTER ROLE db_datareader ADD MEMBER [$DB_APP_USER];
EXEC sp_addsrvrolemember '$DB_APP_USER', 'dbcreator';
GRANT ALTER ON SCHEMA::dbo TO [$DB_APP_USER];
GRANT CONTROL ON SCHEMA::dbo TO [$DB_APP_USER];
"
if [ $? -ne 0 ]; then
    echo "Error: Failed to apply permissions to application user."
    exit 1
fi


# APPYING ALEMBIC MIGRATIONS
echo "Applying Alembic migrations..."
alembic upgrade head
if [ $? -ne 0 ]; then
    echo "Error: Failed to apply Alembic migrations."
    exit 1
fi

# (Optional) Seed the database with initial data
# python seed.py 

echo "Database setup complete."
