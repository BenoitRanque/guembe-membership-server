ALTER TABLE membership.use
ADD COLUMN date DATE NOT NULL DEFAULT NOW(),
ADD CONSTRAINT limit_one_daily_use UNIQUE (card_id, date);