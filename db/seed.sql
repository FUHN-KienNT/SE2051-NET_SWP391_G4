-- =====================================================================
-- LEARNHUB DATABASE SEED SCRIPT
-- ~55 users | 30 courses | 130+ registrations | Rich dashboard data
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. SEED SETTING (Role, Category, Payment Method, Notification Type)
-- ---------------------------------------------------------------------
INSERT INTO setting (id, type, code, name, description, status, sort_order) VALUES
    -- Roles
    ('a0000000-0000-0000-0000-000000000001', 'role', 'ROLE_ADMIN',   'Administrator',        'Toàn quyền quản trị hệ thống, người dùng và phân quyền', TRUE, 1),
    ('a0000000-0000-0000-0000-000000000002', 'role', 'ROLE_MANAGER', 'Manager',              'Quản lý danh mục, khóa học, phê duyệt nội dung và doanh thu', TRUE, 2),
    ('a0000000-0000-0000-0000-000000000003', 'role', 'ROLE_EXPERT',  'Expert / Instructor',  'Chuyên gia biên soạn bài giảng, ra đề thi và giải đáp thắc mắc', TRUE, 3),
    ('a0000000-0000-0000-0000-000000000004', 'role', 'ROLE_STUDENT', 'Student',              'Học viên tham gia các khóa học và làm bài tập đánh giá', TRUE, 4),

    -- Categories (Mở rộng 10 danh mục đa dạng lĩnh vực công nghệ)
    ('b0000000-0000-0000-0000-000000000001', 'category', 'web_dev',         'Phát triển Web Fullstack',       'HTML, CSS, JavaScript, React, Node.js, Java Web, Spring Boot, Next.js', TRUE, 1),
    ('b0000000-0000-0000-0000-000000000002', 'category', 'database',        'Cơ sở dữ liệu & Tối ưu hóa',     'PostgreSQL, MySQL, Redis, CSDL nâng cao, Indexing và Query Tuning', TRUE, 2),
    ('b0000000-0000-0000-0000-000000000003', 'category', 'programming',     'Lập trình Cốt lõi & Thuật toán', 'OOP, Cấu trúc dữ liệu & Giải thuật, Java Core, Python, C#', TRUE, 3),
    ('b0000000-0000-0000-0000-000000000004', 'category', 'ai_data',         'Trí tuệ nhân tạo & Data Science','Machine Learning, Deep Learning, Phân tích dữ liệu, Python AI, NLP', TRUE, 4),
    ('b0000000-0000-0000-0000-000000000005', 'category', 'devops',          'DevOps & CI/CD Pipeline',        'Docker, Kubernetes, GitHub Actions, Terraform, Linux System', TRUE, 5),
    ('b0000000-0000-0000-0000-000000000006', 'category', 'mobile',          'Lập trình Mobile App',           'Flutter, React Native, iOS Swift, SwiftUI và Android Kotlin', TRUE, 6),
    ('b0000000-0000-0000-0000-000000000007', 'category', 'cyber_security',  'An toàn Thông tin & An ninh mạng','Bảo mật web, Kiểm thử xâm nhập Web Pentest, OWASP Top 10, Network Security', TRUE, 7),
    ('b0000000-0000-0000-0000-000000000008', 'category', 'ui_ux',           'Thiết kế UI/UX & Đồ họa số',     'Figma, Wireframing, Prototype, Design Systems, UX Research cho Dev', TRUE, 8),
    ('b0000000-0000-0000-0000-000000000009', 'category', 'cloud_computing', 'Điện toán Đám mây (Cloud)',     'AWS Certified, Cloud Architecture, Serverless, Microservices Cloud', TRUE, 9),
    ('b0000000-0000-0000-0000-000000000010', 'category', 'game_dev',        'Phát triển & Lập trình Game',    'Unity 2D/3D, Unreal Engine, Game Physics, Animation, C# Scripting', TRUE, 10),

    -- Payment Methods
    ('b0000000-0000-0000-0000-000000000011', 'payment_method', 'vnpay',       'Cổng thanh toán VNPay',          'Thanh toán qua thẻ ATM, QR Code VNPay sandbox', TRUE, 1),
    ('b0000000-0000-0000-0000-000000000013', 'payment_method', 'sepay',       'Cổng thanh toán SePay (VietQR)', 'Chuyển khoản trực tiếp qua mã QR VietQR tự động qua SePay', TRUE, 2),
    ('b0000000-0000-0000-0000-000000000012', 'payment_method', 'momo',        'Ví điện tử MoMo',                'Thanh toán quét mã MoMo Pay', FALSE, 3),
    ('b0000000-0000-0000-0000-000000000014', 'payment_method', 'credit_card', 'Thẻ Quốc tế (Visa/Master)',     'Thanh toán trực tuyến bằng thẻ tín dụng quốc tế', FALSE, 4),

    -- Notification Types
    ('b0000000-0000-0000-0000-000000000021', 'notification_type', 'system',  'Hệ thống',  'Thông báo nâng cấp hệ thống, điều khoản và an toàn bảo mật', TRUE, 1),
    ('b0000000-0000-0000-0000-000000000022', 'notification_type', 'course',  'Khóa học',  'Thông báo đăng ký khóa học, bài học mới và nhắc nhở học tập', TRUE, 2),
    ('b0000000-0000-0000-0000-000000000023', 'notification_type', 'payment', 'Thanh toán','Xác nhận thanh toán học phí thành công và biên lai thu tiền', TRUE, 3),
    ('b0000000-0000-0000-0000-000000000024', 'notification_type', 'quiz',    'Bài kiểm tra','Kết quả chấm điểm bài thi trắc nghiệm và đánh giá năng lực', TRUE, 4)
ON CONFLICT (type, code) DO UPDATE SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    status = EXCLUDED.status,
    sort_order = EXCLUDED.sort_order;


-- ---------------------------------------------------------------------
-- 2. SEED USER (~55 accounts)
-- Mật khẩu hash bằng BCrypt:
-- admin->admin, manager->manager, expert->expert, student->student
-- New users all use password: password123
-- ---------------------------------------------------------------------
INSERT INTO setting (id, type, code, name, description, status, sort_order) VALUES
    ('a0000000-0000-0000-0000-000000000001', 'role', 'ROLE_ADMIN',   'Administrator',        'Toàn quyền quản trị hệ thống', TRUE, 1),
    ('a0000000-0000-0000-0000-000000000002', 'role', 'ROLE_MANAGER', 'Manager',              'Quản lý danh mục, khóa học', TRUE, 2),
    ('a0000000-0000-0000-0000-000000000003', 'role', 'ROLE_EXPERT',  'Expert / Instructor',  'Chuyên gia biên soạn bài giảng', TRUE, 3),
    ('a0000000-0000-0000-0000-000000000004', 'role', 'ROLE_STUDENT', 'Student',              'Học viên tham gia khóa học', TRUE, 4)
ON CONFLICT (type, code) DO NOTHING;

INSERT INTO "user" (id, username, full_name, email, password, role_id, status, created_at) VALUES
    -- 1 Admin
    ('c0000000-0000-0000-0000-000000000001', 'admin', 'Phạm Quốc Bảo', 'admin@learnhub.com',
     '$2a$10$Sdt.YtiEjO5Kr5V.oEIs/uyme2cDi65wo/sHUL5J546JTjZpnWVRC',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_ADMIN' LIMIT 1), 'active', NOW() - INTERVAL '180 days'),

    -- 2 Managers
    ('c0000000-0000-0000-0000-000000000002', 'manager', 'Nguyễn Minh Tuấn', 'manager@learnhub.com',
     '$2a$10$AQYzTX/07vmJ11M8kVevCeG09zAFD3Y6EVCkdIrIcsnHuJ9O0fylK',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_MANAGER' LIMIT 1), 'active', NOW() - INTERVAL '180 days'),
    ('c0000000-0000-0000-0000-000000000003', 'manager2', 'Trần Thị Hương', 'manager2@learnhub.com',
     '$2a$10$WkWgNDWJ/YkDYCpcHV7lbuVcuMCEeH.CL6fe0RVPyZnt1bsTRJZJ.',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_MANAGER' LIMIT 1), 'active', NOW() - INTERVAL '170 days'),

    -- 6 Experts
    ('c0000000-0000-0000-0000-000000000004', 'expert', 'Lê Văn Kiên', 'expert@learnhub.com',
     '$2a$10$Amt4fLTJ2n2n/h.GEXf3lu9pro6uozD8si3FknTwDiBxJ0Q6lmGfK',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_EXPERT' LIMIT 1), 'active', NOW() - INTERVAL '175 days'),
    ('c0000000-0000-0000-0000-000000000005', 'expert2', 'Phạm Thanh Hà', 'expert2@learnhub.com',
     '$2a$10$GahzmDxReLJIg0dSmHc0ius8inJJW6Yx4tM0uX0vjOiVPNA3/ClxG',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_EXPERT' LIMIT 1), 'active', NOW() - INTERVAL '170 days'),
    ('c0000000-0000-0000-0000-000000000006', 'expert3', 'Vũ Đức Mạnh', 'expert3@learnhub.com',
     '$2a$10$3zIF/X.cI5PGiT/RxG8XveEmTZw9OCTwri0rnUkXuUaT9vuLWaCTO',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_EXPERT' LIMIT 1), 'active', NOW() - INTERVAL '165 days'),
    ('c0000000-0000-0000-0000-000000000007', 'expert4', 'Đặng Quang Huy', 'expert4@learnhub.com',
     '$2a$10$ll2khekvXIiqgp4NsaFQRObxp3/LoHO99rkhF6hVpxRxuvezJPVC.',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_EXPERT' LIMIT 1), 'active', NOW() - INTERVAL '160 days'),
    ('c0000000-0000-0000-0000-000000000060', 'expert5', 'David Anderson', 'david.anderson@learnhub.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_EXPERT' LIMIT 1), 'active', NOW() - INTERVAL '140 days'),
    ('c0000000-0000-0000-0000-000000000061', 'expert6', 'Sarah Kim', 'sarah.kim@learnhub.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_EXPERT' LIMIT 1), 'active', NOW() - INTERVAL '130 days'),

    -- Original 8 Students (updated full_name)
    ('c0000000-0000-0000-0000-000000000008', 'student', 'Nguyễn Văn An', 'student@learnhub.com',
     '$2a$10$ujsHGpMf9v0mE/QQtFLgGuVuhBBGo9CupXp4Dn6tsBdjyFSMncGvO',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '150 days'),
    ('c0000000-0000-0000-0000-000000000009', 'student2', 'Trần Bình Minh', 'student2@learnhub.com',
     '$2a$10$kG6.9HLENo9arUiveoQu.uBED657ES5Cx5jE1Nzscf8B1bT.CbIfK',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '145 days'),
    ('c0000000-0000-0000-0000-000000000010', 'student3', 'Lê Thị Chi', 'student3@learnhub.com',
     '$2a$10$IncS/j/.pNruMXdFxbNhxub/HA.5bg6n9s7VhMjrE/pmxLcz6y3zy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '140 days'),
    ('c0000000-0000-0000-0000-000000000011', 'student4', 'Hoàng Dũng', 'student4@learnhub.com',
     '$2a$10$uvdiL6YTHA1/B1bNSh84uuNgImBgGnExPgFwPV1IyJFAASlB90aBi',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '135 days'),
    ('c0000000-0000-0000-0000-000000000012', 'student5', 'Phạm Thị Linh', 'student5@learnhub.com',
     '$2a$10$Mnx9fQz.gNa2Q/hCCz5zmenXDlYF.if3.7TaWqVOejUNx95rELkxK',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '130 days'),
    ('c0000000-0000-0000-0000-000000000013', 'student6', 'Đỗ Thanh Mai', 'student6@learnhub.com',
     '$2a$10$0edRofpWrPXF85O8WGAeaub8RB9/AxWawKEj71pPHXDjisxqLOZ.W',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '125 days'),
    ('c0000000-0000-0000-0000-000000000014', 'student7', 'Bùi Quang Hào', 'student7@learnhub.com',
     '$2a$10$TR13q4kGjZg1nqOOjTCLB.21DvaEz8YPUa8oi3qI.3SBxzNpUfg2S',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '120 days'),
    ('c0000000-0000-0000-0000-000000000015', 'student8', 'Vũ Ngọc Hân', 'student8@learnhub.com',
     '$2a$10$qIrXEEG4/EdxpCYiOLAkp.GeeA272AZnh5VFgUNZoihL/yCjuDwKG',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '115 days'),

    -- Inactive & Banned
    ('c0000000-0000-0000-0000-000000000016', 'inactive', 'Ngô Văn Tùng', 'inactive@learnhub.com',
     '$2a$10$eu4KnFl9QzuD.jwM6Q58O.l/7fIyFCuieKJCC.69WiUnZEHsm9ZIC',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'inactive', NOW() - INTERVAL '100 days'),
    ('c0000000-0000-0000-0000-000000000017', 'banned', 'Trương Quốc Spam', 'banned@learnhub.com',
     '$2a$10$v1OxBlBlLquJKeBXy7ydROU.3jayw6i9JUYxiiYEbVm.7NtNpI08i',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'banned', NOW() - INTERVAL '90 days'),

    -- ══ NEW STUDENTS (18–55) ══
    ('c0000000-0000-0000-0000-000000000018', 'nguyenhoang', 'Nguyễn Hoàng Nam', 'nguyenhoang@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '148 days'),
    ('c0000000-0000-0000-0000-000000000019', 'tranthib', 'Trần Thị Bích', 'tranthib@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '142 days'),
    ('c0000000-0000-0000-0000-000000000020', 'leducminh', 'Lê Đức Minh', 'leducminh@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '138 days'),
    ('c0000000-0000-0000-0000-000000000021', 'phamthao', 'Phạm Thu Thảo', 'phamthao@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '132 days'),
    ('c0000000-0000-0000-0000-000000000022', 'johnsmith', 'John Smith', 'john.smith@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '128 days'),
    ('c0000000-0000-0000-0000-000000000023', 'emilychen', 'Emily Chen', 'emily.chen@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '122 days'),
    ('c0000000-0000-0000-0000-000000000024', 'vothanhson', 'Võ Thanh Sơn', 'vothanhson@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '118 days'),
    ('c0000000-0000-0000-0000-000000000025', 'danglan', 'Đặng Thùy Lan', 'danglan@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '112 days'),
    ('c0000000-0000-0000-0000-000000000026', 'michaellee', 'Michael Lee', 'michael.lee@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '108 days'),
    ('c0000000-0000-0000-0000-000000000027', 'huynhkhang', 'Huỳnh Gia Khang', 'huynhkhang@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '102 days'),
    ('c0000000-0000-0000-0000-000000000028', 'ngocdiep', 'Trần Ngọc Diệp', 'ngocdiep@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '98 days'),
    ('c0000000-0000-0000-0000-000000000029', 'davidpark', 'David Park', 'david.park@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '92 days'),
    ('c0000000-0000-0000-0000-000000000030', 'buithien', 'Bùi Thiện Nhân', 'buithien@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '88 days'),
    ('c0000000-0000-0000-0000-000000000031', 'jessicawu', 'Jessica Wu', 'jessica.wu@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '82 days'),
    ('c0000000-0000-0000-0000-000000000032', 'lyminh', 'Lý Quốc Minh', 'lyminh@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '78 days'),
    ('c0000000-0000-0000-0000-000000000033', 'alexjohnson', 'Alex Johnson', 'alex.johnson@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '72 days'),
    ('c0000000-0000-0000-0000-000000000034', 'nguyenhoa', 'Nguyễn Thị Hoa', 'nguyenhoa@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '68 days'),
    ('c0000000-0000-0000-0000-000000000035', 'tomwilson', 'Tom Wilson', 'tom.wilson@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '62 days'),
    ('c0000000-0000-0000-0000-000000000036', 'hoanglam', 'Hoàng Lâm', 'hoanglam@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '58 days'),
    ('c0000000-0000-0000-0000-000000000037', 'racheltran', 'Rachel Trần', 'rachel.tran@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '52 days'),
    ('c0000000-0000-0000-0000-000000000038', 'doanthang', 'Đoàn Văn Thắng', 'doanthang@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '48 days'),
    ('c0000000-0000-0000-0000-000000000039', 'lindanguyen', 'Linda Nguyễn', 'linda.nguyen@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '42 days'),
    ('c0000000-0000-0000-0000-000000000040', 'trungkien', 'Nguyễn Trung Kiên', 'trungkien@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '38 days'),
    ('c0000000-0000-0000-0000-000000000041', 'kevinpham', 'Kevin Phạm', 'kevin.pham@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '35 days'),
    ('c0000000-0000-0000-0000-000000000042', 'minhchau', 'Lê Minh Châu', 'minhchau@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '30 days'),
    ('c0000000-0000-0000-0000-000000000043', 'sophiale', 'Sophia Lê', 'sophia.le@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '28 days'),
    ('c0000000-0000-0000-0000-000000000044', 'dinhbao', 'Đinh Gia Bảo', 'dinhbao@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '25 days'),
    ('c0000000-0000-0000-0000-000000000045', 'chrisphan', 'Chris Phan', 'chris.phan@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '20 days'),
    ('c0000000-0000-0000-0000-000000000046', 'nguyetanh', 'Vũ Nguyệt Ánh', 'nguyetanh@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '18 days'),
    ('c0000000-0000-0000-0000-000000000047', 'brianvo', 'Brian Võ', 'brian.vo@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '15 days'),
    ('c0000000-0000-0000-0000-000000000048', 'thanhtruc', 'Nguyễn Thanh Trúc', 'thanhtruc@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '12 days'),
    ('c0000000-0000-0000-0000-000000000049', 'danielho', 'Daniel Hồ', 'daniel.ho@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '10 days'),
    ('c0000000-0000-0000-0000-000000000050', 'quynhnhu', 'Trần Quỳnh Như', 'quynhnhu@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '8 days'),
    ('c0000000-0000-0000-0000-000000000051', 'andrewle', 'Andrew Lê', 'andrew.le@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '5 days'),
    ('c0000000-0000-0000-0000-000000000052', 'haiyen', 'Phạm Hải Yến', 'haiyen@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '3 days'),
    ('c0000000-0000-0000-0000-000000000053', 'jasonbui', 'Jason Bùi', 'jason.bui@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '2 days'),
    ('c0000000-0000-0000-0000-000000000054', 'maitrang', 'Lê Mai Trang', 'maitrang@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '1 days'),
    ('c0000000-0000-0000-0000-000000000055', 'ryandinh', 'Ryan Đinh', 'ryan.dinh@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'active', NOW() - INTERVAL '1 days'),
    -- Extra inactive/banned
    ('c0000000-0000-0000-0000-000000000056', 'inactive2', 'Cao Minh Đạt', 'inactive2@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'inactive', NOW() - INTERVAL '60 days'),
    ('c0000000-0000-0000-0000-000000000057', 'banned2', 'Spammer Test', 'spammer@mailinator.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     (SELECT id FROM setting WHERE type='role' AND code='ROLE_STUDENT' LIMIT 1), 'banned', NOW() - INTERVAL '45 days')
ON CONFLICT (id) DO UPDATE SET
    username  = EXCLUDED.username,
    full_name = EXCLUDED.full_name,
    email     = EXCLUDED.email,
    password  = EXCLUDED.password,
    role_id   = EXCLUDED.role_id,
    status    = EXCLUDED.status;


-- ---------------------------------------------------------------------
-- 3. SEED COURSE (30 khóa học)
-- ---------------------------------------------------------------------
INSERT INTO course (id, title, description, price, thumbnail_url, status, category_id, created_by, expert_id, created_at) VALUES
    ('d0000000-0000-0000-0000-000000000001',
     'Lập trình Java Web chuyên sâu với Jakarta EE, Servlet, JSP & MVC',
     'Khóa học thực chiến toàn diện giúp bạn làm chủ mô hình MVC, Jakarta Servlet 6.0, JSP/JSTL, HikariCP Connection Pool, PostgreSQL, Authentication Filter và tích hợp cổng thanh toán VNPay.',
     699000.00,
     'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000004', NOW() - INTERVAL '170 days'),

    ('d0000000-0000-0000-0000-000000000002',
     'Làm chủ PostgreSQL: Thiết kế CSDL & Tối ưu hóa Truy vấn',
     'Khám phá chuyên sâu kiến trúc PostgreSQL, kỹ thuật đánh Index B-tree/GIN, đọc và phân tích EXPLAIN ANALYZE, tối ưu Transaction, Partitioning và viết Stored Procedures.',
     550000.00,
     'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000006', NOW() - INTERVAL '168 days'),

    ('d0000000-0000-0000-0000-000000000003',
     'Spring Boot 3 & Microservices: Xây dựng REST API chuẩn Doanh nghiệp',
     'Học cách thiết kế hệ sinh thái Microservices bảo mật với Spring Boot 3, Spring Security 6, JWT, Spring Data JPA, Apache Kafka, OpenFeign và Docker containers.',
     890000.00,
     'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000005', NOW() - INTERVAL '165 days'),

    ('d0000000-0000-0000-0000-000000000004',
     'Machine Learning & Phân tích Dữ liệu thực chiến với Python',
     'Từ tiền xử lý dữ liệu với Pandas, NumPy đến huấn luyện các mô hình học máy Scikit-Learn, XGBoost, trực quan hóa dữ liệu và triển khai model ra ứng dụng thực tế.',
     1190000.00,
     'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000006', NOW() - INTERVAL '160 days'),

    ('d0000000-0000-0000-0000-000000000005',
     'DevOps Toàn diện: Docker, Kubernetes, CI/CD Pipeline & AWS',
     'Thực hành đóng gói container ứng dụng, triển khai cluster Kubernetes (K8s), viết pipeline tự động hóa CI/CD với GitHub Actions và giám sát hệ thống với Prometheus & Grafana.',
     990000.00,
     'https://images.unsplash.com/photo-1618401471353-b98afee0b2eb?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000007', NOW() - INTERVAL '158 days'),

    ('d0000000-0000-0000-0000-000000000006',
     'Frontend Hiện đại với React 18, TypeScript & Tailwind CSS',
     'Làm chủ tư duy Component-driven, React Hooks tùy chỉnh, Context API, Redux Toolkit, React Router v6, tối ưu hiệu năng web và xây dựng giao diện chuẩn thẩm mỹ.',
     620000.00,
     'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000004', NOW() - INTERVAL '155 days'),

    ('d0000000-0000-0000-0000-000000000007',
     'Lập trình Ứng dụng Di động Đa nền tảng với Flutter & Dart',
     'Xây dựng các ứng dụng mobile mượt mà 60fps trên cả Android & iOS, áp dụng kiến trúc Clean Architecture, BLoC pattern, tích hợp Firebase và thanh toán In-App Purchase.',
     750000.00,
     'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000005', NOW() - INTERVAL '150 days'),

    ('d0000000-0000-0000-0000-000000000008',
     'Cấu trúc Dữ liệu & Giải thuật cho Phỏng vấn Kỹ sư Phần mềm',
     'Tổng hợp các bài toán thuật toán kinh điển từ LeetCode: Hai con trỏ, Sliding Window, Đồ thị BFS/DFS, Cây nhị phân, Quy hoạch động.',
     450000.00,
     'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000004', NOW() - INTERVAL '148 days'),

    ('d0000000-0000-0000-0000-000000000009',
     'An toàn Thông tin Web & Kiểm thử Xâm nhập (Web Pentest)',
     'Khám phá cơ chế tấn công và phương pháp phòng chống các lỗ hổng OWASP Top 10: SQL Injection, XSS, CSRF, IDOR, SSRF.',
     850000.00,
     'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800&auto=format&fit=crop',
     'draft', 'b0000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000007', NOW() - INTERVAL '145 days'),

    -- ═══ NEW COURSES 10–30 ═══
    ('d0000000-0000-0000-0000-000000000010',
     'Python for Beginners: From Zero to Hero',
     'A comprehensive beginner-friendly course covering Python syntax, data types, control flow, functions, OOP, file I/O, and building real projects.',
     399000.00,
     'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000006', NOW() - INTERVAL '140 days'),

    ('d0000000-0000-0000-0000-000000000011',
     'HTML, CSS & JavaScript: Nền tảng Web cho Người mới bắt đầu',
     'Khóa học dành cho người hoàn toàn mới, xây dựng website đầu tiên từ HTML5, CSS3 Flexbox/Grid và JavaScript ES6+ cơ bản.',
     299000.00,
     'https://images.unsplash.com/photo-1621839673705-6617adf9e890?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000004', NOW() - INTERVAL '135 days'),

    ('d0000000-0000-0000-0000-000000000012',
     'Deep Learning with TensorFlow & Keras',
     'Build neural networks, CNNs, RNNs, and GANs using TensorFlow 2 and Keras. Deploy models with TensorFlow Serving and TF Lite.',
     1490000.00,
     'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000060', NOW() - INTERVAL '130 days'),

    ('d0000000-0000-0000-0000-000000000013',
     'Node.js & Express: Xây dựng Backend API hiện đại',
     'Phát triển RESTful API với Node.js, Express.js, Mongoose/MongoDB, authentication JWT và deploy lên Heroku/Render.',
     599000.00,
     'https://images.unsplash.com/photo-1627398242454-45a1465c2479?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000060', NOW() - INTERVAL '125 days'),

    ('d0000000-0000-0000-0000-000000000014',
     'MySQL Complete: Từ Cơ bản đến Nâng cao',
     'Thiết kế schema, normalization, stored procedures, triggers, views, và performance tuning cho MySQL 8.0.',
     490000.00,
     'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000006', NOW() - INTERVAL '120 days'),

    ('d0000000-0000-0000-0000-000000000015',
     'React Native: Build Cross-Platform Mobile Apps',
     'Create production-ready mobile apps for iOS and Android using React Native, Expo, React Navigation, and native modules.',
     799000.00,
     'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000061', NOW() - INTERVAL '115 days'),

    ('d0000000-0000-0000-0000-000000000016',
     'AWS Cloud Practitioner: Chứng chỉ Đám mây Căn bản',
     'Chuẩn bị cho kỳ thi AWS Cloud Practitioner CLF-C02, bao gồm EC2, S3, RDS, VPC, IAM, CloudWatch và tính toán chi phí.',
     690000.00,
     'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000009', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000007', NOW() - INTERVAL '110 days'),

    ('d0000000-0000-0000-0000-000000000017',
     'Git & GitHub Mastery: Version Control cho Developer',
     'Từ git init đến Advanced Branching Strategies, Rebase, Cherry-pick, Git Hooks, GitHub Actions và quy trình PR review.',
     350000.00,
     'https://images.unsplash.com/photo-1556075798-4825dfaaf498?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000007', NOW() - INTERVAL '105 days'),

    ('d0000000-0000-0000-0000-000000000018',
     'Kotlin for Android Development',
     'Learn Kotlin from scratch and build modern Android apps with Jetpack Compose, MVVM architecture, Coroutines, and Room database.',
     720000.00,
     'https://images.unsplash.com/photo-1607252650355-f7fd0460ccdb?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000061', NOW() - INTERVAL '100 days'),

    ('d0000000-0000-0000-0000-000000000019',
     'Java Core OOP: Lập trình Hướng đối tượng chuyên sâu',
     'Nắm vững 4 tính chất OOP, SOLID principles, Design Patterns (Factory, Strategy, Observer), Exception handling và Java Collections Framework.',
     550000.00,
     'https://images.unsplash.com/photo-1515879218367-8466d910adef?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000004', NOW() - INTERVAL '95 days'),

    ('d0000000-0000-0000-0000-000000000020',
     'Data Analysis with Power BI & Excel',
     'Master data visualization with Power BI Desktop, DAX formulas, Power Query, and advanced Excel analytics for business intelligence.',
     580000.00,
     'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000060', NOW() - INTERVAL '90 days'),

    ('d0000000-0000-0000-0000-000000000021',
     'Next.js 14 & Full-Stack React Applications',
     'Build production-ready full-stack apps with Next.js 14 App Router, Server Components, Server Actions, Prisma ORM, and Vercel deployment.',
     890000.00,
     'https://images.unsplash.com/photo-1537432376149-e84978e29438?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000060', NOW() - INTERVAL '85 days'),

    ('d0000000-0000-0000-0000-000000000022',
     'Linux Administration & Shell Scripting',
     'Quản trị hệ thống Linux (Ubuntu/CentOS), Bash scripting nâng cao, systemd, cron, networking, firewall và log management.',
     520000.00,
     'https://images.unsplash.com/photo-1629654297299-c8506221ca97?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000007', NOW() - INTERVAL '80 days'),

    ('d0000000-0000-0000-0000-000000000023',
     'Thiết kế UI/UX cho Developer: Figma & Design Thinking',
     'Học tư duy thiết kế, wireframing, prototyping với Figma, hệ thống design token, responsive design và user testing.',
     480000.00,
     'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000061', NOW() - INTERVAL '75 days'),

    ('d0000000-0000-0000-0000-000000000024',
     'Swift & SwiftUI: Phát triển ứng dụng iOS chuyên nghiệp',
     'Xây dựng iOS app hiện đại với SwiftUI, Combine, Core Data, CloudKit, StoreKit 2 và App Store Connect submission.',
     880000.00,
     'https://images.unsplash.com/photo-1592478411213-6153e4ebc07d?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000005', NOW() - INTERVAL '70 days'),

    ('d0000000-0000-0000-0000-000000000025',
     'Redis & Caching Strategies for High-Performance Apps',
     'Master Redis data structures, pub/sub, Lua scripting, Redis Cluster, and caching patterns (Cache Aside, Write Through, Write Behind).',
     650000.00,
     'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000006', NOW() - INTERVAL '65 days'),

    ('d0000000-0000-0000-0000-000000000026',
     'Vue.js 3 & Nuxt: Xây dựng SPA & SSR hiệu suất cao',
     'Composition API, Pinia state management, Vue Router 4, Nuxt 3 server-side rendering, và testing với Vitest.',
     620000.00,
     'https://images.unsplash.com/photo-1614741118887-7a4ee193a5fa?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000060', NOW() - INTERVAL '55 days'),

    ('d0000000-0000-0000-0000-000000000027',
     'Natural Language Processing with Python',
     'Text preprocessing, sentiment analysis, NER, transformers, BERT fine-tuning, and building chatbots with LangChain.',
     1290000.00,
     'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800&auto=format&fit=crop',
     'published', 'b0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000060', NOW() - INTERVAL '45 days'),

    ('d0000000-0000-0000-0000-000000000028',
     'Terraform & Infrastructure as Code',
     'Provision cloud infra with Terraform: HCL syntax, modules, state management, AWS/GCP providers, and CI/CD integration.',
     780000.00,
     'https://images.unsplash.com/photo-1667372393119-3d4c48d07fc9?w=800&auto=format&fit=crop',
     'draft', 'b0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000007', NOW() - INTERVAL '35 days'),

    ('d0000000-0000-0000-0000-000000000029',
     'Lập trình Game với Unity & C#',
     'Từ cài đặt Unity đến phát hành game 2D/3D: physics, animation, scripting C#, UI design, audio và monetization.',
     750000.00,
     'https://images.unsplash.com/photo-1556438064-2d7646166914?w=800&auto=format&fit=crop',
     'draft', 'b0000000-0000-0000-0000-000000000010', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000061', NOW() - INTERVAL '25 days'),

    ('d0000000-0000-0000-0000-000000000030',
     'GraphQL & Apollo: API Design thế hệ mới',
     'Schema design, resolvers, mutations, subscriptions, Apollo Server/Client, caching, authentication và pagination.',
     570000.00,
     'https://images.unsplash.com/photo-1555949963-ff9fe0c870eb?w=800&auto=format&fit=crop',
     'archived', 'b0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000004', NOW() - INTERVAL '150 days')
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 4. SEED MODULE (Chương học)
-- ---------------------------------------------------------------------
INSERT INTO module (id, course_id, title, content, order_index) VALUES
    -- Modules cho Course 1 (Java Web)
    ('e0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 'Chương 1: Tổng quan HTTP & Vòng đời Servlet', 'Tìm hiểu giao thức HTTP, Request/Response model và Servlet Lifecycle trong Jakarta EE 10.', 1),
    ('e0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'Chương 2: JSP, JSTL & Mô hình MVC', 'Tách biệt tầng hiển thị với JSP, JSTL Core tags và kiến trúc phân lớp Controller-Service-DAO.', 2),
    ('e0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000001', 'Chương 3: Session, Cookie & Filter Bảo mật', 'Quản lý phiên đăng nhập người dùng, phân quyền Role-based với HttpFilter và mã hóa mật khẩu.', 3),
    -- Modules cho Course 2 (PostgreSQL)
    ('e0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000002', 'Chương 1: Kiến trúc Lưu trữ & DDL/DML Nâng cao', 'Cấu trúc table, page, heap storage, kiểu dữ liệu UUID, JSONB.', 1),
    ('e0000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000002', 'Chương 2: Đánh Chỉ mục Indexing & Tối ưu Execution Plan', 'Chiến lược đánh index B-Tree, GIN, Partial Index và đọc EXPLAIN.', 2),
    -- Modules cho Course 3 (Spring Boot)
    ('e0000000-0000-0000-0000-000000000006', 'd0000000-0000-0000-0000-000000000003', 'Chương 1: Khởi tạo Spring Boot & Kiến trúc REST API', 'IoC, DI và thiết kế RESTful endpoints.', 1),
    ('e0000000-0000-0000-0000-000000000007', 'd0000000-0000-0000-0000-000000000003', 'Chương 2: Spring Data JPA & Quản lý Giao dịch', 'Hibernate/JPA, Repository pattern và Transaction Isolation.', 2),
    -- Modules cho Course 6 (React)
    ('e0000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000006', 'Chương 1: React Core Concepts & Hooks', 'JSX, Virtual DOM, useState, useEffect.', 1),
    ('e0000000-0000-0000-0000-000000000009', 'd0000000-0000-0000-0000-000000000006', 'Chương 2: State Nâng cao & Gọi API REST', 'Context API, useReducer, Axios interceptors.', 2),
    -- Modules cho Course 4 (ML Python)
    ('e0000000-0000-0000-0000-000000000010', 'd0000000-0000-0000-0000-000000000004', 'Chương 1: Python for Data Science Basics', 'NumPy arrays, Pandas DataFrames, data cleaning.', 1),
    ('e0000000-0000-0000-0000-000000000011', 'd0000000-0000-0000-0000-000000000004', 'Chương 2: Supervised Learning Algorithms', 'Linear Regression, Decision Trees, Random Forest, XGBoost.', 2),
    -- Modules cho Course 5 (DevOps)
    ('e0000000-0000-0000-0000-000000000012', 'd0000000-0000-0000-0000-000000000005', 'Chương 1: Docker Fundamentals', 'Containers, Images, Dockerfile, Docker Compose.', 1),
    ('e0000000-0000-0000-0000-000000000013', 'd0000000-0000-0000-0000-000000000005', 'Chương 2: Kubernetes Orchestration', 'Pods, Deployments, Services, Ingress, Helm.', 2),
    -- Modules cho Course 7 (Flutter)
    ('e0000000-0000-0000-0000-000000000014', 'd0000000-0000-0000-0000-000000000007', 'Chương 1: Dart Language & Flutter Widgets', 'Dart syntax, Widget tree, StatelessWidget, StatefulWidget.', 1),
    ('e0000000-0000-0000-0000-000000000015', 'd0000000-0000-0000-0000-000000000007', 'Chương 2: Navigation, State & Firebase', 'GoRouter, BLoC pattern, Firebase Auth/Firestore.', 2),
    -- Modules cho Course 8 (DSA)
    ('e0000000-0000-0000-0000-000000000016', 'd0000000-0000-0000-0000-000000000008', 'Chương 1: Arrays, Strings & Hashing', 'Two pointers, sliding window, hash maps.', 1),
    ('e0000000-0000-0000-0000-000000000017', 'd0000000-0000-0000-0000-000000000008', 'Chương 2: Trees, Graphs & DP', 'BFS, DFS, binary trees, dynamic programming patterns.', 2),
    -- Modules cho Course 10 (Python Beginners)
    ('e0000000-0000-0000-0000-000000000018', 'd0000000-0000-0000-0000-000000000010', 'Chapter 1: Python Fundamentals', 'Variables, data types, control flow, functions.', 1),
    ('e0000000-0000-0000-0000-000000000019', 'd0000000-0000-0000-0000-000000000010', 'Chapter 2: OOP & File I/O', 'Classes, inheritance, file reading/writing, exceptions.', 2),
    -- Modules cho Course 11 (HTML/CSS/JS)
    ('e0000000-0000-0000-0000-000000000020', 'd0000000-0000-0000-0000-000000000011', 'Chương 1: HTML5 & CSS3 Căn bản', 'Semantic HTML, Flexbox, Grid Layout.', 1),
    ('e0000000-0000-0000-0000-000000000021', 'd0000000-0000-0000-0000-000000000011', 'Chương 2: JavaScript ES6+', 'let/const, arrow functions, promises, DOM manipulation.', 2),
    -- Modules cho Course 13 (Node.js)
    ('e0000000-0000-0000-0000-000000000022', 'd0000000-0000-0000-0000-000000000013', 'Chapter 1: Node.js & Express Setup', 'Node runtime, Express routing, middleware.', 1),
    ('e0000000-0000-0000-0000-000000000023', 'd0000000-0000-0000-0000-000000000013', 'Chapter 2: MongoDB & Authentication', 'Mongoose ODM, JWT auth, bcrypt.', 2),
    -- Modules cho Course 19 (Java OOP)
    ('e0000000-0000-0000-0000-000000000024', 'd0000000-0000-0000-0000-000000000019', 'Chương 1: OOP 4 Tính chất', 'Encapsulation, Inheritance, Polymorphism, Abstraction.', 1),
    ('e0000000-0000-0000-0000-000000000025', 'd0000000-0000-0000-0000-000000000019', 'Chương 2: Design Patterns & SOLID', 'Factory, Strategy, Observer, SOLID principles.', 2),
    -- Modules cho Course 17 (Git)
    ('e0000000-0000-0000-0000-000000000026', 'd0000000-0000-0000-0000-000000000017', 'Chương 1: Git Cơ bản', 'init, add, commit, branch, merge, rebase.', 1),
    ('e0000000-0000-0000-0000-000000000027', 'd0000000-0000-0000-0000-000000000017', 'Chương 2: GitHub & Collaboration', 'Pull requests, code review, GitHub Actions.', 2),
    -- Modules cho Course 21 (Next.js)
    ('e0000000-0000-0000-0000-000000000028', 'd0000000-0000-0000-0000-000000000021', 'Chapter 1: Next.js App Router', 'File-based routing, layouts, server components.', 1),
    ('e0000000-0000-0000-0000-000000000029', 'd0000000-0000-0000-0000-000000000021', 'Chapter 2: Full-Stack with Prisma', 'Server actions, Prisma ORM, database integration.', 2)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 5. SEED LESSON (Bài học)
-- ---------------------------------------------------------------------
INSERT INTO lesson (status, id, module_id, title, content, order_index, duration_minutes) VALUES
    -- Course 1, Module 1
    ('published', 'f0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001',
     'Bài 1: Giới thiệu Kiến trúc Web & Jakarta Servlet 6.0',
     '<h3>Nội dung bài học:</h3><p>Kiến trúc Client-Server, Tomcat 10.1, Servlet Container.</p><ul><li>Vòng đời Servlet: init(), service(), destroy()</li><li>Phân biệt GET vs POST</li><li>@WebServlet annotation</li></ul>', 1, 25),
    ('published', 'f0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001',
     'Bài 2: HttpServletRequest, HttpServletResponse & RequestDispatcher',
     '<h3>Đọc tham số và gửi phản hồi:</h3><p>req.getParameter(), forward, sendRedirect.</p>', 2, 30),
    ('published', 'f0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000001',
     'Bài 3: Tích hợp HikariCP Connection Pool kết nối PostgreSQL',
     '<h3>Tối ưu hóa kết nối CSDL:</h3><p>HikariCP connection pool configuration.</p>', 3, 35),
    -- Course 1, Module 2
    ('published', 'f0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000002',
     'Bài 4: Giới thiệu JSP & Expression Language (EL)',
     '<p>Expression Language ${user.username} truy cập thuộc tính trong scope.</p>', 1, 20),
    ('published', 'f0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000002',
     'Bài 5: JSTL Core Tags & Render Danh sách Động',
     '<p>Sử dụng c:forEach, c:if, c:choose để duyệt danh sách.</p>', 2, 25),
    -- Course 1, Module 3
    ('published', 'f0000000-0000-0000-0000-000000000006', 'e0000000-0000-0000-0000-000000000003',
     'Bài 6: Quản lý Phiên Đăng nhập với HttpSession',
     '<p>Tạo session, lưu User, session.invalidate() logout.</p>', 1, 20),
    ('published', 'f0000000-0000-0000-0000-000000000007', 'e0000000-0000-0000-0000-000000000003',
     'Bài 7: Xây dựng Authorization Filter & Phân quyền RBAC',
     '<p>Filter chặn URL /admin/*, /expert/* kiểm tra Role Code.</p>', 2, 30),
    -- Course 2, Module 1
    ('published', 'f0000000-0000-0000-0000-000000000008', 'e0000000-0000-0000-0000-000000000004',
     'Bài 1: Kiến trúc Lưu trữ PostgreSQL & MVCC',
     '<p>MVCC, Vacuuming, concurrent writes without read locks.</p>', 1, 35),
    -- Course 2, Module 2
    ('published', 'f0000000-0000-0000-0000-000000000009', 'e0000000-0000-0000-0000-000000000005',
     'Bài 2: Tối ưu Indexing B-Tree & Phân tích EXPLAIN',
     '<p>Sequential Scan, Index Scan, Composite Index strategies.</p>', 1, 40),
    -- Course 10, Module 1 (Python)
    ('published', 'f0000000-0000-0000-0000-000000000010', 'e0000000-0000-0000-0000-000000000018',
     'Lesson 1: Installing Python & Hello World',
     '<p>Install Python 3.12, setup VS Code, write your first script.</p>', 1, 15),
    ('published', 'f0000000-0000-0000-0000-000000000011', 'e0000000-0000-0000-0000-000000000018',
     'Lesson 2: Variables, Data Types & Operators',
     '<p>int, float, str, bool, lists, tuples, dictionaries.</p>', 2, 20),
    -- Course 10, Module 2
    ('published', 'f0000000-0000-0000-0000-000000000012', 'e0000000-0000-0000-0000-000000000019',
     'Lesson 3: Classes & Inheritance',
     '<p>Defining classes, __init__, inheritance, super().</p>', 1, 25),
    -- Course 11, Module 1 (HTML/CSS/JS)
    ('published', 'f0000000-0000-0000-0000-000000000013', 'e0000000-0000-0000-0000-000000000020',
     'Bài 1: HTML5 Semantic Elements',
     '<p>header, nav, main, article, section, footer.</p>', 1, 20),
    ('published', 'f0000000-0000-0000-0000-000000000014', 'e0000000-0000-0000-0000-000000000020',
     'Bài 2: CSS Flexbox & Grid Layout',
     '<p>display:flex, justify-content, align-items, grid-template.</p>', 2, 30),
    -- Course 11, Module 2
    ('published', 'f0000000-0000-0000-0000-000000000015', 'e0000000-0000-0000-0000-000000000021',
     'Bài 3: JavaScript DOM Manipulation',
     '<p>querySelector, addEventListener, createElement.</p>', 1, 25),
    -- Course 3, Module 1 (Spring Boot)
    ('published', 'f0000000-0000-0000-0000-000000000016', 'e0000000-0000-0000-0000-000000000006',
     'Bài 1: Spring Boot Starter & Auto Configuration',
     '<p>Spring Initializr, application.properties, embedded Tomcat.</p>', 1, 30),
    ('published', 'f0000000-0000-0000-0000-000000000017', 'e0000000-0000-0000-0000-000000000006',
     'Bài 2: REST Controller & Request Mapping',
     '<p>@RestController, @GetMapping, @PostMapping, ResponseEntity.</p>', 2, 25),
    -- Course 6, Module 1 (React)
    ('published', 'f0000000-0000-0000-0000-000000000018', 'e0000000-0000-0000-0000-000000000008',
     'Lesson 1: JSX & Component Basics',
     '<p>JSX syntax, functional components, props.</p>', 1, 20),
    ('published', 'f0000000-0000-0000-0000-000000000019', 'e0000000-0000-0000-0000-000000000008',
     'Lesson 2: useState & useEffect Hooks',
     '<p>State management, side effects, cleanup functions.</p>', 2, 25)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 6. SEED QUIZ (Bài thi trắc nghiệm)
-- ---------------------------------------------------------------------
INSERT INTO quiz (id, module_id, title, time_limit, pass_score, status, image_url) VALUES
    ('10000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'Quiz Ôn tập: Vòng đời Servlet & Xử lý HTTP Request', 15, 5.0, 'published', 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&auto=format&fit=crop&q=80'),
    ('10000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'Quiz Đánh giá: JSP, JSTL Core Tags & Mô hình MVC', 20, 6.0, 'published', 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=400&auto=format&fit=crop&q=80'),
    ('10000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000003', 'Quiz Bảo mật: Session, Cookie & Filter Authorization', 20, 7.0, 'published', 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400&auto=format&fit=crop&q=80'),
    ('10000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000005', 'Quiz Chuyên gia: Đánh Index & Đọc EXPLAIN PostgreSQL', 25, 8.0, 'published', 'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=400&auto=format&fit=crop&q=80'),
    ('10000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000018', 'Python Basics Quiz', 15, 5.0, 'published', NULL),
    ('10000000-0000-0000-0000-000000000006', 'e0000000-0000-0000-0000-000000000010', 'Data Science Fundamentals Quiz', 20, 6.0, 'published', NULL),
    ('10000000-0000-0000-0000-000000000007', 'e0000000-0000-0000-0000-000000000012', 'Docker Basics Quiz', 15, 5.0, 'published', NULL),
    ('10000000-0000-0000-0000-000000000008', 'e0000000-0000-0000-0000-000000000008', 'React Hooks Quiz', 20, 6.0, 'published', NULL)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 7. SEED QUESTION (Ngân hàng câu hỏi)
-- ---------------------------------------------------------------------
INSERT INTO question (id, module_id, content, type, status) VALUES
    ('20000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'Phương thức nào trong vòng đời của Servlet chỉ được gọi đúng MỘT lần duy nhất khi Servlet được khởi tạo?', 'single_choice', 'public'),
    ('20000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'Sự khác biệt chính giữa RequestDispatcher.forward() và HttpServletResponse.sendRedirect() là gì?', 'single_choice', 'public'),
    ('20000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000001', 'Trong Jakarta EE 10, package nào thay thế hoàn toàn cho package cũ "javax.servlet"?', 'single_choice', 'public'),
    ('20000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000002', 'Thẻ JSTL nào sau đây được sử dụng để duyệt qua một Collection hoặc mảng trong JSP?', 'single_choice', 'public'),
    ('20000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000003', 'Phương thức nào được dùng để hủy bỏ hoàn toàn một HttpSession khi người dùng đăng xuất?', 'single_choice', 'public'),
    ('20000000-0000-0000-0000-000000000006', 'e0000000-0000-0000-0000-000000000001', 'Trong kiến trúc MVC, tầng Controller đảm nhiệm vai trò gì?', 'single_choice', 'public'),
    ('20000000-0000-0000-0000-000000000007', 'e0000000-0000-0000-0000-000000000005', 'Loại Index mặc định trong PostgreSQL khi bạn tạo khóa chính (Primary Key) là gì?', 'single_choice', 'public'),
    ('20000000-0000-0000-0000-000000000008', 'e0000000-0000-0000-0000-000000000005', 'Lệnh nào trong PostgreSQL cho phép xem thời gian thực tế thực thi câu lệnh SQL?', 'single_choice', 'public'),
    ('20000000-0000-0000-0000-000000000009', 'e0000000-0000-0000-0000-000000000001', 'Điền vào chỗ trống: Phương thức xử lý HTTP GET trong HttpServlet là _____', 'fill_in_blank', 'public'),
    ('20000000-0000-0000-0000-000000000010', 'e0000000-0000-0000-0000-000000000018', 'What is the output of: print(type(3.14))?', 'single_choice', 'public'),
    ('20000000-0000-0000-0000-000000000011', 'e0000000-0000-0000-0000-000000000018', 'Which keyword is used to define a function in Python?', 'single_choice', 'public')
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 8. SEED QUESTION_OPTION
-- ---------------------------------------------------------------------
INSERT INTO question_option (id, question_id, option_text, is_correct) VALUES
    ('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'init(ServletConfig config)', TRUE),
    ('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'service(ServletRequest req, ServletResponse res)', FALSE),
    ('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', 'doGet(HttpServletRequest req, HttpServletResponse res)', FALSE),
    ('30000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000001', 'destroy()', FALSE),
    ('30000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002', 'forward() thực hiện ở phía Server và giữ nguyên URL - sendRedirect() gửi mã chuyển hướng về Browser', TRUE),
    ('30000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000002', 'forward() gửi mã HTTP 302 về trình duyệt', FALSE),
    ('30000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000002', 'Cả hai phương thức đều thực hiện ở Client', FALSE),
    ('30000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000002', 'forward() không thể truyền thuộc tính trong request', FALSE),
    ('30000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000003', 'jakarta.servlet', TRUE),
    ('30000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000003', 'org.apache.servlet', FALSE),
    ('30000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000003', 'java.servlet', FALSE),
    ('30000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000003', 'javax.jakarta.servlet', FALSE),
    ('30000000-0000-0000-0000-000000000013', '20000000-0000-0000-0000-000000000004', '<c:forEach items="${list}" var="item">', TRUE),
    ('30000000-0000-0000-0000-000000000014', '20000000-0000-0000-0000-000000000004', '<c:iterate collection="${list}">', FALSE),
    ('30000000-0000-0000-0000-000000000015', '20000000-0000-0000-0000-000000000004', '<c:loop items="${list}">', FALSE),
    ('30000000-0000-0000-0000-000000000016', '20000000-0000-0000-0000-000000000004', '<c:while condition="${list.hasNext()}">', FALSE),
    ('30000000-0000-0000-0000-000000000017', '20000000-0000-0000-0000-000000000005', 'session.invalidate()', TRUE),
    ('30000000-0000-0000-0000-000000000018', '20000000-0000-0000-0000-000000000005', 'session.destroy()', FALSE),
    ('30000000-0000-0000-0000-000000000019', '20000000-0000-0000-0000-000000000005', 'session.clear()', FALSE),
    ('30000000-0000-0000-0000-000000000020', '20000000-0000-0000-0000-000000000005', 'session.remove()', FALSE),
    ('30000000-0000-0000-0000-000000000021', '20000000-0000-0000-0000-000000000006', 'Tiếp nhận Request, gọi Service xử lý và điều hướng View', TRUE),
    ('30000000-0000-0000-0000-000000000022', '20000000-0000-0000-0000-000000000006', 'Trực tiếp thực thi SQL vào Database', FALSE),
    ('30000000-0000-0000-0000-000000000023', '20000000-0000-0000-0000-000000000006', 'Hiển thị giao diện HTML/CSS ra trình duyệt', FALSE),
    ('30000000-0000-0000-0000-000000000024', '20000000-0000-0000-0000-000000000006', 'Chứa các thẻ định dạng văn bản', FALSE),
    ('30000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000007', 'B-Tree Index', TRUE),
    ('30000000-0000-0000-0000-000000000026', '20000000-0000-0000-0000-000000000007', 'Hash Index', FALSE),
    ('30000000-0000-0000-0000-000000000027', '20000000-0000-0000-0000-000000000007', 'GIN Index', FALSE),
    ('30000000-0000-0000-0000-000000000028', '20000000-0000-0000-0000-000000000007', 'BRIN Index', FALSE),
    ('30000000-0000-0000-0000-000000000029', '20000000-0000-0000-0000-000000000008', 'EXPLAIN ANALYZE <câu_lệnh_sql>', TRUE),
    ('30000000-0000-0000-0000-000000000030', '20000000-0000-0000-0000-000000000008', 'DESCRIBE <câu_lệnh_sql>', FALSE),
    ('30000000-0000-0000-0000-000000000031', '20000000-0000-0000-0000-000000000008', 'SHOW PROFILE <câu_lệnh_sql>', FALSE),
    ('30000000-0000-0000-0000-000000000032', '20000000-0000-0000-0000-000000000008', 'OPTIMIZE <câu_lệnh_sql>', FALSE),
    ('30000000-0000-0000-0000-000000000033', '20000000-0000-0000-0000-000000000009', 'doGet', TRUE),
    ('30000000-0000-0000-0000-000000000034', '20000000-0000-0000-0000-000000000009', 'doGet()', TRUE),
    ('30000000-0000-0000-0000-000000000035', '20000000-0000-0000-0000-000000000010', '<class ''float''>', TRUE),
    ('30000000-0000-0000-0000-000000000036', '20000000-0000-0000-0000-000000000010', '<class ''int''>', FALSE),
    ('30000000-0000-0000-0000-000000000037', '20000000-0000-0000-0000-000000000010', '<class ''str''>', FALSE),
    ('30000000-0000-0000-0000-000000000038', '20000000-0000-0000-0000-000000000010', '<class ''double''>', FALSE),
    ('30000000-0000-0000-0000-000000000039', '20000000-0000-0000-0000-000000000011', 'def', TRUE),
    ('30000000-0000-0000-0000-000000000040', '20000000-0000-0000-0000-000000000011', 'function', FALSE),
    ('30000000-0000-0000-0000-000000000041', '20000000-0000-0000-0000-000000000011', 'func', FALSE),
    ('30000000-0000-0000-0000-000000000042', '20000000-0000-0000-0000-000000000011', 'lambda', FALSE)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 9. SEED QUIZ_QUESTION
-- ---------------------------------------------------------------------
INSERT INTO quiz_question (id, quiz_id, question_id, order_index) VALUES
    ('40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 1),
    ('40000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 2),
    ('40000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 3),
    ('40000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000004', 1),
    ('40000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000006', 2),
    ('40000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000005', 1),
    ('40000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000007', 1),
    ('40000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000008', 2),
    ('40000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000010', 1),
    ('40000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000011', 2)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 10. SEED REGISTRATION (130+ đăng ký khóa học – trải đều 6 tháng)
-- Dữ liệu quan trọng nhất cho Admin Dashboard charts
-- ---------------------------------------------------------------------
INSERT INTO registration (id, user_id, course_id, enrolled_at, status, progress_percent, amount, payment_method_id, transaction_id, payment_status, paid_at) VALUES
    -- ═══════════════════════════════════════════════════════════════════
    -- THÁNG 1 (5 tháng trước) — ~18 registrations
    -- ═══════════════════════════════════════════════════════════════════
    ('50000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '152 days', 'completed', 100, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892019', 'paid', NOW() - INTERVAL '152 days'),
    ('50000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000002',
     NOW() - INTERVAL '148 days', 'completed', 100, 550000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291001', 'paid', NOW() - INTERVAL '148 days'),
    ('50000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000009', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '150 days', 'completed', 100, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892020', 'paid', NOW() - INTERVAL '150 days'),
    ('50000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000010', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '147 days', 'completed', 100, 890000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892021', 'paid', NOW() - INTERVAL '147 days'),
    ('50000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000011', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '145 days', 'completed', 100, 620000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291002', 'paid', NOW() - INTERVAL '145 days'),
    ('50000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000012', 'd0000000-0000-0000-0000-000000000004',
     NOW() - INTERVAL '143 days', 'enrolled', 80, 1190000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892022', 'paid', NOW() - INTERVAL '143 days'),
    ('50000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000013', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '142 days', 'enrolled', 70, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892023', 'paid', NOW() - INTERVAL '142 days'),
    ('50000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000014', 'd0000000-0000-0000-0000-000000000008',
     NOW() - INTERVAL '140 days', 'completed', 100, 450000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291003', 'paid', NOW() - INTERVAL '140 days'),
    ('50000000-0000-0000-0000-000000000009', 'c0000000-0000-0000-0000-000000000015', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '138 days', 'enrolled', 60, 620000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892024', 'paid', NOW() - INTERVAL '138 days'),
    ('50000000-0000-0000-0000-000000000010', 'c0000000-0000-0000-0000-000000000018', 'd0000000-0000-0000-0000-000000000010',
     NOW() - INTERVAL '146 days', 'completed', 100, 399000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892025', 'paid', NOW() - INTERVAL '146 days'),
    ('50000000-0000-0000-0000-000000000011', 'c0000000-0000-0000-0000-000000000019', 'd0000000-0000-0000-0000-000000000011',
     NOW() - INTERVAL '144 days', 'completed', 100, 299000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291004', 'paid', NOW() - INTERVAL '144 days'),
    ('50000000-0000-0000-0000-000000000012', 'c0000000-0000-0000-0000-000000000020', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '141 days', 'enrolled', 50, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892026', 'paid', NOW() - INTERVAL '141 days'),
    ('50000000-0000-0000-0000-000000000013', 'c0000000-0000-0000-0000-000000000021', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '139 days', 'enrolled', 40, 890000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291005', 'paid', NOW() - INTERVAL '139 days'),
    ('50000000-0000-0000-0000-000000000014', 'c0000000-0000-0000-0000-000000000022', 'd0000000-0000-0000-0000-000000000010',
     NOW() - INTERVAL '149 days', 'completed', 100, 399000.00, 'b0000000-0000-0000-0000-000000000014', 'TXCC994801', 'paid', NOW() - INTERVAL '149 days'),
    ('50000000-0000-0000-0000-000000000015', 'c0000000-0000-0000-0000-000000000023', 'd0000000-0000-0000-0000-000000000004',
     NOW() - INTERVAL '137 days', 'enrolled', 30, 1190000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892027', 'paid', NOW() - INTERVAL '137 days'),
    ('50000000-0000-0000-0000-000000000016', 'c0000000-0000-0000-0000-000000000009', 'd0000000-0000-0000-0000-000000000008',
     NOW() - INTERVAL '136 days', 'enrolled', 60, 450000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892028', 'paid', NOW() - INTERVAL '136 days'),
    ('50000000-0000-0000-0000-000000000017', 'c0000000-0000-0000-0000-000000000024', 'd0000000-0000-0000-0000-000000000005',
     NOW() - INTERVAL '135 days', 'cancelled', 0, 990000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892029', 'refunded', NOW() - INTERVAL '135 days'),
    ('50000000-0000-0000-0000-000000000018', 'c0000000-0000-0000-0000-000000000025', 'd0000000-0000-0000-0000-000000000011',
     NOW() - INTERVAL '134 days', 'enrolled', 90, 299000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291006', 'paid', NOW() - INTERVAL '134 days'),

    -- ═══════════════════════════════════════════════════════════════════
    -- THÁNG 2 (4 tháng trước) — ~22 registrations
    -- ═══════════════════════════════════════════════════════════════════
    ('50000000-0000-0000-0000-000000000019', 'c0000000-0000-0000-0000-000000000026', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '128 days', 'enrolled', 50, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892030', 'paid', NOW() - INTERVAL '128 days'),
    ('50000000-0000-0000-0000-000000000020', 'c0000000-0000-0000-0000-000000000027', 'd0000000-0000-0000-0000-000000000002',
     NOW() - INTERVAL '126 days', 'enrolled', 40, 550000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291007', 'paid', NOW() - INTERVAL '126 days'),
    ('50000000-0000-0000-0000-000000000021', 'c0000000-0000-0000-0000-000000000028', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '124 days', 'enrolled', 70, 620000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892031', 'paid', NOW() - INTERVAL '124 days'),
    ('50000000-0000-0000-0000-000000000022', 'c0000000-0000-0000-0000-000000000029', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '122 days', 'completed', 100, 890000.00, 'b0000000-0000-0000-0000-000000000014', 'TXCC994802', 'paid', NOW() - INTERVAL '122 days'),
    ('50000000-0000-0000-0000-000000000023', 'c0000000-0000-0000-0000-000000000030', 'd0000000-0000-0000-0000-000000000010',
     NOW() - INTERVAL '120 days', 'enrolled', 60, 399000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892032', 'paid', NOW() - INTERVAL '120 days'),
    ('50000000-0000-0000-0000-000000000024', 'c0000000-0000-0000-0000-000000000031', 'd0000000-0000-0000-0000-000000000004',
     NOW() - INTERVAL '118 days', 'enrolled', 20, 1190000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892033', 'paid', NOW() - INTERVAL '118 days'),
    ('50000000-0000-0000-0000-000000000025', 'c0000000-0000-0000-0000-000000000032', 'd0000000-0000-0000-0000-000000000005',
     NOW() - INTERVAL '116 days', 'enrolled', 30, 990000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291008', 'paid', NOW() - INTERVAL '116 days'),
    ('50000000-0000-0000-0000-000000000026', 'c0000000-0000-0000-0000-000000000033', 'd0000000-0000-0000-0000-000000000012',
     NOW() - INTERVAL '127 days', 'enrolled', 10, 1490000.00, 'b0000000-0000-0000-0000-000000000014', 'TXCC994803', 'paid', NOW() - INTERVAL '127 days'),
    ('50000000-0000-0000-0000-000000000027', 'c0000000-0000-0000-0000-000000000034', 'd0000000-0000-0000-0000-000000000011',
     NOW() - INTERVAL '125 days', 'completed', 100, 299000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892034', 'paid', NOW() - INTERVAL '125 days'),
    ('50000000-0000-0000-0000-000000000028', 'c0000000-0000-0000-0000-000000000035', 'd0000000-0000-0000-0000-000000000013',
     NOW() - INTERVAL '123 days', 'enrolled', 50, 599000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892035', 'paid', NOW() - INTERVAL '123 days'),
    ('50000000-0000-0000-0000-000000000029', 'c0000000-0000-0000-0000-000000000010', 'd0000000-0000-0000-0000-000000000005',
     NOW() - INTERVAL '121 days', 'enrolled', 40, 990000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892036', 'paid', NOW() - INTERVAL '121 days'),
    ('50000000-0000-0000-0000-000000000030', 'c0000000-0000-0000-0000-000000000011', 'd0000000-0000-0000-0000-000000000010',
     NOW() - INTERVAL '119 days', 'enrolled', 70, 399000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291009', 'paid', NOW() - INTERVAL '119 days'),
    ('50000000-0000-0000-0000-000000000031', 'c0000000-0000-0000-0000-000000000012', 'd0000000-0000-0000-0000-000000000014',
     NOW() - INTERVAL '117 days', 'enrolled', 50, 490000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892037', 'paid', NOW() - INTERVAL '117 days'),
    ('50000000-0000-0000-0000-000000000032', 'c0000000-0000-0000-0000-000000000036', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '115 days', 'enrolled', 20, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892038', 'paid', NOW() - INTERVAL '115 days'),
    ('50000000-0000-0000-0000-000000000033', 'c0000000-0000-0000-0000-000000000013', 'd0000000-0000-0000-0000-000000000002',
     NOW() - INTERVAL '113 days', 'enrolled', 30, 550000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291010', 'paid', NOW() - INTERVAL '113 days'),
    ('50000000-0000-0000-0000-000000000034', 'c0000000-0000-0000-0000-000000000037', 'd0000000-0000-0000-0000-000000000013',
     NOW() - INTERVAL '111 days', 'enrolled', 40, 599000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892039', 'paid', NOW() - INTERVAL '111 days'),
    ('50000000-0000-0000-0000-000000000035', 'c0000000-0000-0000-0000-000000000018', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '129 days', 'enrolled', 60, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892040', 'paid', NOW() - INTERVAL '129 days'),
    ('50000000-0000-0000-0000-000000000036', 'c0000000-0000-0000-0000-000000000019', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '130 days', 'cancelled', 0, 620000.00, 'b0000000-0000-0000-0000-000000000011', NULL, 'failed', NULL),
    ('50000000-0000-0000-0000-000000000037', 'c0000000-0000-0000-0000-000000000022', 'd0000000-0000-0000-0000-000000000008',
     NOW() - INTERVAL '114 days', 'enrolled', 80, 450000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892041', 'paid', NOW() - INTERVAL '114 days'),
    ('50000000-0000-0000-0000-000000000038', 'c0000000-0000-0000-0000-000000000023', 'd0000000-0000-0000-0000-000000000007',
     NOW() - INTERVAL '112 days', 'enrolled', 20, 750000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291011', 'paid', NOW() - INTERVAL '112 days'),
    ('50000000-0000-0000-0000-000000000039', 'c0000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000010',
     NOW() - INTERVAL '110 days', 'completed', 100, 399000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892042', 'paid', NOW() - INTERVAL '110 days'),
    ('50000000-0000-0000-0000-000000000040', 'c0000000-0000-0000-0000-000000000015', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '109 days', 'enrolled', 30, 890000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892043', 'paid', NOW() - INTERVAL '109 days'),

    -- ═══════════════════════════════════════════════════════════════════
    -- THÁNG 3 (3 tháng trước) — ~24 registrations
    -- ═══════════════════════════════════════════════════════════════════
    ('50000000-0000-0000-0000-000000000041', 'c0000000-0000-0000-0000-000000000038', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '98 days', 'enrolled', 40, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892044', 'paid', NOW() - INTERVAL '98 days'),
    ('50000000-0000-0000-0000-000000000042', 'c0000000-0000-0000-0000-000000000039', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '96 days', 'enrolled', 50, 620000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291012', 'paid', NOW() - INTERVAL '96 days'),
    ('50000000-0000-0000-0000-000000000043', 'c0000000-0000-0000-0000-000000000040', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '95 days', 'enrolled', 30, 890000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892045', 'paid', NOW() - INTERVAL '95 days'),
    ('50000000-0000-0000-0000-000000000044', 'c0000000-0000-0000-0000-000000000041', 'd0000000-0000-0000-0000-000000000015',
     NOW() - INTERVAL '93 days', 'enrolled', 20, 799000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892046', 'paid', NOW() - INTERVAL '93 days'),
    ('50000000-0000-0000-0000-000000000045', 'c0000000-0000-0000-0000-000000000042', 'd0000000-0000-0000-0000-000000000016',
     NOW() - INTERVAL '92 days', 'enrolled', 60, 690000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291013', 'paid', NOW() - INTERVAL '92 days'),
    ('50000000-0000-0000-0000-000000000046', 'c0000000-0000-0000-0000-000000000043', 'd0000000-0000-0000-0000-000000000017',
     NOW() - INTERVAL '91 days', 'completed', 100, 350000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892047', 'paid', NOW() - INTERVAL '91 days'),
    ('50000000-0000-0000-0000-000000000047', 'c0000000-0000-0000-0000-000000000044', 'd0000000-0000-0000-0000-000000000019',
     NOW() - INTERVAL '90 days', 'enrolled', 40, 550000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892048', 'paid', NOW() - INTERVAL '90 days'),
    ('50000000-0000-0000-0000-000000000048', 'c0000000-0000-0000-0000-000000000045', 'd0000000-0000-0000-0000-000000000004',
     NOW() - INTERVAL '89 days', 'enrolled', 10, 1190000.00, 'b0000000-0000-0000-0000-000000000014', 'TXCC994804', 'paid', NOW() - INTERVAL '89 days'),
    ('50000000-0000-0000-0000-000000000049', 'c0000000-0000-0000-0000-000000000046', 'd0000000-0000-0000-0000-000000000012',
     NOW() - INTERVAL '88 days', 'enrolled', 20, 1490000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892049', 'paid', NOW() - INTERVAL '88 days'),
    ('50000000-0000-0000-0000-000000000050', 'c0000000-0000-0000-0000-000000000047', 'd0000000-0000-0000-0000-000000000005',
     NOW() - INTERVAL '87 days', 'enrolled', 30, 990000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291014', 'paid', NOW() - INTERVAL '87 days'),
    ('50000000-0000-0000-0000-000000000051', 'c0000000-0000-0000-0000-000000000026', 'd0000000-0000-0000-0000-000000000010',
     NOW() - INTERVAL '97 days', 'enrolled', 80, 399000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892050', 'paid', NOW() - INTERVAL '97 days'),
    ('50000000-0000-0000-0000-000000000052', 'c0000000-0000-0000-0000-000000000029', 'd0000000-0000-0000-0000-000000000011',
     NOW() - INTERVAL '94 days', 'completed', 100, 299000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892051', 'paid', NOW() - INTERVAL '94 days'),
    ('50000000-0000-0000-0000-000000000053', 'c0000000-0000-0000-0000-000000000030', 'd0000000-0000-0000-0000-000000000017',
     NOW() - INTERVAL '86 days', 'enrolled', 50, 350000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291015', 'paid', NOW() - INTERVAL '86 days'),
    ('50000000-0000-0000-0000-000000000054', 'c0000000-0000-0000-0000-000000000031', 'd0000000-0000-0000-0000-000000000019',
     NOW() - INTERVAL '85 days', 'enrolled', 60, 550000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892052', 'paid', NOW() - INTERVAL '85 days'),
    ('50000000-0000-0000-0000-000000000055', 'c0000000-0000-0000-0000-000000000020', 'd0000000-0000-0000-0000-000000000004',
     NOW() - INTERVAL '99 days', 'enrolled', 10, 1190000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892053', 'paid', NOW() - INTERVAL '99 days'),
    ('50000000-0000-0000-0000-000000000056', 'c0000000-0000-0000-0000-000000000034', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '84 days', 'enrolled', 30, 620000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892054', 'paid', NOW() - INTERVAL '84 days'),
    ('50000000-0000-0000-0000-000000000057', 'c0000000-0000-0000-0000-000000000035', 'd0000000-0000-0000-0000-000000000005',
     NOW() - INTERVAL '83 days', 'cancelled', 0, 990000.00, 'b0000000-0000-0000-0000-000000000011', NULL, 'failed', NULL),
    ('50000000-0000-0000-0000-000000000058', 'c0000000-0000-0000-0000-000000000048', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '82 days', 'enrolled', 20, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892055', 'paid', NOW() - INTERVAL '82 days'),
    ('50000000-0000-0000-0000-000000000059', 'c0000000-0000-0000-0000-000000000009', 'd0000000-0000-0000-0000-000000000014',
     NOW() - INTERVAL '100 days', 'enrolled', 70, 490000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291016', 'paid', NOW() - INTERVAL '100 days'),
    ('50000000-0000-0000-0000-000000000060', 'c0000000-0000-0000-0000-000000000033', 'd0000000-0000-0000-0000-000000000018',
     NOW() - INTERVAL '88 days', 'enrolled', 40, 720000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892056', 'paid', NOW() - INTERVAL '88 days'),
    ('50000000-0000-0000-0000-000000000061', 'c0000000-0000-0000-0000-000000000024', 'd0000000-0000-0000-0000-000000000011',
     NOW() - INTERVAL '96 days', 'enrolled', 90, 299000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892057', 'paid', NOW() - INTERVAL '96 days'),
    ('50000000-0000-0000-0000-000000000062', 'c0000000-0000-0000-0000-000000000025', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '95 days', 'enrolled', 50, 699000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291017', 'paid', NOW() - INTERVAL '95 days'),
    ('50000000-0000-0000-0000-000000000063', 'c0000000-0000-0000-0000-000000000014', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '91 days', 'enrolled', 40, 620000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892058', 'paid', NOW() - INTERVAL '91 days'),
    ('50000000-0000-0000-0000-000000000064', 'c0000000-0000-0000-0000-000000000021', 'd0000000-0000-0000-0000-000000000010',
     NOW() - INTERVAL '85 days', 'enrolled', 60, 399000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892059', 'paid', NOW() - INTERVAL '85 days'),

    -- ═══════════════════════════════════════════════════════════════════
    -- THÁNG 4 (2 tháng trước: ~65 - 40 ngày trước) — ~25 registrations
    -- ═══════════════════════════════════════════════════════════════════
    ('50000000-0000-0000-0000-000000000065', 'c0000000-0000-0000-0000-000000000049', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '65 days', 'enrolled', 45, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892060', 'paid', NOW() - INTERVAL '65 days'),
    ('50000000-0000-0000-0000-000000000066', 'c0000000-0000-0000-0000-000000000050', 'd0000000-0000-0000-0000-000000000002',
     NOW() - INTERVAL '64 days', 'enrolled', 30, 550000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291018', 'paid', NOW() - INTERVAL '64 days'),
    ('50000000-0000-0000-0000-000000000067', 'c0000000-0000-0000-0000-000000000051', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '63 days', 'enrolled', 55, 890000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892061', 'paid', NOW() - INTERVAL '63 days'),
    ('50000000-0000-0000-0000-000000000068', 'c0000000-0000-0000-0000-000000000052', 'd0000000-0000-0000-0000-000000000004',
     NOW() - INTERVAL '62 days', 'enrolled', 25, 1190000.00, 'b0000000-0000-0000-0000-000000000014', 'TXCC994805', 'paid', NOW() - INTERVAL '62 days'),
    ('50000000-0000-0000-0000-000000000069', 'c0000000-0000-0000-0000-000000000053', 'd0000000-0000-0000-0000-000000000005',
     NOW() - INTERVAL '61 days', 'enrolled', 40, 990000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291019', 'paid', NOW() - INTERVAL '61 days'),
    ('50000000-0000-0000-0000-000000000070', 'c0000000-0000-0000-0000-000000000054', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '60 days', 'completed', 100, 620000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892062', 'paid', NOW() - INTERVAL '60 days'),
    ('50000000-0000-0000-0000-000000000071', 'c0000000-0000-0000-0000-000000000055', 'd0000000-0000-0000-0000-000000000007',
     NOW() - INTERVAL '59 days', 'enrolled', 35, 750000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291020', 'paid', NOW() - INTERVAL '59 days'),
    ('50000000-0000-0000-0000-000000000072', 'c0000000-0000-0000-0000-000000000018', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '58 days', 'enrolled', 60, 890000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892063', 'paid', NOW() - INTERVAL '58 days'),
    ('50000000-0000-0000-0000-000000000073', 'c0000000-0000-0000-0000-000000000019', 'd0000000-0000-0000-0000-000000000002',
     NOW() - INTERVAL '57 days', 'enrolled', 50, 550000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892064', 'paid', NOW() - INTERVAL '57 days'),
    ('50000000-0000-0000-0000-000000000074', 'c0000000-0000-0000-0000-000000000020', 'd0000000-0000-0000-0000-000000000008',
     NOW() - INTERVAL '56 days', 'completed', 100, 450000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291021', 'paid', NOW() - INTERVAL '56 days'),
    ('50000000-0000-0000-0000-000000000075', 'c0000000-0000-0000-0000-000000000022', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '55 days', 'enrolled', 40, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892065', 'paid', NOW() - INTERVAL '55 days'),
    ('50000000-0000-0000-0000-000000000076', 'c0000000-0000-0000-0000-000000000023', 'd0000000-0000-0000-0000-000000000010',
     NOW() - INTERVAL '54 days', 'completed', 100, 399000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892066', 'paid', NOW() - INTERVAL '54 days'),
    ('50000000-0000-0000-0000-000000000077', 'c0000000-0000-0000-0000-000000000024', 'd0000000-0000-0000-0000-000000000013',
     NOW() - INTERVAL '53 days', 'enrolled', 30, 599000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291022', 'paid', NOW() - INTERVAL '53 days'),
    ('50000000-0000-0000-0000-000000000078', 'c0000000-0000-0000-0000-000000000025', 'd0000000-0000-0000-0000-000000000014',
     NOW() - INTERVAL '52 days', 'enrolled', 65, 490000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892067', 'paid', NOW() - INTERVAL '52 days'),
    ('50000000-0000-0000-0000-000000000079', 'c0000000-0000-0000-0000-000000000027', 'd0000000-0000-0000-0000-000000000015',
     NOW() - INTERVAL '51 days', 'enrolled', 20, 799000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892068', 'paid', NOW() - INTERVAL '51 days'),
    ('50000000-0000-0000-0000-000000000080', 'c0000000-0000-0000-0000-000000000028', 'd0000000-0000-0000-0000-000000000016',
     NOW() - INTERVAL '50 days', 'enrolled', 45, 690000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291023', 'paid', NOW() - INTERVAL '50 days'),
    ('50000000-0000-0000-0000-000000000081', 'c0000000-0000-0000-0000-000000000030', 'd0000000-0000-0000-0000-000000000020',
     NOW() - INTERVAL '49 days', 'enrolled', 30, 580000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892069', 'paid', NOW() - INTERVAL '49 days'),
    ('50000000-0000-0000-0000-000000000082', 'c0000000-0000-0000-0000-000000000032', 'd0000000-0000-0000-0000-000000000021',
     NOW() - INTERVAL '48 days', 'enrolled', 20, 890000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892070', 'paid', NOW() - INTERVAL '48 days'),
    ('50000000-0000-0000-0000-000000000083', 'c0000000-0000-0000-0000-000000000036', 'd0000000-0000-0000-0000-000000000022',
     NOW() - INTERVAL '47 days', 'enrolled', 50, 520000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291024', 'paid', NOW() - INTERVAL '47 days'),
    ('50000000-0000-0000-0000-000000000084', 'c0000000-0000-0000-0000-000000000037', 'd0000000-0000-0000-0000-000000000023',
     NOW() - INTERVAL '46 days', 'enrolled', 60, 480000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892071', 'paid', NOW() - INTERVAL '46 days'),
    ('50000000-0000-0000-0000-000000000085', 'c0000000-0000-0000-0000-000000000038', 'd0000000-0000-0000-0000-000000000024',
     NOW() - INTERVAL '45 days', 'enrolled', 15, 880000.00, 'b0000000-0000-0000-0000-000000000014', 'TXCC994806', 'paid', NOW() - INTERVAL '45 days'),
    ('50000000-0000-0000-0000-000000000086', 'c0000000-0000-0000-0000-000000000039', 'd0000000-0000-0000-0000-000000000025',
     NOW() - INTERVAL '44 days', 'enrolled', 40, 650000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892072', 'paid', NOW() - INTERVAL '44 days'),
    ('50000000-0000-0000-0000-000000000087', 'c0000000-0000-0000-0000-000000000040', 'd0000000-0000-0000-0000-000000000011',
     NOW() - INTERVAL '43 days', 'completed', 100, 299000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892073', 'paid', NOW() - INTERVAL '43 days'),
    ('50000000-0000-0000-0000-000000000088', 'c0000000-0000-0000-0000-000000000041', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '42 days', 'enrolled', 70, 620000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291025', 'paid', NOW() - INTERVAL '42 days'),
    ('50000000-0000-0000-0000-000000000089', 'c0000000-0000-0000-0000-000000000042', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '41 days', 'enrolled', 35, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892074', 'paid', NOW() - INTERVAL '41 days'),

    -- ═══════════════════════════════════════════════════════════════════
    -- THÁNG 5 (1 tháng trước: ~39 - 15 ngày trước) — ~28 registrations
    -- ═══════════════════════════════════════════════════════════════════
    ('50000000-0000-0000-0000-000000000090', 'c0000000-0000-0000-0000-000000000043', 'd0000000-0000-0000-0000-000000000002',
     NOW() - INTERVAL '39 days', 'enrolled', 50, 550000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892075', 'paid', NOW() - INTERVAL '39 days'),
    ('50000000-0000-0000-0000-000000000091', 'c0000000-0000-0000-0000-000000000044', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '38 days', 'enrolled', 40, 890000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291026', 'paid', NOW() - INTERVAL '38 days'),
    ('50000000-0000-0000-0000-000000000092', 'c0000000-0000-0000-0000-000000000045', 'd0000000-0000-0000-0000-000000000010',
     NOW() - INTERVAL '37 days', 'completed', 100, 399000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892076', 'paid', NOW() - INTERVAL '37 days'),
    ('50000000-0000-0000-0000-000000000093', 'c0000000-0000-0000-0000-000000000046', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '36 days', 'enrolled', 60, 620000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892077', 'paid', NOW() - INTERVAL '36 days'),
    ('50000000-0000-0000-0000-000000000094', 'c0000000-0000-0000-0000-000000000047', 'd0000000-0000-0000-0000-000000000004',
     NOW() - INTERVAL '35 days', 'enrolled', 30, 1190000.00, 'b0000000-0000-0000-0000-000000000014', 'TXCC994807', 'paid', NOW() - INTERVAL '35 days'),
    ('50000000-0000-0000-0000-000000000095', 'c0000000-0000-0000-0000-000000000048', 'd0000000-0000-0000-0000-000000000005',
     NOW() - INTERVAL '34 days', 'enrolled', 25, 990000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892078', 'paid', NOW() - INTERVAL '34 days'),
    ('50000000-0000-0000-0000-000000000096', 'c0000000-0000-0000-0000-000000000049', 'd0000000-0000-0000-0000-000000000011',
     NOW() - INTERVAL '33 days', 'completed', 100, 299000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291027', 'paid', NOW() - INTERVAL '33 days'),
    ('50000000-0000-0000-0000-000000000097', 'c0000000-0000-0000-0000-000000000050', 'd0000000-0000-0000-0000-000000000013',
     NOW() - INTERVAL '32 days', 'enrolled', 45, 599000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892079', 'paid', NOW() - INTERVAL '32 days'),
    ('50000000-0000-0000-0000-000000000098', 'c0000000-0000-0000-0000-000000000051', 'd0000000-0000-0000-0000-000000000014',
     NOW() - INTERVAL '31 days', 'enrolled', 50, 490000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892080', 'paid', NOW() - INTERVAL '31 days'),
    ('50000000-0000-0000-0000-000000000099', 'c0000000-0000-0000-0000-000000000052', 'd0000000-0000-0000-0000-000000000015',
     NOW() - INTERVAL '30 days', 'enrolled', 30, 799000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291028', 'paid', NOW() - INTERVAL '30 days'),
    ('50000000-0000-0000-0000-000000000100', 'c0000000-0000-0000-0000-000000000053', 'd0000000-0000-0000-0000-000000000016',
     NOW() - INTERVAL '29 days', 'enrolled', 40, 690000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892081', 'paid', NOW() - INTERVAL '29 days'),
    ('50000000-0000-0000-0000-000000000101', 'c0000000-0000-0000-0000-000000000054', 'd0000000-0000-0000-0000-000000000017',
     NOW() - INTERVAL '28 days', 'completed', 100, 350000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892082', 'paid', NOW() - INTERVAL '28 days'),
    ('50000000-0000-0000-0000-000000000102', 'c0000000-0000-0000-0000-000000000055', 'd0000000-0000-0000-0000-000000000019',
     NOW() - INTERVAL '27 days', 'enrolled', 20, 550000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291029', 'paid', NOW() - INTERVAL '27 days'),
    ('50000000-0000-0000-0000-000000000103', 'c0000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000021',
     NOW() - INTERVAL '26 days', 'enrolled', 45, 890000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892083', 'paid', NOW() - INTERVAL '26 days'),
    ('50000000-0000-0000-0000-000000000104', 'c0000000-0000-0000-0000-000000000009', 'd0000000-0000-0000-0000-000000000022',
     NOW() - INTERVAL '25 days', 'enrolled', 35, 520000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892084', 'paid', NOW() - INTERVAL '25 days'),
    ('50000000-0000-0000-0000-000000000105', 'c0000000-0000-0000-0000-000000000010', 'd0000000-0000-0000-0000-000000000023',
     NOW() - INTERVAL '24 days', 'enrolled', 50, 480000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291030', 'paid', NOW() - INTERVAL '24 days'),
    ('50000000-0000-0000-0000-000000000106', 'c0000000-0000-0000-0000-000000000011', 'd0000000-0000-0000-0000-000000000024',
     NOW() - INTERVAL '23 days', 'enrolled', 15, 880000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892085', 'paid', NOW() - INTERVAL '23 days'),
    ('50000000-0000-0000-0000-000000000107', 'c0000000-0000-0000-0000-000000000012', 'd0000000-0000-0000-0000-000000000025',
     NOW() - INTERVAL '22 days', 'enrolled', 25, 650000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892086', 'paid', NOW() - INTERVAL '22 days'),
    ('50000000-0000-0000-0000-000000000108', 'c0000000-0000-0000-0000-000000000013', 'd0000000-0000-0000-0000-000000000026',
     NOW() - INTERVAL '21 days', 'enrolled', 40, 620000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291031', 'paid', NOW() - INTERVAL '21 days'),
    ('50000000-0000-0000-0000-000000000109', 'c0000000-0000-0000-0000-000000000014', 'd0000000-0000-0000-0000-000000000027',
     NOW() - INTERVAL '20 days', 'enrolled', 10, 1290000.00, 'b0000000-0000-0000-0000-000000000014', 'TXCC994808', 'paid', NOW() - INTERVAL '20 days'),
    ('50000000-0000-0000-0000-000000000110', 'c0000000-0000-0000-0000-000000000015', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '19 days', 'enrolled', 60, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892087', 'paid', NOW() - INTERVAL '19 days'),
    ('50000000-0000-0000-0000-000000000111', 'c0000000-0000-0000-0000-000000000018', 'd0000000-0000-0000-0000-000000000004',
     NOW() - INTERVAL '18 days', 'enrolled', 30, 1190000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892088', 'paid', NOW() - INTERVAL '18 days'),
    ('50000000-0000-0000-0000-000000000112', 'c0000000-0000-0000-0000-000000000019', 'd0000000-0000-0000-0000-000000000005',
     NOW() - INTERVAL '17 days', 'enrolled', 45, 990000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291032', 'paid', NOW() - INTERVAL '17 days'),
    ('50000000-0000-0000-0000-000000000113', 'c0000000-0000-0000-0000-000000000020', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '16 days', 'enrolled', 55, 620000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892089', 'paid', NOW() - INTERVAL '16 days'),
    ('50000000-0000-0000-0000-000000000114', 'c0000000-0000-0000-0000-000000000021', 'd0000000-0000-0000-0000-000000000012',
     NOW() - INTERVAL '16 days', 'enrolled', 20, 1490000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892090', 'paid', NOW() - INTERVAL '16 days'),
    ('50000000-0000-0000-0000-000000000115', 'c0000000-0000-0000-0000-000000000022', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '15 days', 'enrolled', 70, 890000.00, 'b0000000-0000-0000-0000-000000000014', 'TXCC994809', 'paid', NOW() - INTERVAL '15 days'),
    ('50000000-0000-0000-0000-000000000116', 'c0000000-0000-0000-0000-000000000023', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '15 days', 'enrolled', 80, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892091', 'paid', NOW() - INTERVAL '15 days'),
    ('50000000-0000-0000-0000-000000000117', 'c0000000-0000-0000-0000-000000000026', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '15 days', 'cancelled', 0, 890000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892092', 'refunded', NOW() - INTERVAL '15 days'),

    -- ═══════════════════════════════════════════════════════════════════
    -- THÁNG 6 (Tháng này / Gần đây: 14 - 0 ngày trước) — ~25 registrations
    -- Gồm nhiều giao dịch PAID + PENDING phục vụ Dashboard KPIs
    -- ═══════════════════════════════════════════════════════════════════
    ('50000000-0000-0000-0000-000000000118', 'c0000000-0000-0000-0000-000000000027', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '14 days', 'enrolled', 50, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892093', 'paid', NOW() - INTERVAL '14 days'),
    ('50000000-0000-0000-0000-000000000119', 'c0000000-0000-0000-0000-000000000028', 'd0000000-0000-0000-0000-000000000002',
     NOW() - INTERVAL '13 days', 'enrolled', 30, 550000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291033', 'paid', NOW() - INTERVAL '13 days'),
    ('50000000-0000-0000-0000-000000000120', 'c0000000-0000-0000-0000-000000000029', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '12 days', 'enrolled', 40, 620000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892094', 'paid', NOW() - INTERVAL '12 days'),
    ('50000000-0000-0000-0000-000000000121', 'c0000000-0000-0000-0000-000000000030', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '11 days', 'enrolled', 25, 890000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892095', 'paid', NOW() - INTERVAL '11 days'),
    ('50000000-0000-0000-0000-000000000122', 'c0000000-0000-0000-0000-000000000031', 'd0000000-0000-0000-0000-000000000010',
     NOW() - INTERVAL '10 days', 'enrolled', 70, 399000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291034', 'paid', NOW() - INTERVAL '10 days'),
    ('50000000-0000-0000-0000-000000000123', 'c0000000-0000-0000-0000-000000000032', 'd0000000-0000-0000-0000-000000000011',
     NOW() - INTERVAL '9 days', 'enrolled', 60, 299000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892096', 'paid', NOW() - INTERVAL '9 days'),
    ('50000000-0000-0000-0000-000000000124', 'c0000000-0000-0000-0000-000000000033', 'd0000000-0000-0000-0000-000000000013',
     NOW() - INTERVAL '8 days', 'enrolled', 35, 599000.00, 'b0000000-0000-0000-0000-000000000014', 'TXCC994810', 'paid', NOW() - INTERVAL '8 days'),
    ('50000000-0000-0000-0000-000000000125', 'c0000000-0000-0000-0000-000000000034', 'd0000000-0000-0000-0000-000000000014',
     NOW() - INTERVAL '7 days', 'enrolled', 45, 490000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892097', 'paid', NOW() - INTERVAL '7 days'),
    ('50000000-0000-0000-0000-000000000126', 'c0000000-0000-0000-0000-000000000035', 'd0000000-0000-0000-0000-000000000015',
     NOW() - INTERVAL '6 days', 'enrolled', 20, 799000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291035', 'paid', NOW() - INTERVAL '6 days'),
    ('50000000-0000-0000-0000-000000000127', 'c0000000-0000-0000-0000-000000000036', 'd0000000-0000-0000-0000-000000000016',
     NOW() - INTERVAL '5 days', 'enrolled', 30, 690000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892098', 'paid', NOW() - INTERVAL '5 days'),
    ('50000000-0000-0000-0000-000000000128', 'c0000000-0000-0000-0000-000000000037', 'd0000000-0000-0000-0000-000000000017',
     NOW() - INTERVAL '4 days', 'enrolled', 50, 350000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892099', 'paid', NOW() - INTERVAL '4 days'),
    ('50000000-0000-0000-0000-000000000129', 'c0000000-0000-0000-0000-000000000038', 'd0000000-0000-0000-0000-000000000019',
     NOW() - INTERVAL '3 days', 'enrolled', 15, 550000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291036', 'paid', NOW() - INTERVAL '3 days'),
    ('50000000-0000-0000-0000-000000000130', 'c0000000-0000-0000-0000-000000000039', 'd0000000-0000-0000-0000-000000000021',
     NOW() - INTERVAL '2 days', 'enrolled', 10, 890000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892100', 'paid', NOW() - INTERVAL '2 days'),
    ('50000000-0000-0000-0000-000000000131', 'c0000000-0000-0000-0000-000000000040', 'd0000000-0000-0000-0000-000000000022',
     NOW() - INTERVAL '1 days', 'enrolled', 5, 520000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892101', 'paid', NOW() - INTERVAL '1 days'),
    ('50000000-0000-0000-0000-000000000132', 'c0000000-0000-0000-0000-000000000041', 'd0000000-0000-0000-0000-000000000027',
     NOW() - INTERVAL '12 hours', 'enrolled', 0, 1290000.00, 'b0000000-0000-0000-0000-000000000013', 'SP38291037', 'paid', NOW() - INTERVAL '12 hours'),
    ('50000000-0000-0000-0000-000000000133', 'c0000000-0000-0000-0000-000000000042', 'd0000000-0000-0000-0000-000000000004',
     NOW() - INTERVAL '6 hours', 'enrolled', 0, 1190000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892102', 'paid', NOW() - INTERVAL '6 hours'),

    -- ── CÁC ĐƠN HÀNG PENDING (Chờ thanh toán) để hiển thị Dashboard pending metrics ──
    ('50000000-0000-0000-0000-000000000134', 'c0000000-0000-0000-0000-000000000043', 'd0000000-0000-0000-0000-000000000001',
     NOW() - INTERVAL '2 hours', 'enrolled', 0, 699000.00, 'b0000000-0000-0000-0000-000000000011', NULL, 'pending', NULL),
    ('50000000-0000-0000-0000-000000000135', 'c0000000-0000-0000-0000-000000000044', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '5 hours', 'enrolled', 0, 620000.00, 'b0000000-0000-0000-0000-000000000013', NULL, 'pending', NULL),
    ('50000000-0000-0000-0000-000000000136', 'c0000000-0000-0000-0000-000000000045', 'd0000000-0000-0000-0000-000000000003',
     NOW() - INTERVAL '8 hours', 'enrolled', 0, 890000.00, 'b0000000-0000-0000-0000-000000000011', NULL, 'pending', NULL),
    ('50000000-0000-0000-0000-000000000137', 'c0000000-0000-0000-0000-000000000046', 'd0000000-0000-0000-0000-000000000013',
     NOW() - INTERVAL '1 days', 'enrolled', 0, 599000.00, 'b0000000-0000-0000-0000-000000000013', NULL, 'pending', NULL),
    ('50000000-0000-0000-0000-000000000138', 'c0000000-0000-0000-0000-000000000047', 'd0000000-0000-0000-0000-000000000010',
     NOW() - INTERVAL '2 days', 'enrolled', 0, 399000.00, 'b0000000-0000-0000-0000-000000000011', NULL, 'pending', NULL),
    ('50000000-0000-0000-0000-000000000139', 'c0000000-0000-0000-0000-000000000048', 'd0000000-0000-0000-0000-000000000002',
     NOW() - INTERVAL '3 days', 'enrolled', 0, 550000.00, 'b0000000-0000-0000-0000-000000000011', NULL, 'pending', NULL),
    ('50000000-0000-0000-0000-000000000140', 'c0000000-0000-0000-0000-000000000049', 'd0000000-0000-0000-0000-000000000006',
     NOW() - INTERVAL '4 days', 'enrolled', 0, 620000.00, 'b0000000-0000-0000-0000-000000000013', NULL, 'pending', NULL)
ON CONFLICT (user_id, course_id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 11. SEED LEARNING_PROCESS (Tiến độ học từng bài của học viên)
-- ---------------------------------------------------------------------
INSERT INTO learning_process (id, registration_id, lesson_id, status, completed_at) VALUES
    -- Tiến độ của học viên An cho khóa Java Web (Hoàn thành cả 7 bài)
    ('60000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 'completed', NOW() - INTERVAL '140 days'),
    ('60000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000002', 'completed', NOW() - INTERVAL '135 days'),
    ('60000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000003', 'completed', NOW() - INTERVAL '130 days'),
    ('60000000-0000-0000-0000-000000000004', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000004', 'completed', NOW() - INTERVAL '125 days'),
    ('60000000-0000-0000-0000-000000000005', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000005', 'completed', NOW() - INTERVAL '120 days'),
    ('60000000-0000-0000-0000-000000000006', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000006', 'completed', NOW() - INTERVAL '115 days'),
    ('60000000-0000-0000-0000-000000000007', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000007', 'completed', NOW() - INTERVAL '110 days'),

    -- Tiến độ của học viên An cho khóa PostgreSQL (Hoàn thành bài 1, đang học bài 2)
    ('60000000-0000-0000-0000-000000000008', '50000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000008', 'completed', NOW() - INTERVAL '130 days'),
    ('60000000-0000-0000-0000-000000000009', '50000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000009', 'completed', NOW() - INTERVAL '120 days'),

    -- Tiến độ của Bình (Reg 3) cho Java Web
    ('60000000-0000-0000-0000-000000000010', '50000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000001', 'completed', NOW() - INTERVAL '140 days'),
    ('60000000-0000-0000-0000-000000000011', '50000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000002', 'completed', NOW() - INTERVAL '135 days'),
    ('60000000-0000-0000-0000-000000000012', '50000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000003', 'completed', NOW() - INTERVAL '130 days'),
    ('60000000-0000-0000-0000-000000000013', '50000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000004', 'completed', NOW() - INTERVAL '125 days'),
    ('60000000-0000-0000-0000-000000000014', '50000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000005', 'completed', NOW() - INTERVAL '120 days'),
    ('60000000-0000-0000-0000-000000000015', '50000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000006', 'completed', NOW() - INTERVAL '115 days'),
    ('60000000-0000-0000-0000-000000000016', '50000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000007', 'completed', NOW() - INTERVAL '110 days'),

    -- Tiến độ của Chi (Reg 4) cho Spring Boot
    ('60000000-0000-0000-0000-000000000017', '50000000-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000016', 'completed', NOW() - INTERVAL '130 days'),
    ('60000000-0000-0000-0000-000000000018', '50000000-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000017', 'completed', NOW() - INTERVAL '120 days'),

    -- Tiến độ của Dũng (Reg 5) cho React
    ('60000000-0000-0000-0000-000000000019', '50000000-0000-0000-0000-000000000005', 'f0000000-0000-0000-0000-000000000018', 'completed', NOW() - INTERVAL '130 days'),
    ('60000000-0000-0000-0000-000000000020', '50000000-0000-0000-0000-000000000005', 'f0000000-0000-0000-0000-000000000019', 'completed', NOW() - INTERVAL '120 days'),

    -- Tiến độ của Nam (Reg 10) cho Python
    ('60000000-0000-0000-0000-000000000021', '50000000-0000-0000-0000-000000000010', 'f0000000-0000-0000-0000-000000000010', 'completed', NOW() - INTERVAL '135 days'),
    ('60000000-0000-0000-0000-000000000022', '50000000-0000-0000-0000-000000000010', 'f0000000-0000-0000-0000-000000000011', 'completed', NOW() - INTERVAL '130 days'),
    ('60000000-0000-0000-0000-000000000023', '50000000-0000-0000-0000-000000000010', 'f0000000-0000-0000-0000-000000000012', 'completed', NOW() - INTERVAL '125 days'),

    -- Tiến độ của Bích (Reg 11) cho HTML/CSS
    ('60000000-0000-0000-0000-000000000024', '50000000-0000-0000-0000-000000000011', 'f0000000-0000-0000-0000-000000000013', 'completed', NOW() - INTERVAL '130 days'),
    ('60000000-0000-0000-0000-000000000025', '50000000-0000-0000-0000-000000000011', 'f0000000-0000-0000-0000-000000000014', 'completed', NOW() - INTERVAL '125 days'),
    ('60000000-0000-0000-0000-000000000026', '50000000-0000-0000-0000-000000000011', 'f0000000-0000-0000-0000-000000000015', 'completed', NOW() - INTERVAL '120 days'),

    -- Thêm các tiến độ đang học gần đây
    ('60000000-0000-0000-0000-000000000027', '50000000-0000-0000-0000-000000000075', 'f0000000-0000-0000-0000-000000000001', 'completed', NOW() - INTERVAL '30 days'),
    ('60000000-0000-0000-0000-000000000028', '50000000-0000-0000-0000-000000000075', 'f0000000-0000-0000-0000-000000000002', 'in_progress', NULL),
    ('60000000-0000-0000-0000-000000000029', '50000000-0000-0000-0000-000000000118', 'f0000000-0000-0000-0000-000000000001', 'completed', NOW() - INTERVAL '5 days'),
    ('60000000-0000-0000-0000-000000000030', '50000000-0000-0000-0000-000000000118', 'f0000000-0000-0000-0000-000000000002', 'in_progress', NULL)
ON CONFLICT (registration_id, lesson_id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 12. SEED QUIZ_SUBMISSION (Lượt nộp bài thi)
-- ---------------------------------------------------------------------
INSERT INTO quiz_submission (id, quiz_id, user_id, score, submitted_at, pass_status) VALUES
    ('70000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000008', 10.00, NOW() - INTERVAL '135 days', TRUE),
    ('70000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000008', 10.00, NOW() - INTERVAL '120 days', TRUE),
    ('70000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000009', 3.33, NOW() - INTERVAL '138 days', FALSE),
    ('70000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000009', 10.00, NOW() - INTERVAL '136 days', TRUE),
    ('70000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000018', 10.00, NOW() - INTERVAL '128 days', TRUE),
    ('70000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000020', 8.50, NOW() - INTERVAL '110 days', TRUE),
    ('70000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000008', 9.00, NOW() - INTERVAL '100 days', TRUE),
    ('70000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000022', 10.00, NOW() - INTERVAL '95 days', TRUE),
    ('70000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000026', 7.00, NOW() - INTERVAL '70 days', TRUE),
    ('70000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000026', 4.00, NOW() - INTERVAL '65 days', FALSE),
    ('70000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000026', 8.00, NOW() - INTERVAL '63 days', TRUE),
    ('70000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000028', 10.00, NOW() - INTERVAL '40 days', TRUE),
    ('70000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000038', 9.00, NOW() - INTERVAL '20 days', TRUE),
    ('70000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000031', 8.50, NOW() - INTERVAL '8 days', TRUE),
    ('70000000-0000-0000-0000-000000000015', '10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000027', 10.00, NOW() - INTERVAL '3 days', TRUE)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 13. SEED QUIZ_ANSWER
-- ---------------------------------------------------------------------
INSERT INTO quiz_answer (id, quiz_submission_id, quiz_question_id, question_option_id) VALUES
    ('80000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001'),
    ('80000000-0000-0000-0000-000000000002', '70000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000005'),
    ('80000000-0000-0000-0000-000000000003', '70000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000009'),
    ('80000000-0000-0000-0000-000000000004', '70000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002'),
    ('80000000-0000-0000-0000-000000000005', '70000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000006'),
    ('80000000-0000-0000-0000-000000000006', '70000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000009'),
    ('80000000-0000-0000-0000-000000000007', '70000000-0000-0000-0000-000000000005', '40000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000035'),
    ('80000000-0000-0000-0000-000000000008', '70000000-0000-0000-0000-000000000005', '40000000-0000-0000-0000-000000000010', '30000000-0000-0000-0000-000000000039')
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 14. SEED NOTIFICATION (Thông báo đa dạng người dùng)
-- ---------------------------------------------------------------------
INSERT INTO notification (id, user_id, type_id, content, status, sent_at) VALUES
    ('90000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000021',
     'Chào mừng bạn đến với hệ thống học tập trực tuyến LearnHub LMS!', 'read', NOW() - INTERVAL '150 days'),
    ('90000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000023',
     'Thanh toán thành công 699,000đ cho khóa học "Lập trình Java Web chuyên sâu". Mã GD: VNP14892019.', 'read', NOW() - INTERVAL '152 days'),
    ('90000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000024',
     'Chúc mừng bạn đã đạt điểm tuyệt đối 10.0/10 bài Quiz Vòng đời Servlet!', 'read', NOW() - INTERVAL '135 days'),
    ('90000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000009', 'b0000000-0000-0000-0000-000000000022',
     'Giảng viên Lê Văn Kiên vừa cập nhật tài liệu mới cho khóa học Java Web.', 'read', NOW() - INTERVAL '120 days'),
    ('90000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000022',
     'Khóa học "Lập trình Java Web" của bạn đã có hơn 20 học viên mới đăng ký trong tháng qua.', 'read', NOW() - INTERVAL '60 days'),
    ('90000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000021',
     'Báo cáo doanh thu tháng đã được tổng hợp xong và sẵn sàng xem trong bảng điều khiển.', 'read', NOW() - INTERVAL '30 days'),
    ('90000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000018', 'b0000000-0000-0000-0000-000000000023',
     'Payment successful for "Python for Beginners". Transaction: VNP14892025.', 'read', NOW() - INTERVAL '146 days'),
    ('90000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000022', 'b0000000-0000-0000-0000-000000000023',
     'Payment receipt: 399,000 VND confirmed via Credit Card TXCC994801.', 'read', NOW() - INTERVAL '149 days'),
    ('90000000-0000-0000-0000-000000000009', 'c0000000-0000-0000-0000-000000000023', 'b0000000-0000-0000-0000-000000000022',
     'New lesson added to Machine Learning & Data Science with Python.', 'unread', NOW() - INTERVAL '10 days'),
    ('90000000-0000-0000-0000-000000000010', 'c0000000-0000-0000-0000-000000000027', 'b0000000-0000-0000-0000-000000000023',
     'Thanh toán thành công 699,000đ cho khóa học Java Web qua VNPay.', 'unread', NOW() - INTERVAL '14 days'),
    ('90000000-0000-0000-0000-000000000011', 'c0000000-0000-0000-0000-000000000043', 'b0000000-0000-0000-0000-000000000023',
     'Đơn hàng khóa học Java Web đang chờ thanh toán. Vui lòng hoàn tất trong vòng 24h.', 'unread', NOW() - INTERVAL '2 hours'),
    ('90000000-0000-0000-0000-000000000012', 'c0000000-0000-0000-0000-000000000044', 'b0000000-0000-0000-0000-000000000023',
     'Đơn hàng khóa học React 18 đang chờ thanh toán.', 'unread', NOW() - INTERVAL '5 hours'),
    ('90000000-0000-0000-0000-000000000013', 'c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000021',
     'Cảnh báo: Có 7 đơn hàng đăng ký đang chờ xử lý thanh toán trên hệ thống.', 'unread', NOW() - INTERVAL '1 hours')
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 15. SEED AUDIT_LOG (Phục vụ trực tiếp Admin Dashboard 2.3)
-- Hiển thị các hành động gần đây của Admin, Manager, User, System
-- ---------------------------------------------------------------------
INSERT INTO audit_log (id, actor, action_type, description, status, created_at) VALUES
    ('a1000000-0000-0000-0000-000000000001', 'admin@learnhub.com',   'LOGIN_SUCCESS',  'Admin đăng nhập thành công từ IP 192.168.1.100',                      'SUCCESS', NOW() - INTERVAL '15 minutes'),
    ('a1000000-0000-0000-0000-000000000002', 'hacker@example.com',  'LOGIN_FAILED',   'Sai mật khẩu 5 lần liên tiếp – tài khoản tạm khóa',                 'FAILED',  NOW() - INTERVAL '45 minutes'),
    ('a1000000-0000-0000-0000-000000000003', 'admin@learnhub.com',   'ROLE_UPDATE',    'Cập nhật vai trò người dùng nguyenhoa@gmail.com → Student',          'SUCCESS', NOW() - INTERVAL '2 hours'),
    ('a1000000-0000-0000-0000-000000000004', 'System',              'JOB_EXEC',       'Cron job: tổng hợp báo cáo doanh thu ngày hoàn thành',              'SUCCESS', NOW() - INTERVAL '4 hours'),
    ('a1000000-0000-0000-0000-000000000005', 'manager@learnhub.com', 'COURSE_PUBLISH', 'Khóa học "Next.js 14 & Full-Stack React" được phát hành chính thức', 'SUCCESS', NOW() - INTERVAL '6 hours'),
    ('a1000000-0000-0000-0000-000000000006', 'System',              'LOGIN_FAILED',   'Phát hiện IP 203.0.113.42 thử đăng nhập brute-force',                'WARNING', NOW() - INTERVAL '10 hours'),
    ('a1000000-0000-0000-0000-000000000007', 'admin@learnhub.com',   'USER_BAN',       'Tài khoản spammer@mailinator.com bị khóa do gửi thư rác',            'SUCCESS', NOW() - INTERVAL '18 hours'),
    ('a1000000-0000-0000-0000-000000000008', 'System',              'PAYMENT_SYNC',   'Đồng bộ giao dịch tự động SePay VietQR hoàn thành: 5 giao dịch',     'SUCCESS', NOW() - INTERVAL '1 day'),
    ('a1000000-0000-0000-0000-000000000009', 'manager2@learnhub.com','COURSE_UPDATE',  'Cập nhật nội dung giáo trình khóa học Spring Boot 3 & Microservices','SUCCESS', NOW() - INTERVAL '1 day 4 hours'),
    ('a1000000-0000-0000-0000-000000000010', 'System',              'JOB_EXEC',       'Sao lưu định kỳ CSDL PostgreSQL hoàn tất (kích thước: 125MB)',      'SUCCESS', NOW() - INTERVAL '1 day 12 hours'),
    ('a1000000-0000-0000-0000-000000000011', 'admin@learnhub.com',   'SETTING_UPDATE', 'Kích hoạt phương thức thanh toán VNPay Sandbox',                     'SUCCESS', NOW() - INTERVAL '2 days'),
    ('a1000000-0000-0000-0000-000000000012', 'david.park@gmail.com','LOGIN_SUCCESS',  'Người dùng David Park đăng nhập qua Google OAuth',                   'SUCCESS', NOW() - INTERVAL '2 days 6 hours'),
    ('a1000000-0000-0000-0000-000000000013', 'admin@learnhub.com',   'USER_CREATE',    'Tạo tài khoản Giảng viên mới: David Anderson (ROLE_EXPERT)',         'SUCCESS', NOW() - INTERVAL '3 days'),
    ('a1000000-0000-0000-0000-000000000014', 'System',              'PAYMENT_FAIL',   'Giao dịch VNPay #14892029 bị hủy do học viên không hoàn tất OTP',    'WARNING', NOW() - INTERVAL '3 days 8 hours'),
    ('a1000000-0000-0000-0000-000000000015', 'manager@learnhub.com', 'COURSE_PUBLISH', 'Phát hành khóa học "Linux Administration & Shell Scripting"',       'SUCCESS', NOW() - INTERVAL '4 days'),
    ('a1000000-0000-0000-0000-000000000016', 'admin@learnhub.com',   'LOGIN_SUCCESS',  'Admin đăng nhập từ IP văn phòng 10.0.0.15',                          'SUCCESS', NOW() - INTERVAL '4 days 12 hours'),
    ('a1000000-0000-0000-0000-000000000017', 'System',              'JOB_EXEC',       'Cron job: Gửi email nhắc nhở học viên 7 ngày chưa đăng nhập',        'SUCCESS', NOW() - INTERVAL '5 days'),
    ('a1000000-0000-0000-0000-000000000018', 'manager2@learnhub.com','COURSE_ARCHIVE', 'Chuyển khóa học GraphQL & Apollo sang trạng thái archived',          'SUCCESS', NOW() - INTERVAL '6 days'),
    ('a1000000-0000-0000-0000-000000000019', 'System',              'LOGIN_FAILED',   'IP 103.145.4.12 đăng nhập thất bại với tài khoản root',             'FAILED',  NOW() - INTERVAL '7 days'),
    ('a1000000-0000-0000-0000-000000000020', 'admin@learnhub.com',   'SETTING_UPDATE', 'Cập nhật cấu hình email SMTP gửi thông báo hệ thống',                'SUCCESS', NOW() - INTERVAL '8 days'),
    ('a1000000-0000-0000-0000-000000000021', 'expert@learnhub.com',  'QUIZ_CREATE',    'Giảng viên Lê Văn Kiên tạo mới bài Quiz Chương 2 MVC',               'SUCCESS', NOW() - INTERVAL '10 days'),
    ('a1000000-0000-0000-0000-000000000022', 'System',              'JOB_EXEC',       'Kiểm tra tính toàn vẹn dữ liệu hệ thống (Data Integrity Check): OK', 'SUCCESS', NOW() - INTERVAL '12 days'),
    ('a1000000-0000-0000-0000-000000000023', 'admin@learnhub.com',   'USER_STATUS',    'Kích hoạt lại tài khoản ngovan.tung@learnhub.com',                   'SUCCESS', NOW() - INTERVAL '14 days'),
    ('a1000000-0000-0000-0000-000000000024', 'System',              'JOB_EXEC',       'Cron job: Tổng kết doanh thu tháng trước hoàn tất: 62,450,000 VND',  'SUCCESS', NOW() - INTERVAL '30 days'),
    ('a1000000-0000-0000-0000-000000000025', 'manager@learnhub.com', 'COURSE_PUBLISH', 'Phát hành khóa học "Kotlin for Android Development"',               'SUCCESS', NOW() - INTERVAL '32 days'),
    ('a1000000-0000-0000-0000-000000000026', 'admin@learnhub.com',   'ROLE_UPDATE',    'Gán quyền Giảng viên cho sarah.kim@learnhub.com',                    'SUCCESS', NOW() - INTERVAL '35 days'),
    ('a1000000-0000-0000-0000-000000000027', 'System',              'SECURITY_AUDIT', 'Quét lỗ hổng định kỳ hệ thống: 0 lỗ hổng nghiêm trọng',              'SUCCESS', NOW() - INTERVAL '40 days'),
    ('a1000000-0000-0000-0000-000000000028', 'manager2@learnhub.com','CATEGORY_ADD',   'Thêm danh mục mới: Mobile & Cross-platform Development',              'SUCCESS', NOW() - INTERVAL '45 days'),
    ('a1000000-0000-0000-0000-000000000029', 'john.smith@gmail.com', 'LOGIN_SUCCESS',  'Học viên John Smith đăng nhập lần đầu tiên',                         'SUCCESS', NOW() - INTERVAL '50 days'),
    ('a1000000-0000-0000-0000-000000000030', 'System',              'BACKUP_FAIL',    'Cảnh báo: Tải bộ nhớ đệm Redis vượt ngưỡng 80% (đã tự dọn dẹp)',      'WARNING', NOW() - INTERVAL '55 days'),
    ('a1000000-0000-0000-0000-000000000031', 'admin@learnhub.com',   'SETTING_UPDATE', 'Cập nhật chính sách hoàn tiền khóa học 7 ngày',                      'SUCCESS', NOW() - INTERVAL '60 days'),
    ('a1000000-0000-0000-0000-000000000032', 'expert2@learnhub.com', 'LESSON_CREATE',  'Thêm 3 bài học mới vào khóa Thiết kế UI/UX',                        'SUCCESS', NOW() - INTERVAL '70 days'),
    ('a1000000-0000-0000-0000-000000000033', 'admin@learnhub.com',   'USER_BAN',       'Khóa tài khoản vi phạm chính sách spam2026@temp.com',                'SUCCESS', NOW() - INTERVAL '80 days'),
    ('a1000000-0000-0000-0000-000000000034', 'System',              'JOB_EXEC',       'Cron job dọn dẹp phiên đăng nhập hết hạn hoàn tất',                  'SUCCESS', NOW() - INTERVAL '90 days'),
    ('a1000000-0000-0000-0000-000000000035', 'admin@learnhub.com',   'SYSTEM_INIT',    'Cấu hình thông số ban đầu nền tảng LearnHub LMS 2.0',                'SUCCESS', NOW() - INTERVAL '150 days')
ON CONFLICT (id) DO NOTHING;
