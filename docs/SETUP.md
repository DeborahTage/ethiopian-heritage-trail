# Local Development Setup Guide

## Requirements
- Java 21 LTS
- Node.js 20+
- Flutter SDK (latest stable)
- PostgreSQL 15+ locally or via Docker
- Redis locally or via Docker

## 1. Backend (Spring Boot)
1. Navigate to `/backend`
2. Configure `.env` or just rely on default `application.yml`.
3. Startup PostgreSQL/Redis via `docker-compose up db redis -d`.
4. Run `mvn spring-boot:run`. The backend will run on `9002`.

## 2. Dashboard (React Vite)
1. Navigate to `/dashboard`
2. Install dependencies: `npm install`
3. Run the dev server: `npm run dev`
4. The application will map API queries natively to `http://localhost:9002` using the `.env` settings.

## 3. Mobile App (Flutter)
1. Navigate to `/mobile`
2. Run `flutter pub get`
3. Ensure a connected emulator/device.
4. Run `flutter run`. (Note: Make sure to point API URLs in configuration to your local machine IP, usually `http://10.0.2.2:9002` for Android or `http://localhost:9002` for iOS).
