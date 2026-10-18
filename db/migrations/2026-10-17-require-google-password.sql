-- Run before deploying the WAR. Existing accounts keep their current password flow.
ALTER TABLE "user"
    ADD COLUMN IF NOT EXISTS requires_password_change BOOLEAN NOT NULL DEFAULT FALSE;
