# Ethiopian Heritage Trail - Open API

## Base URL
`http://localhost:9002/api/v1`

## Authentication
`POST /auth/login`
**Request:**
```json
{
  "email": "user@heritage.et",
  "password": "password123"
}
```
**Response:** `{"accessToken": "...", "refreshToken": "...", "user": {...}}`

## Landmarks
- `GET /landmarks`: Lists all active landmarks. Auth: Any
- `GET /admin/landmarks/{id}`: View single landmark details.

### Admin Operations
- `POST /admin/landmarks`: Create new landmark.
- `PUT /admin/landmarks/{id}`: Update info.
- `DELETE /admin/landmarks/{id}`: Soft delete.

## Visits & Scans
- `POST /visits/scan`: Trigger a scan event based on QR decode.
**Request:**
```json
{
  "qrPayload": "heritage-trail://visit/{uuid}?secret={secret}",
  "latitude": 9.03,
  "longitude": 38.74
}
```
**Response:** `{"success": true, "pointsAwarded": 10}`

## Bulk Operations (Admin)
- `POST /admin/landmarks/bulk-qr/zip`: Downloads ZIP of all PNG identifiers.
- `POST /admin/landmarks/bulk-qr/pdf`: Downloads print-ready A4 PDF grids.
- `GET /admin/landmarks/marker-template`: Raw HTML printable token template.
