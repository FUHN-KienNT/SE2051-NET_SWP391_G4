-- Preserve existing decisions; only future lessons default to draft.
ALTER TABLE lesson ALTER COLUMN status SET DEFAULT 'draft';
ALTER TABLE lesson DROP CONSTRAINT IF EXISTS ck_lesson_publication_status;
ALTER TABLE lesson ADD CONSTRAINT ck_lesson_publication_status
    CHECK (status IN ('published', 'draft', 'archived', 'decline'));
