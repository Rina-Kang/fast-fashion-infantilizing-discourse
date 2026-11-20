-- =====================================================
-- 快时尚女装社媒评论分析 · SQLite 建库脚本
-- Tech Intern 作品集项目
-- =====================================================

PRAGMA foreign_keys = ON;

-- 1) 社媒评论主表（主分析对象，7912 条已脱敏评论）
CREATE TABLE IF NOT EXISTS social_comments (
    comment_id      TEXT PRIMARY KEY,
    note_id         TEXT,
    platform        TEXT NOT NULL,
    author_anon     TEXT,
    like_count      INTEGER,
    comment_time    TEXT,
    content         TEXT NOT NULL,
    source_file     TEXT,
    track           TEXT,
    store           TEXT,
    spectrum_pole   TEXT
);

-- 2) 电商买家评论表（真实采集 98 条）
CREATE TABLE IF NOT EXISTS ecommerce_reviews (
    review_id       TEXT PRIMARY KEY,
    store_type      TEXT,
    store_name      TEXT,
    product_no      INTEGER,
    product_link    TEXT,
    price           REAL,
    total_sales     INTEGER,
    pos_rate        REAL,
    neg_total       INTEGER,
    collect_date    TEXT,
    source          TEXT,
    content         TEXT,
    feel_word       TEXT,
    feel_type       TEXT,
    appear_word     TEXT,
    subjectivity    TEXT
);

-- 3) 店铺维度表（6 家店）
CREATE TABLE IF NOT EXISTS stores (
    store_name      TEXT PRIMARY KEY,
    store_type      TEXT,
    platform        TEXT
);

CREATE INDEX IF NOT EXISTS idx_comments_platform ON social_comments(platform);
CREATE INDEX IF NOT EXISTS idx_comments_track    ON social_comments(track);
