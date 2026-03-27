package com.spcms.config;

import com.spcms.util.DBConnection;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

/**
 * Bridges Spring-managed DataSource into legacy DBConnection utility.
 * This keeps legacy JDBC repositories aligned with active Spring profiles.
 */
@Component
public class DBConnectionDataSourceBridge {

    public DBConnectionDataSourceBridge(DataSource dataSource) {
        DBConnection.setDataSource(dataSource);
    }
}

