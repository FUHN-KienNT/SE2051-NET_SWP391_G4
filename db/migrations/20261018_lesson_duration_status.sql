-- Add metadata without resetting lessons, enrollments or learning progress.
-- Existing lessons remain published; unknown historical durations remain NULL.
ALTER TABLE lesson ADD COLUMN IF NOT EXISTS duration_minutes INTEGER;
ALTER TABLE lesson ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'published';

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                   WHERE conrelid = 'lesson'::regclass AND conname = 'ck_lesson_duration_minutes') THEN
        ALTER TABLE lesson ADD CONSTRAINT ck_lesson_duration_minutes CHECK (duration_minutes > 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                   WHERE conrelid = 'lesson'::regclass AND conname = 'ck_lesson_publication_status') THEN
        ALTER TABLE lesson ADD CONSTRAINT ck_lesson_publication_status
            CHECK (status IN ('published', 'draft', 'archived'));
    END IF;
END $$;
