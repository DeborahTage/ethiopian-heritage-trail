-- V5__landmark_content.sql
-- Rich landmark content for scan and admin CMS experiences

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE landmark_contents (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    landmark_id         UUID NOT NULL UNIQUE REFERENCES landmarks(id) ON DELETE CASCADE,
    short_story_en      TEXT,
    short_story_am      TEXT,
    full_history_en     TEXT,
    full_history_am     TEXT,
    fun_facts           JSONB DEFAULT '[]'::jsonb,
    hero_image_url      VARCHAR(500),
    gallery_urls        JSONB DEFAULT '[]'::jsonb,
    video_url           VARCHAR(500),
    video_duration      INTEGER,
    video_thumbnail_url VARCHAR(500),
    audio_guide_url     VARCHAR(500),
    audio_duration      INTEGER,
    badge_name          VARCHAR(100),
    badge_icon_url      VARCHAR(500),
    badge_points        INTEGER DEFAULT 0,
    badge_rarity        VARCHAR(20) DEFAULT 'common',
    opening_hours       VARCHAR(50),
    entry_fee           VARCHAR(50),
    best_time           VARCHAR(50),
    contact_phone       VARCHAR(20),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
