-- Additive migration: existing lessons remain Content; no data reset or seed required.
BEGIN;
ALTER TABLE lesson ADD COLUMN IF NOT EXISTS lesson_type VARCHAR(20) NOT NULL DEFAULT 'content';
ALTER TABLE lesson ADD COLUMN IF NOT EXISTS video_url TEXT;
ALTER TABLE lesson ADD COLUMN IF NOT EXISTS quiz_id UUID;
CREATE UNIQUE INDEX IF NOT EXISTS uq_quiz_id_module ON quiz (id, module_id);
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_lesson_quiz_module' AND conrelid = 'lesson'::regclass) THEN
        ALTER TABLE lesson ADD CONSTRAINT fk_lesson_quiz_module
            FOREIGN KEY (quiz_id, module_id) REFERENCES quiz (id, module_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_lesson_type_payload' AND conrelid = 'lesson'::regclass) THEN
        ALTER TABLE lesson ADD CONSTRAINT ck_lesson_type_payload CHECK (
            (lesson_type = 'content' AND video_url IS NULL AND quiz_id IS NULL)
            OR (lesson_type = 'video' AND NULLIF(BTRIM(video_url), '') IS NOT NULL AND quiz_id IS NULL)
            OR (lesson_type = 'quiz' AND quiz_id IS NOT NULL AND video_url IS NULL AND COALESCE(content, '') = '')
        );
    END IF;
END $$;
CREATE INDEX IF NOT EXISTS idx_lesson_quiz_id ON lesson (quiz_id) WHERE quiz_id IS NOT NULL;
COMMIT;
