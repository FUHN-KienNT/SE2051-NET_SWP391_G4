package com.learnhub.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
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
            LOGGER.info("HikariCP Connection Pool initialized successfully.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialize HikariCP connection pool: " + e.getMessage(), e);
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
