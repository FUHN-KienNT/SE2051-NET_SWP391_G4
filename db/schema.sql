-- =====================================================================
-- LEARNHUB DATABASE SCHEMA
-- PostgreSQL DDL Script
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. EXTENSIONS
-- ---------------------------------------------------------------------
-- gen_random_uuid() la ham built-in tu PostgreSQL 13+.
-- Neu chay tren ban PostgreSQL cu hon, bo comment dong duoi de dung pgcrypto:
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------
-- 0.1 CLEANUP (chay lai script nhieu lan khi dang thiet ke/test)
-- Neu day la lan chay DAU TIEN tren mot database sach, co the bo qua
-- phan nay (se khong bao loi vi dung IF EXISTS).
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS notification CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS quiz_answer CASCADE;
DROP TABLE IF EXISTS quiz_submission CASCADE;
DROP TABLE IF EXISTS quiz_question CASCADE;
DROP TABLE IF EXISTS question_option CASCADE;
DROP TABLE IF EXISTS question CASCADE;
DROP TABLE IF EXISTS quiz CASCADE;
DROP TABLE IF EXISTS learning_process CASCADE;
DROP TABLE IF EXISTS lesson CASCADE;
DROP TABLE IF EXISTS module CASCADE;
DROP TABLE IF EXISTS registration CASCADE;
DROP TABLE IF EXISTS course CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;
DROP TABLE IF EXISTS setting CASCADE;

DROP TYPE IF EXISTS notification_status CASCADE;
DROP TYPE IF EXISTS question_type CASCADE;
DROP TYPE IF EXISTS learning_status CASCADE;
DROP TYPE IF EXISTS payment_status CASCADE;
DROP TYPE IF EXISTS registration_status CASCADE;
DROP TYPE IF EXISTS course_status CASCADE;
DROP TYPE IF EXISTS user_status CASCADE;


-- ---------------------------------------------------------------------
-- 1. ENUM TYPES
-- Dung cho cac trang thai gan chat voi logic nghiep vu (workflow/state machine)
-- ---------------------------------------------------------------------
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'banned');

CREATE TYPE course_status AS ENUM ('draft', 'published', 'archived');

CREATE TYPE registration_status AS ENUM ('enrolled', 'completed', 'cancelled');

CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');

CREATE TYPE learning_status AS ENUM ('not_started', 'in_progress', 'completed');

CREATE TYPE question_type AS ENUM ('text', 'single_choice', 'multiple_choice');

CREATE TYPE notification_status AS ENUM ('unread', 'read', 'sent', 'failed');


-- ---------------------------------------------------------------------
-- 2. SETTING (bang danh muc dung chung - generic lookup table)
-- Dung cho: role, category, payment_method, notification_type
-- ---------------------------------------------------------------------
CREATE TABLE setting (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type        VARCHAR(50)  NOT NULL,
    code        VARCHAR(100) NOT NULL,
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    status      BOOLEAN      NOT NULL DEFAULT TRUE,
    sort_order  INTEGER      NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT uq_setting_type_code UNIQUE (type, code)
);

CREATE INDEX idx_setting_type ON setting (type);


-- ---------------------------------------------------------------------
-- 3. USER
-- ---------------------------------------------------------------------
CREATE TABLE "user" (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username   VARCHAR(255) NOT NULL,
    email      VARCHAR(255) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    role_id    UUID NOT NULL REFERENCES setting (id),
    status     user_status NOT NULL DEFAULT 'active',
    google_user_id VARCHAR(255),
    github_user_id VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_google_user_id UNIQUE (google_user_id),
    CONSTRAINT uq_user_github_user_id UNIQUE (github_user_id)
);

CREATE INDEX idx_user_role_id ON "user" (role_id);


-- ---------------------------------------------------------------------
-- 4. COURSE
-- ---------------------------------------------------------------------
CREATE TABLE course (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title         VARCHAR(255) NOT NULL,
    description   TEXT,
    price         NUMERIC(12, 2) NOT NULL DEFAULT 0,
    thumbnail_url TEXT,
    status        course_status NOT NULL DEFAULT 'draft',
    category_id   UUID REFERENCES setting (id),
    created_by    UUID NOT NULL REFERENCES "user" (id),  -- Manager tao khoa hoc
    expert_id     UUID REFERENCES "user" (id),           -- Expert duoc assign
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_course_category_id ON course (category_id);
CREATE INDEX idx_course_created_by ON course (created_by);
CREATE INDEX idx_course_expert_id ON course (expert_id);


-- ---------------------------------------------------------------------
-- 5. REGISTRATION
-- ---------------------------------------------------------------------
CREATE TABLE registration (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID NOT NULL REFERENCES "user" (id),
    course_id         UUID NOT NULL REFERENCES course (id),
    enrolled_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    status            registration_status NOT NULL DEFAULT 'enrolled',
    progress_percent  SMALLINT NOT NULL DEFAULT 0
        CHECK (progress_percent BETWEEN 0 AND 100),
    amount            NUMERIC(12, 2) NOT NULL DEFAULT 0,
    payment_method_id UUID REFERENCES setting (id),
    transaction_id    VARCHAR(255),
    payment_status    payment_status NOT NULL DEFAULT 'pending',
    paid_at           TIMESTAMPTZ,
    CONSTRAINT uq_registration_user_course UNIQUE (user_id, course_id)
);

CREATE INDEX idx_registration_user_id ON registration (user_id);
CREATE INDEX idx_registration_course_id ON registration (course_id);
CREATE INDEX idx_registration_payment_method_id ON registration (payment_method_id);


-- ---------------------------------------------------------------------
-- 6. MODULE
-- ---------------------------------------------------------------------
CREATE TABLE module (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id   UUID NOT NULL REFERENCES course (id) ON DELETE CASCADE,
    title       VARCHAR(255) NOT NULL,
    content     TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_module_course_id ON module (course_id);


-- ---------------------------------------------------------------------
-- 7. LESSON
-- ---------------------------------------------------------------------
CREATE TABLE lesson (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id   UUID NOT NULL REFERENCES module (id) ON DELETE CASCADE,
    title       VARCHAR(255) NOT NULL,
    content     TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_lesson_module_id ON lesson (module_id);


-- ---------------------------------------------------------------------
-- 8. LEARNING_PROCESS
-- Theo doi tien do hoc cua 1 registration tren tung lesson
-- ---------------------------------------------------------------------
CREATE TABLE learning_process (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    registration_id  UUID NOT NULL REFERENCES registration (id) ON DELETE CASCADE,
    lesson_id        UUID NOT NULL REFERENCES lesson (id),
    status           learning_status NOT NULL DEFAULT 'not_started',
    completed_at     TIMESTAMPTZ,
    CONSTRAINT uq_learning_process_reg_lesson UNIQUE (registration_id, lesson_id)
);

CREATE INDEX idx_learning_process_registration_id ON learning_process (registration_id);
CREATE INDEX idx_learning_process_lesson_id ON learning_process (lesson_id);


-- ---------------------------------------------------------------------
-- 9. QUIZ
-- ---------------------------------------------------------------------
CREATE TABLE quiz (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id  UUID NOT NULL REFERENCES module (id) ON DELETE CASCADE,
    title      VARCHAR(255) NOT NULL,
    time_limit INTEGER,  -- don vi: phut
    pass_score NUMERIC(5, 2) NOT NULL DEFAULT 5.0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_quiz_module_id ON quiz (module_id);


-- ---------------------------------------------------------------------
-- 10. QUESTION
-- ---------------------------------------------------------------------
CREATE TABLE question (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content    TEXT NOT NULL,
    type       question_type NOT NULL DEFAULT 'single_choice',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ---------------------------------------------------------------------
-- 11. QUESTION_OPTION
-- ---------------------------------------------------------------------
CREATE TABLE question_option (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL REFERENCES question (id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    is_correct  BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_question_option_question_id ON question_option (question_id);


-- ---------------------------------------------------------------------
-- 12. QUIZ_QUESTION (bang trung gian Quiz <-> Question, N-N)
-- ---------------------------------------------------------------------
CREATE TABLE quiz_question (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id     UUID NOT NULL REFERENCES quiz (id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES question (id),
    order_index INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT uq_quiz_question UNIQUE (quiz_id, question_id)
);

CREATE INDEX idx_quiz_question_quiz_id ON quiz_question (quiz_id);
CREATE INDEX idx_quiz_question_question_id ON quiz_question (question_id);


-- ---------------------------------------------------------------------
-- 13. QUIZ_SUBMISSION
-- ---------------------------------------------------------------------
CREATE TABLE quiz_submission (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id      UUID NOT NULL REFERENCES quiz (id),
    user_id      UUID NOT NULL REFERENCES "user" (id),
    score        NUMERIC(5, 2),
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    pass_status  BOOLEAN
);

CREATE INDEX idx_quiz_submission_quiz_id ON quiz_submission (quiz_id);
CREATE INDEX idx_quiz_submission_user_id ON quiz_submission (user_id);


-- ---------------------------------------------------------------------
-- 14. QUIZ_ANSWER
-- Luu dap an nguoi dung chon cho tung cau hoi trong 1 lan submit
-- ---------------------------------------------------------------------
CREATE TABLE quiz_answer (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_submission_id  UUID NOT NULL REFERENCES quiz_submission (id) ON DELETE CASCADE,
    quiz_question_id    UUID NOT NULL REFERENCES quiz_question (id),
    question_option_id  UUID NOT NULL REFERENCES question_option (id)
);

CREATE INDEX idx_quiz_answer_quiz_submission_id ON quiz_answer (quiz_submission_id);
CREATE INDEX idx_quiz_answer_quiz_question_id ON quiz_answer (quiz_question_id);
CREATE INDEX idx_quiz_answer_question_option_id ON quiz_answer (question_option_id);


-- ---------------------------------------------------------------------
-- 15. NOTIFICATION
-- ---------------------------------------------------------------------
CREATE TABLE notification (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES "user" (id),
    type_id    UUID REFERENCES setting (id),
    content    TEXT NOT NULL,
    status     notification_status NOT NULL DEFAULT 'unread',
    sent_at    TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notification_user_id ON notification (user_id);
CREATE INDEX idx_notification_type_id ON notification (type_id);


-- ---------------------------------------------------------------------
-- 16. AUDIT_LOG
-- Ghi lai cac su kien he thong quan trong phuc vu Admin Dashboard
-- ---------------------------------------------------------------------
CREATE TABLE audit_log (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor       VARCHAR(255),          -- email hoac username cua nguoi thuc hien
    action_type VARCHAR(100) NOT NULL, -- vi du: LOGIN_SUCCESS, LOGIN_FAILED, ROLE_UPDATE, JOB_EXEC
    description TEXT,
    status      VARCHAR(50)  NOT NULL DEFAULT 'SUCCESS', -- SUCCESS | FAILED | WARNING
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_log_created_at ON audit_log (created_at DESC);
CREATE INDEX idx_audit_log_actor ON audit_log (actor);
