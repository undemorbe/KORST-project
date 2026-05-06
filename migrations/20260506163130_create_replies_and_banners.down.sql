DROP INDEX IF EXISTS idx_banners_created_at;
DROP TABLE IF EXISTS banners;

DROP INDEX IF EXISTS idx_replies_card_id;
DROP INDEX IF EXISTS idx_replies_author_id;
DROP TABLE IF EXISTS replies;

ALTER TABLE users
DROP CONSTRAINT IF EXISTS check_users_status;

ALTER TABLE cards
DROP CONSTRAINT IF EXISTS check_cards_status;

ALTER TABLE cards
DROP COLUMN IF EXISTS status;