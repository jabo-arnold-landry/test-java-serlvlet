package com.spcms.repositories;

import com.spcms.models.CoolingAlarmLog;
import com.spcms.models.CoolingUnit;
import com.spcms.util.DBConnection;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;
@Repository
public class CoolingAlarmLogRepository {

    public boolean save(CoolingAlarmLog alarm) {
        return addAlarm(alarm);
    }

    public boolean addAlarm(CoolingAlarmLog alarm) {
        String sql = "INSERT INTO cooling_alarm_log (cooling_id, alarm_type, alarm_description, severity, alarm_triggered_at, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, alarm.getCoolingUnitId());
            ps.setString(2, alarm.getAlarmType());
            ps.setString(3, alarm.getAlarmDescription());
            ps.setString(4, alarm.getSeverity());
            ps.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now()));
            ps.setString(6, "ACTIVE");
            ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<CoolingAlarmLog> getAllAlarms() {
        String sql = "SELECT * FROM cooling_alarm_log ORDER BY alarm_triggered_at DESC";
        List<CoolingAlarmLog> alarms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                alarms.add(extractAlarm(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return alarms;
    }

    public List<CoolingAlarmLog> getAlarmsByCoolingUnit(Long coolingUnitId) {
        String sql = "SELECT * FROM cooling_alarm_log WHERE cooling_id = ? ORDER BY alarm_triggered_at DESC";
        List<CoolingAlarmLog> alarms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, coolingUnitId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    alarms.add(extractAlarm(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return alarms;
    }

    public List<CoolingAlarmLog> getActiveAlarms() {
        String sql = "SELECT * FROM cooling_alarm_log WHERE status = 'ACTIVE' ORDER BY alarm_triggered_at DESC";
        List<CoolingAlarmLog> alarms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                alarms.add(extractAlarm(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return alarms;
    }

    public List<CoolingAlarmLog> getAlarmsBySeverity(String severity) {
        String sql = "SELECT * FROM cooling_alarm_log WHERE severity = ? ORDER BY alarm_triggered_at DESC";
        List<CoolingAlarmLog> alarms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, severity);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    alarms.add(extractAlarm(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return alarms;
    }

    public CoolingAlarmLog getAlarmById(Long alarmId) {
        String sql = "SELECT * FROM cooling_alarm_log WHERE alarm_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, alarmId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractAlarm(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateAlarmStatus(Long alarmId, String status, String resolvedBy, String resolution) {
        String sql = "UPDATE cooling_alarm_log SET status = ?, resolved_by = ?, resolution = ?, alarm_resolved_at = ?, updated_at = ? WHERE alarm_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, resolvedBy);
            ps.setString(3, resolution);
            ps.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(6, alarmId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteAlarm(Long alarmId) {
        String sql = "DELETE FROM cooling_alarm_log WHERE alarm_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, alarmId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private CoolingAlarmLog extractAlarm(ResultSet rs) throws SQLException {
        CoolingAlarmLog alarm = new CoolingAlarmLog();
        alarm.setAlarmId(rs.getLong("alarm_id"));
        alarm.setCoolingUnitId(rs.getLong("cooling_id"));
        alarm.setAlarmType(rs.getString("alarm_type"));
        alarm.setAlarmDescription(rs.getString("alarm_description"));
        alarm.setSeverity(rs.getString("severity"));
        alarm.setAlarmTriggeredAt(rs.getTimestamp("alarm_triggered_at").toLocalDateTime());

        Timestamp resolvedAt = rs.getTimestamp("alarm_resolved_at");
        if (resolvedAt != null) {
            alarm.setAlarmResolvedAt(resolvedAt.toLocalDateTime());
        }

        alarm.setStatus(rs.getString("status"));
        alarm.setResolvedBy(rs.getString("resolved_by"));
        alarm.setResolution(rs.getString("resolution"));
        alarm.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        alarm.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        return alarm;
    }

    public List<CoolingAlarmLog> findByAlarmTimeBetween(LocalDateTime start, LocalDateTime end) {
        String sql = "SELECT * FROM cooling_alarm_log WHERE alarm_triggered_at BETWEEN ? AND ? ORDER BY alarm_triggered_at DESC";
        List<CoolingAlarmLog> alarms = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(start));
            ps.setTimestamp(2, Timestamp.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    alarms.add(extractAlarm(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return alarms;
    }

    public Optional<CoolingUnit> findById(Long alarmId) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'findById'");
    }

    public List<CoolingAlarmLog> findByResolutionTimeIsNull() {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'findByResolutionTimeIsNull'");
    }

    public List<CoolingAlarmLog> findByCoolingUnit_CoolingIdOrderByAlarmTimeDesc(Long coolingId) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'findByCoolingUnit_CoolingIdOrderByAlarmTimeDesc'");
    }
}
