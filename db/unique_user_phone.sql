-- Resolve duplicate digit sequences before applying this migration.
-- Blank phone numbers remain optional and are excluded from the index.
CREATE UNIQUE INDEX IF NOT EXISTS uq_user_phone_digits ON "user"
    (regexp_replace(phone, '[^0-9]', '', 'g'))
    WHERE phone IS NOT NULL AND regexp_replace(phone, '[^0-9]', '', 'g') <> '';
