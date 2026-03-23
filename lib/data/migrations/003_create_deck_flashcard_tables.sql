-- migrations/003_create_deck_flashcard_tables.sql
-- Deck table
CREATE TABLE IF NOT EXISTS decks (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    subject_color_hex TEXT NOT NULL
);

-- FlashCard table
CREATE TABLE IF NOT EXISTS flash_cards (
    id SERIAL PRIMARY KEY,
    front_text TEXT NOT NULL,
    back_text TEXT NOT NULL,
    deck_id INT NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
    next_review_date TIMESTAMP,
    interval DOUBLE PRECISION DEFAULT 1.0,
    repetition INT DEFAULT 0,
    ease_factor DOUBLE PRECISION DEFAULT 2.5
);