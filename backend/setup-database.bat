@echo off
REM Database Setup Script for Together Tunes (Windows)
REM This script creates the PostgreSQL database and runs Prisma migrations

echo.
echo 🗄️  Together Tunes - Database Setup
echo =====================================
echo.

REM Check if .env file exists
if not exist ".env" (
    echo ❌ .env file not found!
    echo.
    echo Please follow these steps:
    echo 1. Copy .env.example to .env
    echo 2. Edit .env with your PostgreSQL credentials
    echo 3. Run this script again
    echo.
    pause
    exit /b 1
)

REM Install npm dependencies
echo 1️⃣  Installing npm dependencies...
call npm install
if errorlevel 1 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

REM Run Prisma migrations
echo.
echo 2️⃣  Running Prisma migrations...
call npx prisma migrate dev --name init
if errorlevel 1 (
    echo ❌ Failed to run migrations
    echo.
    echo Troubleshooting:
    echo - Make sure PostgreSQL is running
    echo - Check DATABASE_URL in .env file
    echo - Try: npx prisma db push
    pause
    exit /b 1
)

REM Generate Prisma Client
echo.
echo 3️⃣  Generating Prisma Client...
call npx prisma generate

echo.
echo ✅ Database setup complete!
echo.
echo 📚 Next steps:
echo    1. Start the server: npm start
echo    2. View database in Prisma Studio: npx prisma studio
echo    3. Run Flutter app: flutter run
echo.
pause
