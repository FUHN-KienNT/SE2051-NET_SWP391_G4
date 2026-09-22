# LearnHub - Online Learning Platform (LMS)

[![Java 17](https://img.shields.io/badge/Java-17-orange.svg)](https://www.oracle.com/java/)
[![Jakarta EE 10](https://img.shields.io/badge/Jakarta%20EE-10-blue.svg)](https://jakarta.ee/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://www.postgresql.org/)
[![Maven](https://img.shields.io/badge/Maven-3.8+-C71A36.svg)](https://maven.apache.org/)

Hệ thống Quản lý Học tập Trực tuyến (**LearnHub LMS**) được thiết kế và xây dựng theo chuẩn tài liệu đặc tả yêu cầu phần mềm (**SRS**) và đặc tả thiết kế phần mềm (**SDS**) dành cho môn học **SWP391 - Nhóm G4 (SE2051-NET)**.

---

## 🏛️ Cấu Trúc Gói (Package Architecture)

Dự án tuân thủ chặt chẽ kiến trúc MVC phân lớp (Layered Architecture) theo chuẩn cấu trúc package được quy định:

```
com.fpt.lms
├── controller              # Các Jakarta Servlets điều hướng Request/Response
│   ├── AuthServlet.java
│   ├── CourseServlet.java
│   ├── EnrollmentServlet.java
│   ├── HomeServlet.java
│   ├── LearningProcessServlet.java
│   ├── LessonServlet.java
│   ├── PaymentServlet.java
│   ├── QuizServlet.java
│   ├── UserServlet.java
│   └── ContentReviewServlet.java
├── dao                     # Data Access Objects tương tác trực tiếp với PostgreSQL
│   ├── SettingDAO.java
│   ├── RoleDAO.java
│   ├── UserDAO.java
│   ├── CourseDAO.java
│   ├── RegistrationDAO.java
│   ├── EnrollmentDAO.java
│   ├── PaymentDAO.java
│   ├── LessonDAO.java
│   ├── LearningProcessDAO.java
│   ├── QuizDAO.java
│   ├── QuestionDAO.java
│   ├── AnswerDAO.java
│   ├── QuizAttemptDAO.java
│   ├── ContentReviewDAO.java
│   └── NotificationDAO.java
├── dto                     # Data Transfer Objects trao đổi dữ liệu giữa các tầng
│   ├── CourseDTO.java
│   ├── LearningProcessDTO.java
│   ├── LessonDTO.java
│   ├── PageResult.java
│   ├── PaymentRequestDTO.java
│   ├── QuizAttemptDTO.java
│   ├── RegistrationDTO.java
│   └── UserDTO.java
├── entity                  # Model Entities ánh xạ trực tiếp 1-1 với Database Schema
│   ├── Setting.java
│   ├── User.java
│   ├── Course.java
│   ├── Registration.java
│   ├── Module.java
│   ├── Lesson.java
│   ├── LearningProcess.java
│   ├── Quiz.java
│   ├── Question.java
│   ├── QuestionOption.java
│   ├── QuizQuestion.java
│   ├── QuizSubmission.java
│   ├── QuizAnswer.java
│   ├── Notification.java
│   ├── Payment.java
│   └── ContentReview.java
├── filter                  # Bộ lọc xử lý Encoding (UTF-8) và Phân quyền (Authorization)
│   ├── EncodingFilter.java
│   └── AuthorizationFilter.java
├── service                 # Business Logic Services xử lý nghiệp vụ hệ thống
│   ├── UserService.java
│   ├── CourseService.java
│   ├── LessonService.java
│   ├── LearningProcessService.java
│   ├── EnrollmentService.java
│   ├── PaymentService.java
│   ├── ScoringService.java
│   ├── QuizAttemptService.java
│   ├── ContentReviewService.java
│   └── NotificationService.java
├── util                    # Tiện ích hệ thống (Database, Hash, VNPay, Mail, ...)
│   ├── DbConnection.java
│   ├── PasswordHashUtil.java
│   ├── VNPayGateway.java
│   ├── CloudinaryClient.java
│   ├── EmailUtil.java
│   └── DateUtil.java
└── HelloServlet.java       # Servlet kiểm thử khởi động hệ thống
```

---

## 🚀 Công Nghệ Sử Dụng

- **Ngôn ngữ & Nền tảng:** Java 17 LTS, Jakarta Servlet 6.0, Jakarta Server Pages (JSP) 3.1, JSTL 3.0.
- **Cơ sở dữ liệu:** PostgreSQL 15+ kết hợp Connection Pooling tốc độ cao với **HikariCP**.
- **Bảo mật:** Mã hóa mật khẩu an toàn theo thuật toán **jBCrypt**, Session-based Authentication & Role-based Authorization.
- **Tích hợp bên ngoài:** Cổng thanh toán **VNPay Gateway** (mô phỏng sandbox chuẩn), Cloudinary Media Storage, Jakarta Mail.
- **Giao diện (Frontend):** JSP views responsive tích hợp **Tailwind CSS**, **FontAwesome 6**, chuẩn UX/UI hiện đại.

---

## 🗄️ Cấu Trúc Cơ Sở Dữ Liệu

Tất cả bảng dữ liệu và dữ liệu mẫu được định nghĩa đầy đủ tại tệp [`db/schema.sql`](file:///db/schema.sql) gồm 16 bảng:
1. `setting`: Quản lý các cấu hình hệ thống (roles, categories, v.v.).
2. `user`: Quản lý tài khoản (Admin, Manager, Expert, Customer/Student).
3. `course`: Danh mục khóa học, giá, phân loại và trạng thái kiểm duyệt.
4. `registration`: Quản lý đơn đăng ký khóa học của học viên.
5. `module`: Các chương học trong khóa học.
6. `lesson`: Bài học (Video, bài viết, tài liệu).
7. `learning_process`: Tiến độ học tập của học viên theo từng bài học.
8. `quiz`: Bài thi trắc nghiệm đánh giá năng lực.
9. `question`: Ngân hàng câu hỏi trắc nghiệm.
10. `question_option`: Các phương án trả lời cho từng câu hỏi.
11. `quiz_question`: Liên kết giữa bài thi và danh sách câu hỏi.
12. `quiz_submission`: Lượt nộp bài thi của học viên.
13. `quiz_answer`: Câu trả lời chi tiết của học viên trong từng lượt thi.
14. `notification`: Thông báo hệ thống tới người dùng.
15. `payment`: Giao dịch thanh toán khóa học qua VNPay.
16. `content_review`: Quy trình kiểm duyệt nội dung của chuyên gia/quản trị.

---

## 🛠️ Hướng Dẫn Cài Đặt & Chạy Dự Án

### 1. Yêu cầu môi trường
- JDK 17 trở lên.
- Apache Maven 3.8+.
- PostgreSQL 14 trở lên.
- Apache Tomcat 10.1+ (Hỗ trợ Jakarta EE 10).

### 2. Cài đặt Cơ sở Dữ liệu
1. Tạo database mới trong PostgreSQL:
   ```sql
   CREATE DATABASE learnhub;
   ```
2. Thực thi kịch bản DDL & dữ liệu mẫu:
   ```bash
   psql -U postgres -d learnhub -f db/schema.sql
   ```
3. Cấu hình thông tin kết nối trong `src/main/resources/database.properties` (hoặc biến môi trường `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`).

### 3. Build Dự Án
```bash
mvn clean package
```
Tệp `target/learnhub.war` sẽ được tạo ra thành công.

### 4. Triển khai (Deploy)
Copy tệp `target/learnhub.war` vào thư mục `webapps/` của Tomcat 10.1+ và khởi động server.
Truy cập ứng dụng tại: `http://localhost:8080/learnhub`

---

## 👥 Nhóm Thực Hiện - SWP391 G4
- **Dự án:** LearnHub LMS
- **Học kỳ:** Fall 2026 / Semester 5