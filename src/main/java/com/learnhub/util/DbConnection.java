package com.learnhub.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Utility class for database connection pooling via HikariCP and PostgreSQL.
 * Matches DbConnection utility class designed in SDS.
 */
public class DbConnection {
    private static final Logger LOGGER = Logger.getLogger(DbConnection.class.getName());
    private static HikariDataSource dataSource;

    private DbConnection() {
    }

    static {
        try {
            Properties props = new Properties();
            try (InputStream input = DbConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input != null) {
                    props.load(input);
                } else {
                    LOGGER.warning("db.properties not found in classpath, using default database properties.");
                }
            }

            String driver = props.getProperty("db.driver", "org.postgresql.Driver");
            String url = props.getProperty("db.url", "jdbc:postgresql://localhost:5432/learnhub_db");
            String username = props.getProperty("db.username", "postgres");
            String password = props.getProperty("db.password", "postgres");

            HikariConfig config = new HikariConfig();
            config.setDriverClassName(driver);
            config.setJdbcUrl(url);
            config.setUsername(username);
            config.setPassword(password);

            config.setMaximumPoolSize(Integer.parseInt(props.getProperty("hikaricp.maximumPoolSize", "10")));
            config.setMinimumIdle(Integer.parseInt(props.getProperty("hikaricp.minimumIdle", "2")));
            config.setIdleTimeout(Long.parseLong(props.getProperty("hikaricp.idleTimeout", "30000")));
            config.setConnectionTimeout(Long.parseLong(props.getProperty("hikaricp.connectionTimeout", "20000")));
            config.setMaxLifetime(Long.parseLong(props.getProperty("hikaricp.maxLifetime", "1800000")));

            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
            config.addDataSourceProperty("stringtype", "unspecified");

            dataSource = new HikariDataSource(config);
            ensureSchemaUpToDate();
            LOGGER.info("HikariCP Connection Pool initialized successfully.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialize HikariCP connection pool: " + e.getMessage(), e);
        }
    }

    private static void ensureSchemaUpToDate() {
        String[] statements = {
            "ALTER TABLE module ADD COLUMN IF NOT EXISTS hidden BOOLEAN NOT NULL DEFAULT FALSE",
            "DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lesson_type') THEN CREATE TYPE lesson_type AS ENUM ('content', 'video', 'quiz'); END IF; END $$",
            "ALTER TABLE lesson ADD COLUMN IF NOT EXISTS lesson_type lesson_type NOT NULL DEFAULT 'content'",
            "ALTER TABLE lesson ADD COLUMN IF NOT EXISTS video_url TEXT",
            "ALTER TABLE lesson ADD COLUMN IF NOT EXISTS quiz_id UUID",
            "CREATE UNIQUE INDEX IF NOT EXISTS uq_quiz_id_module ON quiz (id, module_id)",
            "CREATE INDEX IF NOT EXISTS idx_lesson_quiz_id ON lesson (quiz_id) WHERE quiz_id IS NOT NULL",
            "INSERT INTO module (course_id, title, content, order_index) " +
                    "SELECT c.id, 'Chương 1: Kiến thức nền tảng & Tổng quan', 'Nội dung kiến thức nền tảng của khóa học.', 1 " +
                    "FROM course c WHERE NOT EXISTS (SELECT 1 FROM module m WHERE m.course_id = c.id)",
            "INSERT INTO module (course_id, title, content, order_index) " +
                    "SELECT c.id, 'Chương 2: Thực hành chuyên sâu & Dự án thực tế', 'Ứng dụng thực hành và bài tập tổng hợp của khóa học.', 2 " +
                    "FROM course c WHERE (SELECT COUNT(*) FROM module m WHERE m.course_id = c.id) = 1"
        };
        try (Connection conn = dataSource.getConnection();
             Statement st = conn.createStatement()) {
            for (String sql : statements) {
                try {
                    st.execute(sql);
                } catch (SQLException ignored) {
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Schema auto-check skipped: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("DataSource has not been initialized correctly.");
        }
        return dataSource.getConnection();
    }

    public static void closePool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            LOGGER.info("HikariCP Connection Pool closed.");
        }
    }
}
