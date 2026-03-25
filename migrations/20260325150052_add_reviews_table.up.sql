CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL,
    related_to_id UUID NOT NULL,

    rating DOUBLE PRECISION NOT NULL,
    comment TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    FOREIGN KEY (author_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    FOREIGN KEY (related_to_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT unique_author_related
        UNIQUE (author_id, related_to_id)
);

CREATE INDEX idx_reviews_author_id ON reviews(author_id);
CREATE INDEX idx_reviews_related_to_id ON reviews(related_to_id);