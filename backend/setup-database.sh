#!/bin/bash

# Database Setup Script for Together Tunes
# This script creates the PostgreSQL database and runs Prisma migrations

echo "🗄️  Together Tunes - Database Setup"
echo "===================================="

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL is not installed. Please install PostgreSQL first."
    echo "   - Windows: https://www.postgresql.org/download/windows/"
    echo "   - macOS: brew install postgresql"
    echo "   - Linux: sudo apt-get install postgresql"
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | xargs)
else
    echo "❌ .env file not found. Please copy .env.example to .env and configure it."
    exit 1
fi

# Extract database details from DATABASE_URL
# Format: postgresql://user:password@host:port/dbname
DB_USER=${DB_USER:-"postgres"}
DB_PASSWORD=${DB_PASSWORD:-""}
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-"5432"}
DB_NAME=${DB_NAME:-"together_tunes"}

echo "📝 Database Details:"
echo "   Host: $DB_HOST"
echo "   Port: $DB_PORT"
echo "   Database: $DB_NAME"
echo "   User: $DB_USER"
echo ""

# Create database
echo "1️⃣  Creating database '$DB_NAME'..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
  PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "CREATE DATABASE $DB_NAME;"

if [ $? -eq 0 ]; then
    echo "✅ Database created/verified"
else
    echo "⚠️  Could not create database (it may already exist)"
fi

# Install dependencies
echo ""
echo "2️⃣  Installing npm dependencies..."
npm install

# Run Prisma migrations
echo ""
echo "3️⃣  Running Prisma migrations..."
npx prisma migrate dev --name init

# Generate Prisma Client
echo ""
echo "4️⃣  Generating Prisma Client..."
npx prisma generate

echo ""
echo "✅ Database setup complete!"
echo ""
echo "📚 Next steps:"
echo "   1. Start the server: npm start"
echo "   2. View database in Prisma Studio: npx prisma studio"
echo "   3. Run Flutter app: flutter run"
