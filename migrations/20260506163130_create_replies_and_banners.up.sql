ALTER TABLE cards
ADD COLUMN status TEXT NOT NULL DEFAULT 'active';

ALTER TABLE cards
ADD CONSTRAINT check_cards_status
    CHECK (status IN (
            'active',
            'in-progress',
            'completed',
            'closed'
        ));

ALTER TABLE users
ADD CONSTRAINT check_users_status
    CHECK (status IN (
            'notFound',
            'notRegistered',
            'user',
            'admin',
            'deleted'
        ));

CREATE TABLE replies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL,
    card_id UUID NOT NULL,

    status TEXT NOT NULL DEFAULT 'pending',

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT unique_author_card
        UNIQUE (author_id, card_id),

    FOREIGN KEY (author_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    FOREIGN KEY (card_id)
        REFERENCES cards(id)
        ON DELETE CASCADE,

    CONSTRAINT check_replies_status
        CHECK (status IN (
            'pending',
            'accepted',
            'rejected',
            'completed',
            'failed'
        ))
);

CREATE INDEX idx_replies_author_id ON replies(author_id);
CREATE INDEX idx_replies_card_id ON replies(card_id);

CREATE TABLE banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company TEXT,

    image_url TEXT NOT NULL,
    link TEXT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_banners_created_at ON banners(created_at);