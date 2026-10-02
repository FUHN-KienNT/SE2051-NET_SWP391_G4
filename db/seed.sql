-- =====================================================================
-- LEARNHUB DATABASE SEED SCRIPT
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. SEED SETTING (Role, Category, Payment Method, Notification Type)
-- ---------------------------------------------------------------------
INSERT INTO setting (id, type, code, name, description, status, sort_order) VALUES
    -- Roles (Mã code chuẩn theo AuthorizationFilter & UserService)
    ('a0000000-0000-0000-0000-000000000001', 'role', 'ROLE_ADMIN',   'Administrator',        'Toàn quyền quản trị hệ thống, người dùng và phân quyền', TRUE, 1),
    ('a0000000-0000-0000-0000-000000000002', 'role', 'ROLE_MANAGER', 'Manager',              'Quản lý danh mục, khóa học, phê duyệt nội dung và doanh thu', TRUE, 2),
    ('a0000000-0000-0000-0000-000000000003', 'role', 'ROLE_EXPERT',  'Expert / Instructor',  'Chuyên gia biên soạn bài giảng, ra đề thi và giải đáp thắc mắc', TRUE, 3),
    ('a0000000-0000-0000-0000-000000000004', 'role', 'ROLE_STUDENT', 'Student',              'Học viên tham gia các khóa học và làm bài tập đánh giá', TRUE, 4),

    -- Categories
    ('b0000000-0000-0000-0000-000000000001', 'category', 'web_dev',     'Phát triển Web Fullstack',   'Khóa học HTML, CSS, JavaScript, React, Java Web, Spring Boot', TRUE, 1),
    ('b0000000-0000-0000-0000-000000000002', 'category', 'database',    'Cơ sở dữ liệu & Tối ưu hóa', 'PostgreSQL, MySQL, Database Design, Indexing và Query Tuning', TRUE, 2),
    ('b0000000-0000-0000-0000-000000000003', 'category', 'programming', 'Lập trình Cốt lõi',         'OOP, Cấu trúc dữ liệu & Giải thuật, Java Core, Python', TRUE, 3),
    ('b0000000-0000-0000-0000-000000000004', 'category', 'ai_data',     'Trí tuệ nhân tạo & Data',    'Machine Learning, Deep Learning, Phân tích dữ liệu với Python', TRUE, 4),
    ('b0000000-0000-0000-0000-000000000005', 'category', 'devops',      'DevOps & Điện toán Đám mây', 'Docker, Kubernetes, CI/CD Pipeline, AWS, Linux System', TRUE, 5),
    ('b0000000-0000-0000-0000-000000000006', 'category', 'mobile',      'Lập trình Mobile',           'Flutter, React Native, iOS Swift và Android Kotlin', TRUE, 6),

    -- Payment Methods (Hệ thống hỗ trợ 2 cổng chính: VNPAY và SePay)
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
-- 2. SEED USER
-- Mật khẩu hash bằng BCrypt tương ứng với chính Username của tài khoản:
-- admin    -> admin
-- manager  -> manager (manager2 -> manager2)
-- expert   -> expert (expert2 -> expert2, ...)
-- student  -> student (student2 -> student2, ...)
-- ---------------------------------------------------------------------
-- Đảm bảo 4 Roles bắt buộc đã tồn tại trong bảng setting
INSERT INTO setting (id, type, code, name, description, status, sort_order) VALUES
    ('a0000000-0000-0000-0000-000000000001', 'role', 'ROLE_ADMIN',   'Administrator',        'Toàn quyền quản trị hệ thống, người dùng và phân quyền', TRUE, 1),
    ('a0000000-0000-0000-0000-000000000002', 'role', 'ROLE_MANAGER', 'Manager',              'Quản lý danh mục, khóa học, phê duyệt nội dung và doanh thu', TRUE, 2),
    ('a0000000-0000-0000-0000-000000000003', 'role', 'ROLE_EXPERT',  'Expert / Instructor',  'Chuyên gia biên soạn bài giảng, ra đề thi và giải đáp thắc mắc', TRUE, 3),
    ('a0000000-0000-0000-0000-000000000004', 'role', 'ROLE_STUDENT', 'Student',              'Học viên tham gia các khóa học và làm bài tập đánh giá', TRUE, 4)
ON CONFLICT (type, code) DO NOTHING;

INSERT INTO "user" (id, username, email, password, role_id, status) VALUES
    -- 1 Admin (admin / admin)
    ('c0000000-0000-0000-0000-000000000001', 'admin',     'admin@learnhub.com',    '$2a$10$Sdt.YtiEjO5Kr5V.oEIs/uyme2cDi65wo/sHUL5J546JTjZpnWVRC', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_ADMIN' LIMIT 1), 'active'),

    -- 2 Managers (manager / manager, manager2 / manager2)
    ('c0000000-0000-0000-0000-000000000002', 'manager',   'manager@learnhub.com',  '$2a$10$AQYzTX/07vmJ11M8kVevCeG09zAFD3Y6EVCkdIrIcsnHuJ9O0fylK', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_MANAGER' LIMIT 1), 'active'),
    ('c0000000-0000-0000-0000-000000000003', 'manager2',  'manager2@learnhub.com', '$2a$10$WkWgNDWJ/YkDYCpcHV7lbuVcuMCEeH.CL6fe0RVPyZnt1bsTRJZJ.', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_MANAGER' LIMIT 1), 'active'),

    -- 4 Experts / Instructors (expert / expert, expert2 / expert2, ...)
    ('c0000000-0000-0000-0000-000000000004', 'expert',    'expert@learnhub.com',   '$2a$10$Amt4fLTJ2n2n/h.GEXf3lu9pro6uozD8si3FknTwDiBxJ0Q6lmGfK', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_EXPERT' LIMIT 1), 'active'),
    ('c0000000-0000-0000-0000-000000000005', 'expert2',   'expert2@learnhub.com',  '$2a$10$GahzmDxReLJIg0dSmHc0ius8inJJW6Yx4tM0uX0vjOiVPNA3/ClxG', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_EXPERT' LIMIT 1), 'active'),
    ('c0000000-0000-0000-0000-000000000006', 'expert3',   'expert3@learnhub.com',  '$2a$10$3zIF/X.cI5PGiT/RxG8XveEmTZw9OCTwri0rnUkXuUaT9vuLWaCTO', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_EXPERT' LIMIT 1), 'active'),
    ('c0000000-0000-0000-0000-000000000007', 'expert4',   'expert4@learnhub.com',  '$2a$10$ll2khekvXIiqgp4NsaFQRObxp3/LoHO99rkhF6hVpxRxuvezJPVC.', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_EXPERT' LIMIT 1), 'active'),

    -- 8 Students (student / student, student2 / student2, ...)
    ('c0000000-0000-0000-0000-000000000008', 'student',   'student@learnhub.com',  '$2a$10$ujsHGpMf9v0mE/QQtFLgGuVuhBBGo9CupXp4Dn6tsBdjyFSMncGvO', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_STUDENT' LIMIT 1), 'active'),
    ('c0000000-0000-0000-0000-000000000009', 'student2',  'student2@learnhub.com', '$2a$10$kG6.9HLENo9arUiveoQu.uBED657ES5Cx5jE1Nzscf8B1bT.CbIfK', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_STUDENT' LIMIT 1), 'active'),
    ('c0000000-0000-0000-0000-000000000010', 'student3',  'student3@learnhub.com', '$2a$10$IncS/j/.pNruMXdFxbNhxub/HA.5bg6n9s7VhMjrE/pmxLcz6y3zy', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_STUDENT' LIMIT 1), 'active'),
    ('c0000000-0000-0000-0000-000000000011', 'student4',  'student4@learnhub.com', '$2a$10$uvdiL6YTHA1/B1bNSh84uuNgImBgGnExPgFwPV1IyJFAASlB90aBi', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_STUDENT' LIMIT 1), 'active'),
    ('c0000000-0000-0000-0000-000000000012', 'student5',  'student5@learnhub.com', '$2a$10$Mnx9fQz.gNa2Q/hCCz5zmenXDlYF.if3.7TaWqVOejUNx95rELkxK', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_STUDENT' LIMIT 1), 'active'),
    ('c0000000-0000-0000-0000-000000000013', 'student6',  'student6@learnhub.com', '$2a$10$0edRofpWrPXF85O8WGAeaub8RB9/AxWawKEj71pPHXDjisxqLOZ.W', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_STUDENT' LIMIT 1), 'active'),
    ('c0000000-0000-0000-0000-000000000014', 'student7',  'student7@learnhub.com', '$2a$10$TR13q4kGjZg1nqOOjTCLB.21DvaEz8YPUa8oi3qI.3SBxzNpUfg2S', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_STUDENT' LIMIT 1), 'active'),
    ('c0000000-0000-0000-0000-000000000015', 'student8',  'student8@learnhub.com', '$2a$10$qIrXEEG4/EdxpCYiOLAkp.GeeA272AZnh5VFgUNZoihL/yCjuDwKG', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_STUDENT' LIMIT 1), 'active'),

    -- Inactive & Banned test accounts
    ('c0000000-0000-0000-0000-000000000016', 'inactive',  'inactive@learnhub.com', '$2a$10$eu4KnFl9QzuD.jwM6Q58O.l/7fIyFCuieKJCC.69WiUnZEHsm9ZIC', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_STUDENT' LIMIT 1), 'inactive'),
    ('c0000000-0000-0000-0000-000000000017', 'banned',    'banned@learnhub.com',   '$2a$10$v1OxBlBlLquJKeBXy7ydROU.3jayw6i9JUYxiiYEbVm.7NtNpI08i', (SELECT id FROM setting WHERE type = 'role' AND code = 'ROLE_STUDENT' LIMIT 1), 'banned')
ON CONFLICT (id) DO UPDATE SET 
    username = EXCLUDED.username,
    email = EXCLUDED.email,
    password = EXCLUDED.password,
    role_id = EXCLUDED.role_id,
    status = EXCLUDED.status;


-- ---------------------------------------------------------------------
-- 3. SEED COURSE
-- ---------------------------------------------------------------------
INSERT INTO course (id, title, description, price, thumbnail_url, status, category_id, created_by, expert_id) VALUES
    ('d0000000-0000-0000-0000-000000000001', 
     'Lập trình Java Web chuyên sâu với Jakarta EE, Servlet, JSP & MVC', 
     'Khóa học thực chiến toàn diện giúp bạn làm chủ mô hình MVC, Jakarta Servlet 6.0, JSP/JSTL, HikariCP Connection Pool, PostgreSQL, Authentication Filter và tích hợp cổng thanh toán VNPay.', 
     699000.00, 
     'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&auto=format&fit=crop', 
     'published', 
     'b0000000-0000-0000-0000-000000000001', 
     'c0000000-0000-0000-0000-000000000002', 
     'c0000000-0000-0000-0000-000000000004'),

    ('d0000000-0000-0000-0000-000000000002', 
     'Làm chủ PostgreSQL: Thiết kế CSDL & Tối ưu hóa Truy vấn', 
     'Khám phá chuyên sâu kiến trúc PostgreSQL, kỹ thuật đánh Index B-tree/GIN, đọc và phân tích EXPLAIN ANALYZE, tối ưu Transaction, Partitioning và viết Stored Procedures.', 
     550000.00, 
     'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=800&auto=format&fit=crop', 
     'published', 
     'b0000000-0000-0000-0000-000000000002', 
     'c0000000-0000-0000-0000-000000000002', 
     'c0000000-0000-0000-0000-000000000006'),

    ('d0000000-0000-0000-0000-000000000003', 
     'Spring Boot 3 & Microservices: Xây dựng REST API chuẩn Doanh nghiệp', 
     'Học cách thiết kế hệ sinh thái Microservices bảo mật với Spring Boot 3, Spring Security 6, JWT, Spring Data JPA, Apache Kafka, OpenFeign và Docker containers.', 
     890000.00, 
     'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&auto=format&fit=crop', 
     'published', 
     'b0000000-0000-0000-0000-000000000003', 
     'c0000000-0000-0000-0000-000000000003', 
     'c0000000-0000-0000-0000-000000000005'),

    ('d0000000-0000-0000-0000-000000000004', 
     'Machine Learning & Phân tích Dữ liệu thực chiến với Python', 
     'Từ tiền xử lý dữ liệu với Pandas, NumPy đến huấn luyện các mô hình học máy Scikit-Learn, XGBoost, trực quan hóa dữ liệu và triển khai model ra ứng dụng thực tế.', 
     1190000.00, 
     'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=800&auto=format&fit=crop', 
     'published', 
     'b0000000-0000-0000-0000-000000000004', 
     'c0000000-0000-0000-0000-000000000002', 
     'c0000000-0000-0000-0000-000000000006'),

    ('d0000000-0000-0000-0000-000000000005', 
     'DevOps Toàn diện: Docker, Kubernetes, CI/CD Pipeline & AWS', 
     'Thực hành đóng gói container ứng dụng, triển khai cluster Kubernetes (K8s), viết pipeline tự động hóa CI/CD với GitHub Actions và giám sát hệ thống với Prometheus & Grafana.', 
     990000.00, 
     'https://images.unsplash.com/photo-1618401471353-b98afee0b2eb?w=800&auto=format&fit=crop', 
     'published', 
     'b0000000-0000-0000-0000-000000000005', 
     'c0000000-0000-0000-0000-000000000003', 
     'c0000000-0000-0000-0000-000000000007'),

    ('d0000000-0000-0000-0000-000000000006', 
     'Frontend Hiện đại với React 18, TypeScript & Tailwind CSS', 
     'Làm chủ tư duy Component-driven, React Hooks tùy chỉnh, Context API, Redux Toolkit, React Router v6, tối ưu hiệu năng web và xây dựng giao diện chuẩn thẩm mỹ.', 
     620000.00, 
     'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=800&auto=format&fit=crop', 
     'published', 
     'b0000000-0000-0000-0000-000000000001', 
     'c0000000-0000-0000-0000-000000000002', 
     'c0000000-0000-0000-0000-000000000004'),

    ('d0000000-0000-0000-0000-000000000007', 
     'Lập trình Ứng dụng Di động Đa nền tảng với Flutter & Dart', 
     'Xây dựng các ứng dụng mobile mượt mà 60fps trên cả Android & iOS, áp dụng kiến trúc Clean Architecture, BLoC pattern, tích hợp Firebase và thanh toán In-App Purchase.', 
     750000.00, 
     'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800&auto=format&fit=crop', 
     'published', 
     'b0000000-0000-0000-0000-000000000006', 
     'c0000000-0000-0000-0000-000000000003', 
     'c0000000-0000-0000-0000-000000000005'),

    ('d0000000-0000-0000-0000-000000000008', 
     'Cấu trúc Dữ liệu & Giải thuật cho Phỏng vấn Kỹ sư Phần mềm', 
     'Tổng hợp các bài toán thuật toán kinh điển từ LeetCode: Hai con trỏ, Sliding Window, Đồ thị BFS/DFS, Cây nhị phân, Quy hoạch động và kỹ thuật tính độ phức tạp thời gian/không gian.', 
     450000.00, 
     'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=800&auto=format&fit=crop', 
     'published', 
     'b0000000-0000-0000-0000-000000000003', 
     'c0000000-0000-0000-0000-000000000002', 
     'c0000000-0000-0000-0000-000000000004'),

    ('d0000000-0000-0000-0000-000000000009', 
     'An toàn Thông tin Web & Kiểm thử Xâm nhập (Web Pentest)', 
     'Khám phá cơ chế tấn công và phương pháp phòng chống các lỗ hổng OWASP Top 10: SQL Injection, XSS, CSRF, IDOR, SSRF và thực hành trên lab thực nghiệm.', 
     850000.00, 
     'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800&auto=format&fit=crop', 
     'draft', 
     'b0000000-0000-0000-0000-000000000003', 
     'c0000000-0000-0000-0000-000000000003', 
     'c0000000-0000-0000-0000-000000000007')
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
    ('e0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000002', 'Chương 1: Kiến trúc Lưu trữ & DDL/DML Nâng cao', 'Cấu trúc table, page, heap storage, kiểu dữ liệu UUID, JSONB và tối ưu hóa câu lệnh SELECT.', 1),
    ('e0000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000002', 'Chương 2: Đánh Chỉ mục Indexing & Tối ưu Execution Plan', 'Chiến lược đánh index B-Tree, GIN, Partial Index và đọc EXPLAIN (ANALYZE, BUFFERS).', 2),

    -- Modules cho Course 3 (Spring Boot)
    ('e0000000-0000-0000-0000-000000000006', 'd0000000-0000-0000-0000-000000000003', 'Chương 1: Khởi tạo Spring Boot & Kiến trúc REST API', 'Tìm hiểu Inversion of Control (IoC), Dependency Injection (DI) và thiết kế RESTful endpoints.', 1),
    ('e0000000-0000-0000-0000-000000000007', 'd0000000-0000-0000-0000-000000000003', 'Chương 2: Spring Data JPA & Quản lý Giao dịch Transaction', 'Tương tác CSDL qua Hibernate/JPA, Repository pattern và Transaction Isolation Level.', 2),

    -- Modules cho Course 6 (React)
    ('e0000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000006', 'Chương 1: React Core Concepts & Hooks Căn bản', 'Tìm hiểu JSX, Virtual DOM, useState, useEffect và tư duy State Lifting.', 1),
    ('e0000000-0000-0000-0000-000000000009', 'd0000000-0000-0000-0000-000000000006', 'Chương 2: Quản lý State Nâng cao & Gọi API REST', 'Làm chủ Context API kết hợp useReducer, Axios interceptors và xử lý Error boundary.', 2)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 5. SEED LESSON (Bài học)
-- ---------------------------------------------------------------------
INSERT INTO lesson (id, module_id, title, content, order_index) VALUES
    -- Lessons cho Module 1 (Course 1)
    ('f0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 
     'Bài 1: Giới thiệu Kiến trúc Web & Jakarta Servlet 6.0', 
     '<h3>Nội dung bài học:</h3><p>Trong bài học này chúng ta tìm hiểu kiến trúc Client-Server, cách Tomcat 10.1 tiếp nhận và điều phối HTTP Request qua Servlet Container.</p><ul><li>Vòng đời của Servlet: init(), service(), destroy()</li><li>Phân biệt GET vs POST</li><li>Cấu hình @WebServlet annotation</li></ul>', 1),

    ('f0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 
     'Bài 2: HttpServletRequest, HttpServletResponse & RequestDispatcher', 
     '<h3>Đọc tham số và gửi phản hồi:</h3><p>Cách lấy tham số qua <code>req.getParameter()</code>, forward yêu cầu tới trang JSP và chuyển hướng bằng <code>resp.sendRedirect()</code>.</p>', 2),

    ('f0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000001', 
     'Bài 3: Tích hợp HikariCP Connection Pool kết nối PostgreSQL', 
     '<h3>Tối ưu hóa kết nối CSDL:</h3><p>Cấu hình connection pool hiệu năng cao HikariCP thay thế cho việc mở Connection thủ công gây nghẽn tài nguyên server.</p>', 3),

    -- Lessons cho Module 2 (Course 1)
    ('f0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000002', 
     'Bài 4: Giới thiệu JSP & Expression Language (EL)', 
     '<p>Cú pháp Expression Language <code>${user.username}</code> giúp truy cập thuộc tính trong requestScope, sessionScope mà không cần nhúng mã scriptlet Java phức tạp.</p>', 1),

    ('f0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000002', 
     'Bài 5: JSTL Core Tags & Render Danh sách Động', 
     '<p>Sử dụng các thẻ <code>&lt;c:forEach&gt;</code>, <code>&lt;c:if&gt;</code>, <code>&lt;c:choose&gt;</code> để duyệt danh sách khóa học và hiển thị dữ liệu bảng linh hoạt.</p>', 2),

    -- Lessons cho Module 3 (Course 1)
    ('f0000000-0000-0000-0000-000000000006', 'e0000000-0000-0000-0000-000000000003', 
     'Bài 6: Quản lý Phiên Đăng nhập với HttpSession', 
     '<p>Tạo session khi đăng nhập thành công, lưu thông tin User và vô hiệu hóa session (Logout) an toàn với <code>session.invalidate()</code>.</p>', 1),

    ('f0000000-0000-0000-0000-000000000007', 'e0000000-0000-0000-0000-000000000003', 
     'Bài 7: Xây dựng Authorization Filter & Phân quyền RBAC', 
     '<p>Cách cấu hình Filter chặn các URL <code>/admin/*</code>, <code>/expert/*</code> và kiểm tra quyền tương ứng dựa vào Role Code.</p>', 2),

    -- Lessons cho Module 1 (Course 2 - PostgreSQL)
    ('f0000000-0000-0000-0000-000000000008', 'e0000000-0000-0000-0000-000000000004', 
     'Bài 1: Kiến trúc Lưu trữ PostgreSQL & MVCC', 
     '<p>Khái niệm Multi-Version Concurrency Control (MVCC), Vacuuming và cách PostgreSQL xử lý ghi dữ liệu đồng thời không gây lock đọc.</p>', 1),

    ('f0000000-0000-0000-0000-000000000009', 'e0000000-0000-0000-0000-000000000005', 
     'Bài 2: Tối ưu Indexing B-Tree & Phân tích Query với EXPLAIN', 
     '<p>Cách nhận biết Sequential Scan, Index Scan, Bitmap Index Scan và chiến lược tạo Composite Index tối ưu cho mệnh đề WHERE và ORDER BY.</p>', 1)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 6. SEED QUIZ (Bài thi trắc nghiệm)
-- ---------------------------------------------------------------------
INSERT INTO quiz (id, module_id, title, time_limit, pass_score) VALUES
    ('10000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'Quiz Ôn tập: Vòng đời Servlet & Xử lý HTTP Request', 15, 5.0),
    ('10000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'Quiz Đánh giá: JSP, JSTL Core Tags & Mô hình MVC', 20, 6.0),
    ('10000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000003', 'Quiz Bảo mật: Session, Cookie & Filter Authorization', 20, 7.0),
    ('10000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000005', 'Quiz Chuyên gia: Đánh Index & Đọc EXPLAIN PostgreSQL', 25, 8.0)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 7. SEED QUESTION (Ngân hàng câu hỏi trắc nghiệm)
-- ---------------------------------------------------------------------
INSERT INTO question (id, content, type) VALUES
    ('20000000-0000-0000-0000-000000000001', 'Phương thức nào trong vòng đời của Servlet chỉ được gọi đúng MỘT lần duy nhất khi Servlet được khởi tạo?', 'single_choice'),
    ('20000000-0000-0000-0000-000000000002', 'Sự khác biệt chính giữa RequestDispatcher.forward() và HttpServletResponse.sendRedirect() là gì?', 'single_choice'),
    ('20000000-0000-0000-0000-000000000003', 'Trong Jakarta EE 10, package nào thay thế hoàn toàn cho package cũ "javax.servlet"?', 'single_choice'),
    ('20000000-0000-0000-0000-000000000004', 'Thẻ JSTL nào sau đây được sử dụng để duyệt qua một Collection hoặc mảng trong JSP?', 'single_choice'),
    ('20000000-0000-0000-0000-000000000005', 'Phương thức nào được dùng để hủy bỏ hoàn toàn một HttpSession khi người dùng đăng xuất?', 'single_choice'),
    ('20000000-0000-0000-0000-000000000006', 'Trong kiến trúc MVC, tầng Controller đảm nhiệm vai trò gì?', 'single_choice'),
    ('20000000-0000-0000-0000-000000000007', 'Loại Index mặc định trong PostgreSQL khi bạn tạo khóa chính (Primary Key) là gì?', 'single_choice'),
    ('20000000-0000-0000-0000-000000000008', 'Lệnh nào trong PostgreSQL cho phép xem thời gian thực tế thực thi câu lệnh SQL cùng với kế hoạch truy vấn?', 'single_choice')
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 8. SEED QUESTION_OPTION (Các lựa chọn đáp án)
-- ---------------------------------------------------------------------
INSERT INTO question_option (id, question_id, option_text, is_correct) VALUES
    -- Câu 1
    ('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'init(ServletConfig config)', TRUE),
    ('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'service(ServletRequest req, ServletResponse res)', FALSE),
    ('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', 'doGet(HttpServletRequest req, HttpServletResponse res)', FALSE),
    ('30000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000001', 'destroy()', FALSE),

    -- Câu 2
    ('30000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002', 'forward() thực hiện ở phía Server và giữ nguyên URL; sendRedirect() gửi mã chuyển hướng về Browser tạo request mới', TRUE),
    ('30000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000002', 'forward() gửi mã HTTP 302 về trình duyệt; sendRedirect() không thay đổi URL', FALSE),
    ('30000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000002', 'Cả hai phương thức đều thực hiện hoàn toàn ở Client', FALSE),
    ('30000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000002', 'forward() không thể truyền thuộc tính trong HttpServletRequest', FALSE),

    -- Câu 3
    ('30000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000003', 'jakarta.servlet', TRUE),
    ('30000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000003', 'org.apache.servlet', FALSE),
    ('30000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000003', 'java.servlet', FALSE),
    ('30000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000003', 'javax.jakarta.servlet', FALSE),

    -- Câu 4
    ('30000000-0000-0000-0000-000000000013', '20000000-0000-0000-0000-000000000004', '<c:forEach items="${list}" var="item">', TRUE),
    ('30000000-0000-0000-0000-000000000014', '20000000-0000-0000-0000-000000000004', '<c:iterate collection="${list}">', FALSE),
    ('30000000-0000-0000-0000-000000000015', '20000000-0000-0000-0000-000000000004', '<c:loop items="${list}">', FALSE),
    ('30000000-0000-0000-0000-000000000016', '20000000-0000-0000-0000-000000000004', '<c:while condition="${list.hasNext()}">', FALSE),

    -- Câu 5
    ('30000000-0000-0000-0000-000000000017', '20000000-0000-0000-0000-000000000005', 'session.invalidate()', TRUE),
    ('30000000-0000-0000-0000-000000000018', '20000000-0000-0000-0000-000000000005', 'session.destroy()', FALSE),
    ('30000000-0000-0000-0000-000000000019', '20000000-0000-0000-0000-000000000005', 'session.clear()', FALSE),
    ('30000000-0000-0000-0000-000000000020', '20000000-0000-0000-0000-000000000005', 'session.remove()', FALSE),

    -- Câu 6
    ('30000000-0000-0000-0000-000000000021', '20000000-0000-0000-0000-000000000006', 'Tiếp nhận Request từ người dùng, gọi tầng Service xử lý và điều hướng View', TRUE),
    ('30000000-0000-0000-0000-000000000022', '20000000-0000-0000-0000-000000000006', 'Trực tiếp thực thi câu lệnh SQL SELECT/INSERT vào Database', FALSE),
    ('30000000-0000-0000-0000-000000000023', '20000000-0000-0000-0000-000000000006', 'Hiển thị giao diện HTML/CSS ra trình duyệt', FALSE),
    ('30000000-0000-0000-0000-000000000024', '20000000-0000-0000-0000-000000000006', 'Chứa các thẻ định dạng văn bản và bảng màu của trang web', FALSE),

    -- Câu 7
    ('30000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000007', 'B-Tree Index', TRUE),
    ('30000000-0000-0000-0000-000000000026', '20000000-0000-0000-0000-000000000007', 'Hash Index', FALSE),
    ('30000000-0000-0000-0000-000000000027', '20000000-0000-0000-0000-000000000007', 'GIN Index', FALSE),
    ('30000000-0000-0000-0000-000000000028', '20000000-0000-0000-0000-000000000007', 'BRIN Index', FALSE),

    -- Câu 8
    ('30000000-0000-0000-0000-000000000029', '20000000-0000-0000-0000-000000000008', 'EXPLAIN ANALYZE <câu_lệnh_sql>', TRUE),
    ('30000000-0000-0000-0000-000000000030', '20000000-0000-0000-0000-000000000008', 'DESCRIBE <câu_lệnh_sql>', FALSE),
    ('30000000-0000-0000-0000-000000000031', '20000000-0000-0000-0000-000000000008', 'SHOW PROFILE <câu_lệnh_sql>', FALSE),
    ('30000000-0000-0000-0000-000000000032', '20000000-0000-0000-0000-000000000008', 'OPTIMIZE <câu_lệnh_sql>', FALSE)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 9. SEED QUIZ_QUESTION (Liên kết Quiz với Question)
-- ---------------------------------------------------------------------
INSERT INTO quiz_question (id, quiz_id, question_id, order_index) VALUES
    ('40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 1),
    ('40000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 2),
    ('40000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 3),

    ('40000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000004', 1),
    ('40000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000006', 2),

    ('40000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000005', 1),

    ('40000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000007', 1),
    ('40000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000008', 2)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 10. SEED REGISTRATION (Đăng ký khóa học của học viên)
-- ---------------------------------------------------------------------
INSERT INTO registration (id, user_id, course_id, enrolled_at, status, progress_percent, amount, payment_method_id, transaction_id, payment_status, paid_at) VALUES
    -- Học viên An: Đã hoàn thành khóa Java Web (100%), đã thanh toán qua VNPay
    ('50000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000001', 
     NOW() - INTERVAL '30 days', 'completed', 100, 699000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892019', 'paid', NOW() - INTERVAL '30 days'),

    -- Học viên An: Đang học khóa PostgreSQL (50%), đã thanh toán qua MoMo
    ('50000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000002', 
     NOW() - INTERVAL '15 days', 'enrolled', 50, 550000.00, 'b0000000-0000-0000-0000-000000000012', 'MOMO9382910', 'paid', NOW() - INTERVAL '15 days'),

    -- Học viên Bình: Đang học Java Web (60%), đã thanh toán qua Banking
    ('50000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000009', 'd0000000-0000-0000-0000-000000000001', 
     NOW() - INTERVAL '20 days', 'enrolled', 60, 699000.00, 'b0000000-0000-0000-0000-000000000013', 'FT2609012389', 'paid', NOW() - INTERVAL '20 days'),

    -- Học viên Chi: Đang học Spring Boot 3 (20%), đã thanh toán qua VNPay
    ('50000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000010', 'd0000000-0000-0000-0000-000000000003', 
     NOW() - INTERVAL '10 days', 'enrolled', 20, 890000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892550', 'paid', NOW() - INTERVAL '10 days'),

    -- Học viên Dũng: Đang học React 18 (40%), đã thanh toán qua VNPay
    ('50000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000011', 'd0000000-0000-0000-0000-000000000006', 
     NOW() - INTERVAL '7 days', 'enrolled', 40, 620000.00, 'b0000000-0000-0000-0000-000000000011', 'VNP14892999', 'paid', NOW() - INTERVAL '7 days'),

    -- Học viên Linh: Đang học Python AI (10%), đã thanh toán qua Credit Card
    ('50000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000012', 'd0000000-0000-0000-0000-000000000004', 
     NOW() - INTERVAL '5 days', 'enrolled', 10, 1190000.00, 'b0000000-0000-0000-0000-000000000014', 'TXCC994821', 'paid', NOW() - INTERVAL '5 days'),

    -- Học viên Mai: Đăng ký Java Web nhưng chưa thanh toán (Pending)
    ('50000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000013', 'd0000000-0000-0000-0000-000000000001', 
     NOW() - INTERVAL '1 days', 'enrolled', 0, 699000.00, 'b0000000-0000-0000-0000-000000000011', NULL, 'pending', NULL),

    -- Học viên Quang: Đã hoàn thành khóa Cấu trúc dữ liệu (100%)
    ('50000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000014', 'd0000000-0000-0000-0000-000000000008', 
     NOW() - INTERVAL '40 days', 'completed', 100, 450000.00, 'b0000000-0000-0000-0000-000000000012', 'MOMO8829103', 'paid', NOW() - INTERVAL '40 days')
ON CONFLICT (user_id, course_id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 11. SEED LEARNING_PROCESS (Tiến độ học từng bài của học viên)
-- ---------------------------------------------------------------------
INSERT INTO learning_process (id, registration_id, lesson_id, status, completed_at) VALUES
    -- Tiến độ của học viên An cho khóa Java Web (Hoàn thành cả 7 bài)
    ('60000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 'completed', NOW() - INTERVAL '28 days'),
    ('60000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000002', 'completed', NOW() - INTERVAL '25 days'),
    ('60000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000003', 'completed', NOW() - INTERVAL '20 days'),
    ('60000000-0000-0000-0000-000000000004', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000004', 'completed', NOW() - INTERVAL '15 days'),
    ('60000000-0000-0000-0000-000000000005', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000005', 'completed', NOW() - INTERVAL '10 days'),
    ('60000000-0000-0000-0000-000000000006', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000006', 'completed', NOW() - INTERVAL '5 days'),
    ('60000000-0000-0000-0000-000000000007', '50000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000007', 'completed', NOW() - INTERVAL '1 days'),

    -- Tiến độ của học viên Bình cho khóa Java Web (Hoàn thành bài 1-3, đang học bài 4)
    ('60000000-0000-0000-0000-000000000008', '50000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000001', 'completed', NOW() - INTERVAL '18 days'),
    ('60000000-0000-0000-0000-000000000009', '50000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000002', 'completed', NOW() - INTERVAL '12 days'),
    ('60000000-0000-0000-0000-000000000010', '50000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000003', 'completed', NOW() - INTERVAL '5 days'),
    ('60000000-0000-0000-0000-000000000011', '50000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000004', 'in_progress', NULL),

    -- Tiến độ của học viên An cho khóa PostgreSQL (Hoàn thành bài 1)
    ('60000000-0000-0000-0000-000000000012', '50000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000008', 'completed', NOW() - INTERVAL '10 days'),
    ('60000000-0000-0000-0000-000000000013', '50000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000009', 'in_progress', NULL)
ON CONFLICT (registration_id, lesson_id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 12. SEED QUIZ_SUBMISSION (Lượt nộp bài thi)
-- ---------------------------------------------------------------------
INSERT INTO quiz_submission (id, quiz_id, user_id, score, submitted_at, pass_status) VALUES
    -- Học viên An làm Quiz 1: Đạt 10/10 (Pass)
    ('70000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000008', 10.00, NOW() - INTERVAL '20 days', TRUE),

    -- Học viên An làm Quiz 2: Đạt 10/10 (Pass)
    ('70000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000008', 10.00, NOW() - INTERVAL '10 days', TRUE),

    -- Học viên Bình làm Quiz 1: Lần 1 đạt 3.33 (Fail)
    ('70000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000009', 3.33, NOW() - INTERVAL '15 days', FALSE),

    -- Học viên Bình làm lại Quiz 1: Lần 2 đạt 10/10 (Pass)
    ('70000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000009', 10.00, NOW() - INTERVAL '14 days', TRUE)
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 13. SEED QUIZ_ANSWER (Chi tiết câu trả lời của học viên)
-- ---------------------------------------------------------------------
INSERT INTO quiz_answer (id, quiz_submission_id, quiz_question_id, question_option_id) VALUES
    -- An trả lời đúng cả 3 câu của Quiz 1
    ('80000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001'),
    ('80000000-0000-0000-0000-000000000002', '70000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000005'),
    ('80000000-0000-0000-0000-000000000003', '70000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000009'),

    -- Bình trả lời sai ở lần 1 (chọn sai câu 1 và 2)
    ('80000000-0000-0000-0000-000000000004', '70000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002'),
    ('80000000-0000-0000-0000-000000000005', '70000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000006'),
    ('80000000-0000-0000-0000-000000000006', '70000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000009')
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- 14. SEED NOTIFICATION (Thông báo người dùng)
-- ---------------------------------------------------------------------
INSERT INTO notification (id, user_id, type_id, content, status, sent_at) VALUES
    ('90000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000021', 
     'Chào mừng bạn đến với hệ thống học tập trực tuyến LearnHub LMS!', 'read', NOW() - INTERVAL '30 days'),

    ('90000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000023', 
     'Thanh toán thành công 699,000đ cho khóa học "Lập trình Java Web chuyên sâu". Mã GD: VNP14892019.', 'read', NOW() - INTERVAL '30 days'),

    ('90000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000024', 
     'Chúc mừng bạn đã đạt điểm tuyệt đối 10.0/10 bài Quiz Vòng đời Servlet!', 'unread', NOW() - INTERVAL '20 days'),

    ('90000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000009', 'b0000000-0000-0000-0000-000000000022', 
     'Giảng viên Kiên vừa tải lên tài liệu mới cho Bài 5: JSTL Core Tags.', 'unread', NOW() - INTERVAL '3 days'),

    ('90000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000022', 
     'Khóa học "Lập trình Java Web" của bạn đã có 15 học viên mới đăng ký trong tuần qua.', 'unread', NOW() - INTERVAL '2 days'),

    ('90000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000021', 
     'Báo cáo doanh thu tháng đã được tổng hợp xong và sẵn sàng xem trong bảng điều khiển.', 'read', NOW() - INTERVAL '1 days')
ON CONFLICT (id) DO NOTHING;


-- ---------------------------------------------------------------------
-- AUDIT LOG SEED DATA (phục vụ Admin Dashboard 2.3)
-- ---------------------------------------------------------------------
INSERT INTO audit_log (id, actor, action_type, description, status, created_at) VALUES
    ('a1000000-0000-0000-0000-000000000001', 'admin@learnhub.vn',   'LOGIN_SUCCESS',  'Admin đăng nhập thành công từ IP 192.168.1.100',                      'SUCCESS', NOW() - INTERVAL '2 hours'),
    ('a1000000-0000-0000-0000-000000000002', 'hacker@example.com',  'LOGIN_FAILED',   'Sai mật khẩu 5 lần liên tiếp – tài khoản tạm khóa',                 'FAILED',  NOW() - INTERVAL '3 hours'),
    ('a1000000-0000-0000-0000-000000000003', 'admin@learnhub.vn',   'ROLE_UPDATE',    'Cập nhật vai trò người dùng nguyenhoa@gmail.com → Expert',           'SUCCESS', NOW() - INTERVAL '1 day'),
    ('a1000000-0000-0000-0000-000000000004', 'System',              'JOB_EXEC',       'Cron job: tổng hợp báo cáo doanh thu tháng hoàn thành',              'SUCCESS', NOW() - INTERVAL '1 day 2 hours'),
    ('a1000000-0000-0000-0000-000000000005', 'manager@learnhub.vn', 'COURSE_PUBLISH', 'Khóa học "Lập trình Java Web chuyên sâu" được phát hành chính thức','SUCCESS', NOW() - INTERVAL '2 days'),
    ('a1000000-0000-0000-0000-000000000006', 'System',              'LOGIN_FAILED',   'Phát hiện IP 203.0.113.42 thử đăng nhập brute-force',                'WARNING', NOW() - INTERVAL '2 days 4 hours'),
    ('a1000000-0000-0000-0000-000000000007', 'admin@learnhub.vn',   'USER_BAN',       'Tài khoản spam123@mail.com bị khóa do vi phạm điều khoản',           'SUCCESS', NOW() - INTERVAL '3 days'),
    ('a1000000-0000-0000-0000-000000000008', 'System',              'JOB_EXEC',       'Gửi email nhắc nhở học viên chưa hoàn thành khóa học',               'SUCCESS', NOW() - INTERVAL '3 days 1 hour'),
    ('a1000000-0000-0000-0000-000000000009', 'manager@learnhub.vn', 'COURSE_ARCHIVE', 'Khóa học "HTML Cơ Bản 2020" chuyển sang trạng thái archived',        'SUCCESS', NOW() - INTERVAL '5 days'),
    ('a1000000-0000-0000-0000-000000000010', 'System',              'JOB_EXEC',       'Backup cơ sở dữ liệu hàng tuần thất bại – kiểm tra dung lượng đĩa', 'FAILED',  NOW() - INTERVAL '7 days')
ON CONFLICT (id) DO NOTHING;
