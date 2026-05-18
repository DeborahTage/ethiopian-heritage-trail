# 🇪🇹 Ethiopian Heritage Trail

> A geo-fenced QR tourism passport app celebrating Ethiopia's cultural landmarks.

Visitors scan QR codes at real-world heritage sites, earn digital rewards, and collect a virtual passport. The platform provides rich analytics for site administrators.

## Architecture

```
ethiopian-heritage-trail/
├── backend/          # Spring Boot 3 REST API
├── mobile/           # Flutter mobile app (iOS + Android)
├── dashboard/        # React admin dashboard
├── database/
│   └── migrations/   # Flyway SQL migrations
└── docker/           # Auxiliary docker config
```

## Services (docker-compose)

| Service    | Image                          | Port  |
|------------|-------------------------------|-------|
| PostgreSQL | postgis/postgis:16-3.4-alpine  | 5432  |
| Redis      | redis:7-alpine                 | 6379  |
| MinIO      | minio/minio:latest             | 9000 / 9001 |
| Backend    | (built locally)                | 8080  |

## Quick Start

```bash
# 1. Copy env file
cp .env.example .env

# 2. Start infrastructure
docker compose up -d postgres redis minio

# 3. Run backend (dev)
cd backend
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# 4. Or start everything
docker compose up --build
```

## API Base URL

```
http://localhost:8080/api/v1
```

## Tech Stack

- **Backend:** Spring Boot 3, Spring Security (JWT), JPA/Hibernate, Flyway, PostGIS, Redis, ZXing, Firebase Admin, MinIO S3
- **Mobile:** Flutter 3, Riverpod, mobile_scanner, google_maps_flutter
- **Dashboard:** React + Vite, Recharts, Leaflet
- **Database:** PostgreSQL 16 + PostGIS 3.4
- **Cache:** Redis 7
- **Storage:** MinIO (S3-compatible)

## Migrations

Flyway migrations live in `database/migrations/`:

| Version | Description |
|---------|-------------|
| V1 | Enable PostGIS |
| V2 | Core schema |
| V3 | Indexes & constraints |
| V4 | Seed landmarks |
