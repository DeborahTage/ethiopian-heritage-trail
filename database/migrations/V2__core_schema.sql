-- V2__core_schema.sql
-- Core application tables

-- USERS
CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email         VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name  VARCHAR(100) NOT NULL,
    role          VARCHAR(20)  NOT NULL DEFAULT 'TOURIST' CHECK (role IN ('TOURIST','ADMIN','SUPER_ADMIN')),
    fcm_token     VARCHAR(512),
    total_points  INTEGER NOT NULL DEFAULT 0,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- LANDMARKS
CREATE TABLE landmarks (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name             VARCHAR(200) NOT NULL,
    name_am          VARCHAR(200),
    description      TEXT,
    description_am   TEXT,
    location         GEOMETRY(POINT, 4326) NOT NULL,
    address          VARCHAR(500),
    region           VARCHAR(100),
    category         VARCHAR(50) NOT NULL DEFAULT 'HERITAGE' CHECK (category IN ('HERITAGE','MUSEUM','CHURCH','MOSQUE','PALACE','NATURE','OTHER')),
    media_url        VARCHAR(1024),
    qr_code_url      VARCHAR(1024),
    qr_secret        VARCHAR(256) NOT NULL,
    gps_radius_meters INTEGER NOT NULL DEFAULT 200,
    points_value     INTEGER NOT NULL DEFAULT 10,
    is_active        BOOLEAN NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- REWARDS
CREATE TABLE rewards (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(200) NOT NULL,
    description TEXT,
    badge_url   VARCHAR(1024),
    points_cost INTEGER NOT NULL DEFAULT 0,
    reward_type VARCHAR(50) NOT NULL DEFAULT 'BADGE' CHECK (reward_type IN ('BADGE','DISCOUNT','CERTIFICATE','PHYSICAL')),
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- VISITS
CREATE TABLE visits (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    landmark_id    UUID NOT NULL REFERENCES landmarks(id) ON DELETE CASCADE,
    scan_lat       DOUBLE PRECISION NOT NULL,
    scan_lng       DOUBLE PRECISION NOT NULL,
    distance_meters DOUBLE PRECISION NOT NULL,
    points_earned  INTEGER NOT NULL DEFAULT 0,
    device_id      VARCHAR(256),
    app_version    VARCHAR(20),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- USER_REWARDS
CREATE TABLE user_rewards (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reward_id   UUID NOT NULL REFERENCES rewards(id) ON DELETE CASCADE,
    earned_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    visit_id    UUID REFERENCES visits(id)
);

-- SCAN_ANALYTICS
CREATE TABLE scan_analytics (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    landmark_id  UUID NOT NULL REFERENCES landmarks(id) ON DELETE CASCADE,
    user_id      UUID REFERENCES users(id) ON DELETE SET NULL,
    scan_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    scan_hour    SMALLINT NOT NULL,
    scan_lat     DOUBLE PRECISION,
    scan_lng     DOUBLE PRECISION,
    success      BOOLEAN NOT NULL DEFAULT TRUE,
    failure_reason VARCHAR(100),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- FAILED_VISITS
CREATE TABLE failed_visits (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id        UUID REFERENCES users(id) ON DELETE SET NULL,
    landmark_id    UUID REFERENCES landmarks(id) ON DELETE SET NULL,
    scan_lat       DOUBLE PRECISION,
    scan_lng       DOUBLE PRECISION,
    distance_meters DOUBLE PRECISION,
    failure_reason VARCHAR(100) NOT NULL,
    raw_qr_data    TEXT,
    device_id      VARCHAR(256),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
