-- Run after the lesson status migrations and before deploying the updated WAR.
-- Preserve existing values; unsupported historical values abort the transaction.
BEGIN;

DO $$
DECLARE
    unsupported_quiz_statuses TEXT;
    unsupported_lesson_statuses TEXT;
BEGIN
    SELECT string_agg(status, ', ')
      INTO unsupported_quiz_statuses
      FROM (SELECT DISTINCT status FROM public.quiz
            WHERE status NOT IN ('published', 'draft', 'hidden')
            ORDER BY status) invalid_quiz_statuses;
    IF unsupported_quiz_statuses IS NOT NULL THEN
        RAISE EXCEPTION 'Unsupported quiz.status values: %', unsupported_quiz_statuses;
    END IF;

    SELECT string_agg(status, ', ')
      INTO unsupported_lesson_statuses
      FROM (SELECT DISTINCT status FROM public.lesson
            WHERE status NOT IN ('draft', 'published', 'archived', 'decline')
            ORDER BY status) invalid_lesson_statuses;
    IF unsupported_lesson_statuses IS NOT NULL THEN
        RAISE EXCEPTION 'Unsupported lesson.status values: %', unsupported_lesson_statuses;
    END IF;
END $$;

CREATE TYPE public.quiz_status AS ENUM ('published', 'draft', 'hidden');
CREATE TYPE public.lesson_status AS ENUM ('draft', 'published', 'archived', 'decline');

ALTER TABLE public.quiz ALTER COLUMN status DROP DEFAULT;
ALTER TABLE public.lesson ALTER COLUMN status DROP DEFAULT;
ALTER TABLE public.lesson DROP CONSTRAINT IF EXISTS ck_lesson_publication_status;

ALTER TABLE public.quiz
    ALTER COLUMN status TYPE public.quiz_status
    USING status::public.quiz_status;
ALTER TABLE public.lesson
    ALTER COLUMN status TYPE public.lesson_status
    USING status::public.lesson_status;

ALTER TABLE public.quiz ALTER COLUMN status SET DEFAULT 'published'::public.quiz_status;
ALTER TABLE public.lesson ALTER COLUMN status SET DEFAULT 'draft'::public.lesson_status;

COMMIT;
