-- ==============================================================================
-- LearnHub Database Schema (PostgreSQL)
-- SWP391 - Software Design Specification (SDS) Compliance
-- ==============================================================================

-- Enable UUID extension if not already available
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Drop existing tables if re-initializing
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
DROP TABLE IF EXISTS notification CASCADE;
DROP TABLE IF EXISTS content_review CASCADE;
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;
DROP TABLE IF EXISTS setting CASCADE;

-- ------------------------------------------------------------------------------
-- 1. SETTING TABLE
-- Category: role, category, payment_method, notification_type
-- ------------------------------------------------------------------------------
CREATE TABLE setting (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50) NOT NULL,
    code VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 2. USER TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE "user" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id UUID NOT NULL REFERENCES setting(id) ON DELETE RESTRICT,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 3. COURSE TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE course (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    thumbnail_url TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'draft',
    category_id UUID REFERENCES setting(id) ON DELETE SET NULL,
    created_by UUID NOT NULL REFERENCES "user"(id) ON DELETE RESTRICT,
    expert_id UUID REFERENCES "user"(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 4. REGISTRATION TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE registration (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES course(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(50) NOT NULL DEFAULT 'enrolled',
    progress_percent INT2 NOT NULL DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
    amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    payment_method_id UUID REFERENCES setting(id) ON DELETE SET NULL,
    transaction_id VARCHAR(255),
    payment_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    paid_at TIMESTAMPTZ
);

-- ------------------------------------------------------------------------------
-- 5. MODULE TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE module (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES course(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 6. LESSON TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE lesson (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES module(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 7. LEARNING PROCESS TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE learning_process (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    registration_id UUID NOT NULL REFERENCES registration(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lesson(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'not_started',
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_reg_lesson UNIQUE (registration_id, lesson_id)
);

-- ------------------------------------------------------------------------------
-- 8. QUIZ TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE quiz (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES module(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    time_limit INT, -- minutes
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 9. QUESTION TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE question (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'single_choice',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 10. QUESTION OPTION TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE question_option (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 11. QUIZ QUESTION TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE quiz_question (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID NOT NULL REFERENCES quiz(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    order_index INT NOT NULL DEFAULT 0,
    CONSTRAINT uk_quiz_question UNIQUE (quiz_id, question_id)
);

-- ------------------------------------------------------------------------------
-- 12. QUIZ SUBMISSION TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE quiz_submission (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID NOT NULL REFERENCES quiz(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    score NUMERIC(5, 2),
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    pass_status BOOLEAN
);

-- ------------------------------------------------------------------------------
-- 13. QUIZ ANSWER TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE quiz_answer (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_submission_id UUID NOT NULL REFERENCES quiz_submission(id) ON DELETE CASCADE,
    quiz_question_id UUID NOT NULL REFERENCES quiz_question(id) ON DELETE CASCADE,
    question_option_id UUID NOT NULL REFERENCES question_option(id) ON DELETE CASCADE
);

-- ------------------------------------------------------------------------------
-- 14. NOTIFICATION TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE notification (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    type_id UUID REFERENCES setting(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'unread',
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 15. PAYMENT LOG & CONTENT REVIEW (SUPPORTING TABLES FOR SEQUENCE FLOWS)
-- ------------------------------------------------------------------------------
CREATE TABLE payment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    registration_id UUID NOT NULL REFERENCES registration(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL DEFAULT 'vnpay',
    transaction_id VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE content_review (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES lesson(id) ON DELETE CASCADE,
    expert_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES "user"(id) ON DELETE SET NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending, approved, rejected
    comments TEXT,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_at TIMESTAMPTZ
);

-- Indexes for high-frequency queries
CREATE INDEX idx_user_email ON "user"(email);
CREATE INDEX idx_user_role ON "user"(role_id);
CREATE INDEX idx_course_status ON course(status);
CREATE INDEX idx_course_category ON course(category_id);
CREATE INDEX idx_registration_user ON registration(user_id);
CREATE INDEX idx_registration_course ON registration(course_id);
CREATE INDEX idx_module_course ON module(course_id);
CREATE INDEX idx_lesson_module ON lesson(module_id);
CREATE INDEX idx_quiz_module ON quiz(module_id);

-- ==============================================================================
-- SEED DATA
-- ==============================================================================

-- 1. Roles & Settings
INSERT INTO setting (id, type, code, name, description, status, sort_order) VALUES
('a0000000-0000-0000-0000-000000000001', 'role', 'ROLE_ADMIN', 'Administrator', 'System Administrator with full access', TRUE, 1),
('a0000000-0000-0000-0000-000000000002', 'role', 'ROLE_MANAGER', 'Course Manager', 'Manages courses, approvals and registrations', TRUE, 2),
('a0000000-0000-0000-0000-000000000003', 'role', 'ROLE_EXPERT', 'Subject Expert', 'Creates content, quizzes and curriculum', TRUE, 3),
('a0000000-0000-0000-0000-000000000004', 'role', 'ROLE_STUDENT', 'Student', 'Enrolls in courses, studies and takes quizzes', TRUE, 4);

-- Categories
INSERT INTO setting (id, type, code, name, description, status, sort_order) VALUES
('b0000000-0000-0000-0000-000000000001', 'category', 'CAT_WEB', 'Web Development', 'Full-stack, Frontend and Backend technologies', TRUE, 1),
('b0000000-0000-0000-0000-000000000002', 'category', 'CAT_MOBILE', 'Mobile Development', 'Flutter, React Native, Android and iOS', TRUE, 2),
('b0000000-0000-0000-0000-000000000003', 'category', 'CAT_AI', 'AI & Data Science', 'Machine Learning, Deep Learning, Python', TRUE, 3);

-- Payment Methods
INSERT INTO setting (id, type, code, name, description, status, sort_order) VALUES
('c0000000-0000-0000-0000-000000000001', 'payment_method', 'PAY_VNPAY', 'VNPay Gateway', 'Online payment via VNPay QR & ATM Cards', TRUE, 1),
('c0000000-0000-0000-0000-000000000002', 'payment_method', 'PAY_BANK', 'Bank Transfer', 'Direct manual bank transfer', TRUE, 2);

-- 2. Users (Password: Admin@123 / Manager@123 / Expert@123 / Student@123 hashed with BCrypt)
-- Hash for password "Password@123": $2a$10$7R9f/C3yQz08iB3i5u6Z6.lK0q0W3P7X5Uq5L7wQ8K3H9J6P2M0.G
-- For safety we also support SHA-256 / BCrypt verification in PasswordHashUtil
INSERT INTO "user" (id, username, email, password, role_id, status) VALUES
('u0000000-0000-0000-0000-000000000001', 'Luu Van Kien (Admin)', 'admin@learnhub.edu.vn', '$2a$10$4n9WvUo9g5Z2Zc7y1rE/xedwDk3Kq3k2yYx7rE9nQ3k2yYx7rE9nQ', 'a0000000-0000-0000-0000-000000000001', 'active'),
('u0000000-0000-0000-0000-000000000002', 'Nguyen Le Duy (Manager)', 'manager@learnhub.edu.vn', '$2a$10$4n9WvUo9g5Z2Zc7y1rE/xedwDk3Kq3k2yYx7rE9nQ3k2yYx7rE9nQ', 'a0000000-0000-0000-0000-000000000002', 'active'),
('u0000000-0000-0000-0000-000000000003', 'Huy Le Duc (Expert)', 'expert@learnhub.edu.vn', '$2a$10$4n9WvUo9g5Z2Zc7y1rE/xedwDk3Kq3k2yYx7rE9nQ3k2yYx7rE9nQ', 'a0000000-0000-0000-0000-000000000003', 'active'),
('u0000000-0000-0000-0000-000000000004', 'Thinh Chu Xuan (Student)', 'student@learnhub.edu.vn', '$2a$10$4n9WvUo9g5Z2Zc7y1rE/xedwDk3Kq3k2yYx7rE9nQ3k2yYx7rE9nQ', 'a0000000-0000-0000-0000-000000000004', 'active');

-- 3. Sample Courses
INSERT INTO course (id, title, description, price, thumbnail_url, status, category_id, created_by, expert_id) VALUES
('d0000000-0000-0000-0000-000000000001', 'Java Web Fullstack Bootcamp', 'Học lập trình Java Web từ cơ bản đến nâng cao với Servlet, JSP, MVC, PostgreSQL và TailwindCSS.', 799000, 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600', 'published', 'b0000000-0000-0000-0000-000000000001', 'u0000000-0000-0000-0000-000000000002', 'u0000000-0000-0000-0000-000000000003'),
('d0000000-0000-0000-0000-000000000002', 'Lập Trình Web Hiện Đại với React & TailwindCSS', 'Xây dựng giao diện web đỉnh cao, component tái sử dụng và responsive hoàn hảo cho mọi thiết bị.', 599000, 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=600', 'published', 'b0000000-0000-0000-0000-000000000001', 'u0000000-0000-0000-0000-000000000002', 'u0000000-0000-0000-0000-000000000003'),
('d0000000-0000-0000-0000-000000000003', 'Khoa Học Dữ Liệu & Machine Learning Cơ Bản', 'Làm chủ Python, Pandas, Scikit-learn và các thuật toán học máy phổ biến.', 899000, 'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=600', 'published', 'b0000000-0000-0000-0000-000000000003', 'u0000000-0000-0000-0000-000000000002', 'u0000000-0000-0000-0000-000000000003');

-- 4. Sample Modules for Course 1
INSERT INTO module (id, course_id, title, content, order_index) VALUES
('m0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 'Chương 1: Kiến trúc Java Web & Servlet', 'Tổng quan về Servlet Lifecycle, Request/Response và mô hình MVC.', 1),
('m0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'Chương 2: Kết nối CSDL với JDBC & PostgreSQL', 'Tối ưu hóa kết nối với HikariCP, Prepared Statement và Transaction.', 2);

-- 5. Sample Lessons for Module 1
INSERT INTO lesson (id, module_id, title, content, order_index) VALUES
('l0000000-0000-0000-0000-000000000001', 'm0000000-0000-0000-0000-000000000001', 'Bài 1: Giới thiệu Kiến Trúc MVC trong Java Web', '<p>Kiến trúc MVC (Model-View-Controller) tách biệt 3 thành phần cốt lõi của ứng dụng...</p>', 1),
('l0000000-0000-0000-0000-000000000002', 'm0000000-0000-0000-0000-000000000001', 'Bài 2: Vòng đời HttpServlet & Xử Lý Request', '<p>HttpServlet quản lý qua init(), service(), doGet(), doPost(), và destroy()...</p>', 2);

-- 6. Sample Quiz for Module 1
INSERT INTO quiz (id, module_id, title, time_limit) VALUES
('q0000000-0000-0000-0000-000000000001', 'm0000000-0000-0000-0000-000000000001', 'Bài Trắc Nghiệm: Kiến Trúc Java Servlet', 15);

-- Sample Questions
INSERT INTO question (id, content, type) VALUES
('k0000000-0000-0000-0000-000000000001', 'Phương thức nào trong HttpServlet được gọi đầu tiên khi Servlet được nạp vào bộ nhớ?', 'single_choice'),
('k0000000-0000-0000-0000-000000000002', 'Filter trong Java Servlet thường được sử dụng cho mục đích nào sau đây?', 'single_choice');

-- Options for Question 1
INSERT INTO question_option (id, question_id, option_text, is_correct) VALUES
('o0000000-0000-0000-0000-000000000001', 'k0000000-0000-0000-0000-000000000001', 'init()', TRUE),
('o0000000-0000-0000-0000-000000000002', 'k0000000-0000-0000-0000-000000000001', 'service()', FALSE),
('o0000000-0000-0000-0000-000000000003', 'k0000000-0000-0000-0000-000000000001', 'doGet()', FALSE),
('o0000000-0000-0000-0000-000000000004', 'k0000000-0000-0000-0000-000000000001', 'destroy()', FALSE);

-- Options for Question 2
INSERT INTO question_option (id, question_id, option_text, is_correct) VALUES
('o0000000-0000-0000-0000-000000000005', 'k0000000-0000-0000-0000-000000000002', 'Xác thực (Authentication) và thiết lập mã hóa UTF-8', TRUE),
('o0000000-0000-0000-0000-000000000006', 'k0000000-0000-0000-0000-000000000002', 'Kết nối trực tiếp tới cơ sở dữ liệu để vẽ biểu đồ', FALSE),
('o0000000-0000-0000-0000-000000000007', 'k0000000-0000-0000-0000-000000000002', 'Thay thế toàn bộ các trang JSP', FALSE);

-- Link Questions to Quiz
INSERT INTO quiz_question (id, quiz_id, question_id, order_index) VALUES
('j0000000-0000-0000-0000-000000000001', 'q0000000-0000-0000-0000-000000000001', 'k0000000-0000-0000-0000-000000000001', 1),
('j0000000-0000-0000-0000-000000000002', 'q0000000-0000-0000-0000-000000000001', 'k0000000-0000-0000-0000-000000000002', 2);
