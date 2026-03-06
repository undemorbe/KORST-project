CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone TEXT UNIQUE NOT NULL,
    name TEXT,
    surname TEXT,
    is_registered BOOLEAN DEFAULT FALSE
);

CREATE TABLE otps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT NOT NULL,
    phone TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY,
    token TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    user_id UUID UNIQUE NOT NULL,
    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);