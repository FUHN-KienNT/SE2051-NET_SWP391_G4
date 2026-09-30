# LearnHub - Online Learning Platform (LMS)

[![Java 17](https://img.shields.io/badge/Java-17-orange.svg)](https://www.oracle.com/java/)
[![Jakarta EE 10](https://img.shields.io/badge/Jakarta%20EE-10-blue.svg)](https://jakarta.ee/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://www.postgresql.org/)
[![Maven](https://img.shields.io/badge/Maven-3.8+-C71A36.svg)](https://maven.apache.org/)

**LearnHub** is an enterprise-grade Online Learning Management System (LMS) built with Java Jakarta EE, following a layered MVC architecture and standardized SRS/SDS specifications for course management, video learning, quiz assessments, and role-based access control.

---

## 🏛️ Package Architecture

The project strictly follows a layered MVC pattern under `com.learnhub`:

```
com.learnhub
├── constant        # System-wide constants (Roles, Statuses, Session keys, Pagination)
│   └── AppConstants.java
├── controller      # Jakarta Servlets dispatching HTTP requests and routing views
│   ├── AuthServlet.java
│   ├── CourseServlet.java
│   ├── EnrollmentServlet.java
│   ├── ErrorServlet.java
│   ├── HomeServlet.java
│   ├── LearningProcessServlet.java
│   ├── LessonServlet.java
│   ├── QuizServlet.java
│   └── UserServlet.java
├── dao             # Data Access Objects executing SQL via JDBC & HikariCP
│   ├── AnswerDAO.java
│   ├── CourseDAO.java
│   ├── LearningProcessDAO.java
│   ├── LessonDAO.java
│   ├── ModuleDAO.java
│   ├── NotificationDAO.java
│   ├── QuestionDAO.java
│   ├── QuizAttemptDAO.java
│   ├── QuizDAO.java
│   ├── RegistrationDAO.java
│   ├── SettingDAO.java
│   └── UserDAO.java
├── dto             # Data Transfer Objects for cross-layer data exchange
│   ├── CourseDTO.java
│   ├── LearningProcessDTO.java
│   ├── LessonDTO.java
│   ├── ModuleDTO.java
│   ├── QuizAttemptDTO.java
│   ├── RegistrationDTO.java
│   └── UserDTO.java
├── entity          # Domain models mapped 1:1 to PostgreSQL tables
│   ├── Course.java
│   ├── LearningProcess.java
│   ├── Lesson.java
│   ├── Module.java
│   ├── Notification.java
│   ├── Payment.java
│   ├── Question.java
│   ├── QuestionOption.java
│   ├── Quiz.java
│   ├── QuizAnswer.java
│   ├── QuizQuestion.java
│   ├── QuizSubmission.java
│   ├── Registration.java
│   ├── Setting.java
│   └── User.java
├── filter          # Web filters for UTF-8 encoding and role-based authorization
│   ├── AuthorizationFilter.java
│   └── EncodingFilter.java
├── service         # Business logic layer orchestrating workflows and transactions
│   ├── CourseService.java
│   ├── LearningProcessService.java
│   ├── LessonService.java
│   ├── NotificationService.java
│   ├── QuizAttemptService.java
│   └── UserService.java
└── util            # Utility helpers (Database pooling, BCrypt hashing, Cloudinary, Mail)
    ├── CloudinaryClient.java
    ├── DbConnection.java
    ├── EmailUtil.java
    └── PasswordHashUtil.java
```

### Layer Responsibilities

| Layer | Package | Description |
|---|---|---|
| **Presentation** | `controller`, `filter` | Intercepts HTTP requests, handles session authentication/authorization, and forwards to JSP views. |
| **Business Logic** | `service` | Executes core business rules, calculations (scoring, progress), and transactional logic. |
| **Data Access** | `dao` | Performs robust CRUD operations against PostgreSQL using prepared statements and connection pooling. |
| **Domain Model** | `entity`, `dto` | Encapsulates relational data structures and facilitates safe data transport across application layers. |
| **Cross-Cutting** | `constant`, `util` | Centralized constants (roles, statuses) and shared utilities (password hashing, connection manager, email). |

---

## 🚀 Tech Stack

- **Backend:** Java 17 LTS, Jakarta Servlet 6.0, Jakarta Server Pages (JSP) 3.1, JSTL 3.0.
- **Database:** PostgreSQL 15+ with **HikariCP** high-performance connection pooling.
- **Security:** **jBCrypt** password hashing, Session-based authentication & Role-based Access Control (RBAC).
- **Integrations:** Cloudinary Media API, Jakarta Mail.
- **Frontend:** Responsive JSP views styled with **Tailwind CSS** and **FontAwesome 6**.
- **Build Tool:** Apache Maven.

---

## 🗄️ Database Schema

The database schema and sample data are defined in:
- [`db/schema.sql`](file:///db/schema.sql): Complete DDL schema defining 14 core tables with foreign keys and indexes.
- [`db/seed.sql`](file:///db/seed.sql): Initial seed data including system roles, categories, demo users, sample courses, modules, lessons, and quizzes.

### Core Tables

1. `setting`: System-wide settings and category/role lookup tables.
2. `user`: User accounts with roles (Admin, Manager, Expert, Student).
3. `course`: Course catalog, pricing, category, and publishing status.
4. `module`: Course curriculum chapters/sections.
5. `lesson`: Educational lessons (video, document, article).
6. `registration`: Course enrollment and registration tracking.
7. `learning_process`: Student progress tracking per lesson.
8. `quiz`: Assessments and evaluation tests.
9. `question`: Question bank for quizzes.
10. `question_option`: Answer choices for questions.
11. `quiz_question`: Quiz and question association mapping.
12. `quiz_submission`: Student quiz attempt records.
13. `quiz_answer`: Detailed student responses per question.
14. `notification`: System notifications and alerts.

---

## 🛠️ Getting Started

### Prerequisites
- **JDK 17** or later
- **Apache Maven 3.8+**
- **PostgreSQL 14+**
- **Apache Tomcat 10.1+** (supporting Jakarta EE 10)

### 1. Database Setup
```bash
# Create database
createdb -U postgres learnhub

# Execute schema and seed data
psql -U postgres -d learnhub -f db/schema.sql
psql -U postgres -d learnhub -f db/seed.sql
```

Configure connection parameters in `src/main/resources/database.properties` or via environment variables (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`).

### 2. Build Project
```bash
mvn clean package
```
The output artifact `target/learnhub.war` will be generated.

### 3. Deploy
Copy `target/learnhub.war` to the `webapps/` directory of your Apache Tomcat 10.1+ server and start Tomcat.

Access the application at: `http://localhost:8080/learnhub`

---

## 👥 Project Team - SWP391 G4
- **Project:** LearnHub LMS
- **Class:** SE2051-NET
- **Semester:** Fall 2026 / Semester 5