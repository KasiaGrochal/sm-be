CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS connected_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    platform VARCHAR(20) CHECK (platform IN ('instagram', 'facebook')),
    account_id VARCHAR(100),
    account_name VARCHAR(100),
    token TEXT,
    token_expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    style VARCHAR(50),
    industry VARCHAR(50),
    target_group TEXT,
    frequency_hint VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    account_id UUID REFERENCES connected_accounts(id) ON DELETE CASCADE,
    text TEXT,
    hashtags TEXT,
    image_url TEXT,
    ai_generated BOOLEAN DEFAULT false,
    source VARCHAR(20),
    media_type VARCHAR(20),
    accepted BOOLEAN DEFAULT false,
    accepted_at TIMESTAMP,
    status VARCHAR(30),
    priority INT,
    scheduled_for TIMESTAMP,
    published_at TIMESTAMP,
    external_post_id VARCHAR(100),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS insights_daily (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES connected_accounts(id) ON DELETE CASCADE,
    date DATE,
    followers INT,
    reach INT,
    impressions INT,
    likes_total INT,
    comments_total INT,
    posts_count INT
);

CREATE TABLE IF NOT EXISTS media_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES connected_accounts(id) ON DELETE CASCADE,
    post_id VARCHAR(100),
    timestamp TIMESTAMP,
    reach INT,
    likes INT,
    comments INT,
    saves INT,
    media_type VARCHAR(50),
    caption TEXT
);

CREATE TABLE IF NOT EXISTS insights_monthly_summary (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES connected_accounts(id) ON DELETE CASCADE,
    month VARCHAR(7),
    followers_start INT,
    followers_end INT,
    reach_total INT,
    impressions_total INT,
    top_posts JSON,
    source VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS subscription_plans (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE,
    name VARCHAR(100),
    price_pln DECIMAL(10,2),
    max_accounts INT,
    ai_enabled BOOLEAN DEFAULT false,
    report_enabled BOOLEAN DEFAULT false,
    priority_support BOOLEAN DEFAULT false,
    visible_in_ui BOOLEAN DEFAULT true,
    position INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    plan_code VARCHAR(50) REFERENCES subscription_plans(code),
    status VARCHAR(20),
    started_at TIMESTAMP,
    expires_at TIMESTAMP,
    last_payment_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS demo_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255),
    image_url TEXT,
    caption TEXT,
    suggested_day INT,
    suggested_hour TIME,
    category VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS payment_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    plan_id INT REFERENCES subscription_plans(id),
    amount DECIMAL(10,2),
    status VARCHAR(20),
    gateway VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_response TEXT
);

CREATE TABLE IF NOT EXISTS agency_clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agency_id UUID REFERENCES users(id),
    client_id UUID REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS system_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
