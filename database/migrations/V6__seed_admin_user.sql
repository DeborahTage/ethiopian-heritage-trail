-- V6__seed_admin_user.sql
-- Insert default admin user for heritage trail dashboard

INSERT INTO users (email, password_hash, display_name, role, is_active)
VALUES (
    'admin@heritage.et',
    '$2b$12$Ch.VaafC5BVBjtsXn6RzCOHUi9nXgPxQH06XrbjTtsNU2bDgCyPbu',
    'Heritage Admin',
    'ADMIN',
    TRUE
)
ON CONFLICT DO NOTHING;
