-- Run after 20261102_lesson_types.sql (filenames sort in this order).
-- Converts existing values without resetting data.
BEGIN;
SET LOCAL lock_timeout = '10s';
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE oid = to_regtype('lesson_type')) THEN
        CREATE TYPE lesson_type AS ENUM ('content', 'video', 'quiz');
    END IF;
    IF (SELECT array_agg(e.enumlabel::text ORDER BY e.enumsortorder)
        FROM pg_enum e WHERE e.enumtypid = 'lesson_type'::regtype)
        IS DISTINCT FROM ARRAY['content', 'video', 'quiz']::text[] THEN
        RAISE EXCEPTION 'lesson_type must contain exactly content, video, quiz';
    END IF;
END $$;
ALTER TABLE lesson DROP CONSTRAINT IF EXISTS ck_lesson_type_payload;
ALTER TABLE lesson ALTER COLUMN lesson_type DROP DEFAULT;
ALTER TABLE lesson ALTER COLUMN lesson_type TYPE lesson_type USING lesson_type::text::lesson_type;
ALTER TABLE lesson ALTER COLUMN lesson_type SET DEFAULT 'content'::lesson_type;
ALTER TABLE lesson ADD CONSTRAINT ck_lesson_type_payload CHECK (
    (lesson_type = 'content' AND video_url IS NULL AND quiz_id IS NULL)
    OR (lesson_type = 'video' AND NULLIF(BTRIM(video_url), '') IS NOT NULL AND quiz_id IS NULL)
    OR (lesson_type = 'quiz' AND quiz_id IS NOT NULL AND video_url IS NULL AND COALESCE(content, '') = '')
);
COMMIT;
