CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    card_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    merchant_id UUID NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    FOREIGN KEY (card_id)
        REFERENCES cards(id)
        ON DELETE CASCADE,

    FOREIGN KEY (customer_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    FOREIGN KEY (merchant_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT unique_card_customer_merchant
        UNIQUE (card_id, customer_id, merchant_id)
);

CREATE INDEX idx_chats_card_id ON chats(card_id);
CREATE INDEX idx_chats_customer_id ON chats(customer_id);
CREATE INDEX idx_chats_merchant_id ON chats(merchant_id);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_id UUID NOT NULL,
    author_id UUID NOT NULL,

    text TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    FOREIGN KEY (chat_id)
        REFERENCES chats(id)
        ON DELETE CASCADE,

    FOREIGN KEY (author_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_author_id ON messages(author_id);