#!/bin/bash

# Load environment variables from .env or custom env file
if [ -f ../fastchestra.env ]; then
    export $(grep -v '^#' ../fastchestra.env | xargs)
else
    echo "Error: fastchestra.env file not found. Ensure the file exists and try again."
    exit 1
fi

# RUN PYTEST WITH COVERAGE
echo "Running tests..."
pytest --cov=app tests/

# IF PYTEST FAILS, EXIT WITH ERROR CODE
if [ $? -ne 0 ]; then
    echo "Error: Tests failed."
    exit 1
fi

# DROP THE TEST DATABASE
echo "Dropping test database..."
sqlcmd -S $DB_HOST -U $DB_USER -P $DB_PASSWORD -Q "DROP DATABASE [$DB_NAME];"

echo "Test execution and cleanup complete!"