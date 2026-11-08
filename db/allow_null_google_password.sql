-- Run before deploying the Google password-setup change.
-- Existing passwords and pending accounts are preserved.
ALTER TABLE "user" ALTER COLUMN password DROP NOT NULL;
