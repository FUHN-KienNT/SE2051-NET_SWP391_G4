-- Run once against an existing LearnHub database before deploying the new WAR.
BEGIN;

ALTER TABLE "user" ADD COLUMN full_name VARCHAR(255);
UPDATE "user" SET full_name = username;
ALTER TABLE "user" ALTER COLUMN full_name SET NOT NULL;
ALTER TABLE "user" ADD CONSTRAINT user_full_name_not_blank CHECK (full_name ~ '[^[:space:]]');

COMMIT;
