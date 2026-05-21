-- V3__indexes.sql
-- Spatial, composite, and unique indexes

-- Unique constraints
ALTER TABLE users ADD CONSTRAINT uq_users_email UNIQUE (email);
ALTER TABLE user_rewards ADD CONSTRAINT uq_user_rewards UNIQUE (user_id, reward_id);

-- GIST spatial index on landmarks.location
CREATE INDEX idx_landmarks_location ON landmarks USING GIST (location);

-- Standard B-tree indexes
CREATE INDEX idx_visits_user_id          ON visits (user_id);
CREATE INDEX idx_visits_landmark_id      ON visits (landmark_id);
CREATE INDEX idx_visits_created_at       ON visits (created_at);

-- Composite: one visit per user per landmark per day (soft unique — enforced in service)
CREATE INDEX idx_visits_user_landmark_day
    ON visits (user_id, landmark_id, DATE(created_at));

-- Unique: prevent duplicate same-day visits at the same landmark
CREATE UNIQUE INDEX uq_visits_user_landmark_day
    ON visits (user_id, landmark_id, DATE(created_at));

CREATE INDEX idx_scan_analytics_landmark  ON scan_analytics (landmark_id);
CREATE INDEX idx_scan_analytics_date      ON scan_analytics (scan_date);
CREATE INDEX idx_scan_analytics_landmark_date ON scan_analytics (landmark_id, scan_date);

CREATE INDEX idx_user_rewards_user_id    ON user_rewards (user_id);
CREATE INDEX idx_failed_visits_user_id   ON failed_visits (user_id);
CREATE INDEX idx_failed_visits_created   ON failed_visits (created_at);

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_landmarks_updated_at
    BEFORE UPDATE ON landmarks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
