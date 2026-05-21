# Ethiopian Heritage Trail

A comprehensive geo-fenced QR tourism passport application for exploring Ethiopian heritage sites. Built with Spring Boot backend, React admin dashboard, and Flutter mobile app.

## 🏛️ Features

### Mobile App (Flutter)
- **QR Code Scanner** with GPS verification
- **Offline Support** with automatic sync
- **Digital Passport** tracking visited landmarks
- **Reward System** with badges and points
- **Multi-language** support (English/Amharic)
- **Real-time Notifications** for nearby landmarks

### Admin Dashboard (React)
- **Landmark Management** with rich content editor
- **Analytics Dashboard** with heatmaps and visitor flow
- **QR Code Generation** for physical markers
- **User Management** and role-based access
- **Content Management** with media upload

### Backend (Spring Boot)
- **RESTful API** with JWT authentication
- **PostGIS Integration** for geospatial queries
- **Real-time Analytics** with Redis caching
- **File Storage** with MinIO S3-compatible storage
- **Rate Limiting** and security features

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Flutter SDK (for mobile development)
- Node.js 18+ (for dashboard development)
- Java 17+ (for backend development)

### 1. Start Backend Services
```bash
# Clone the repository
git clone https://github.com/NaniAmu/ethiopian-heritage-trail.git
cd ethiopian-heritage-trail

# Start all services with Docker
docker compose up -d

# Verify services are running
curl http://localhost:8080/actuator/health
```

### 2. Run Admin Dashboard
```bash
cd dashboard
npm install
npm run dev

# Open http://localhost:5173
# Login: admin@heritage.et / Admin@1234
```

### 3. Run Mobile App
```bash
cd mobile
flutter pub get
flutter run

# For physical device, update the IP in lib/utils/app_config.dart
# Register new account or use: dibora@gmail.com / Test@1234
```

## 📱 Mobile App Setup

### Network Configuration
The mobile app needs to connect to your computer's backend. Update the IP address:

**File:** `mobile/lib/utils/app_config.dart`
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:8080/api/v1';
```

### Device-Specific URLs
| Device Type | Base URL |
|-------------|----------|
| Android Emulator | `http://10.0.2.2:8080/api/v1` |
| iOS Simulator | `http://localhost:8080/api/v1` |
| Physical Device | `http://192.168.x.x:8080/api/v1` |

### Android Setup
Ensure `android:usesCleartextTraffic="true"` is in `AndroidManifest.xml` for HTTP connections.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  React Dashboard │    │  Spring Boot    │
│                 │    │                 │    │     Backend     │
│ • QR Scanner    │◄──►│ • Analytics     │◄──►│ • REST API      │
│ • GPS Verify    │    │ • Landmarks     │    │ • JWT Auth      │
│ • Offline Sync  │    │ • Content CMS   │    │ • PostGIS       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                              ┌─────────────────────────────────────┐
                              │           Infrastructure            │
                              │                                     │
                              │ PostgreSQL + PostGIS (Geospatial)  │
                              │ Redis (Caching & Rate Limiting)    │
                              │ MinIO (S3-compatible File Storage) │
                              └─────────────────────────────────────┘
```

## 🗄️ Database Schema

### Core Entities
- **Users** - Authentication and profiles
- **Landmarks** - Heritage sites with GPS coordinates
- **Visits** - User check-ins with GPS verification
- **Rewards** - Achievement system
- **LandmarkContent** - Rich media and stories

### Key Features
- **PostGIS** for geospatial queries and distance calculations
- **Flyway** migrations for version control
- **Audit trails** with created/updated timestamps

## 🔧 Development

### Backend Development
```bash
cd backend
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### Frontend Development
```bash
cd dashboard
npm run dev
```

### Mobile Development
```bash
cd mobile
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

## 🚀 Deployment

### Production Deployment
```bash
# Build and deploy all services
docker compose -f docker-compose.prod.yml up -d

# Or deploy to cloud platforms
# See docs/DEPLOY.md for detailed instructions
```

### Environment Variables
Key environment variables in `.env`:
- `POSTGRES_PASSWORD` - Database password
- `JWT_SECRET` - JWT signing secret
- `MINIO_ROOT_PASSWORD` - File storage password
- `REDIS_PASSWORD` - Cache password

## 📊 API Documentation

### Authentication
```bash
# Register new user
POST /api/v1/auth/register
{
  "email": "user@example.com",
  "password": "SecurePass123",
  "displayName": "John Doe"
}

# Login
POST /api/v1/auth/login
{
  "email": "user@example.com", 
  "password": "SecurePass123"
}
```

### QR Scanning
```bash
# Claim visit (requires GPS verification)
POST /api/v1/visits/claim
{
  "qrPayload": "heritage-trail://visit/landmark-id?secret=xyz",
  "latitude": 9.0307,
  "longitude": 38.7406
}
```

See `docs/API.md` for complete API documentation.

## 🧪 Testing

### Backend Tests
```bash
cd backend
./mvnw test
```

### Mobile Tests
```bash
cd mobile
flutter test
flutter integration_test integration_test/scanner_flow_test.dart
```

### E2E Tests
```bash
cd dashboard
npm run test:e2e
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Ethiopian Tourism Organization
- PostGIS for geospatial capabilities
- Flutter community for mobile development
- Spring Boot ecosystem

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Check the documentation in `/docs`
- Review the setup guides in each component

---

**Built with ❤️ for Ethiopian Heritage Preservation**