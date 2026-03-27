package com.spcms.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
@Order(0)
public class IncidentStatusMigration implements CommandLineRunner {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) {
        jdbcTemplate.update("UPDATE incidents SET status = 'IN_PROGRESS' WHERE status = 'OPEN'");
        jdbcTemplate.update("UPDATE incidents SET status = 'RESOLVED' WHERE status = 'CLOSED'");
        jdbcTemplate.update("UPDATE incidents SET status = 'IN_PROGRESS' WHERE status IS NULL");
    }
}
