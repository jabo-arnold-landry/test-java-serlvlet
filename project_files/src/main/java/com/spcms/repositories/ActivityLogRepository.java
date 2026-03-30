package com.spcms.repositories;

import com.spcms.models.ActivityLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ActivityLogRepository extends JpaRepository<ActivityLog, Long> {

    List<ActivityLog> findByUser_UserIdOrderByTimestampDesc(Long userId);

    List<ActivityLog> findByTimestampBetweenOrderByTimestampDesc(LocalDateTime start, LocalDateTime end);

    List<ActivityLog> findByEntityTypeAndEntityId(String entityType, Long entityId);

    void deleteByUser_UserId(Long userId);

    // === Maintenance History Filtered Queries ===

    List<ActivityLog> findByEntityTypeContainingAndTimestampBetweenOrderByTimestampDesc(
            String entityTypePattern, LocalDateTime start, LocalDateTime end);

    List<ActivityLog> findByActionAndTimestampBetweenOrderByTimestampDesc(
            String action, LocalDateTime start, LocalDateTime end);

    @Query("SELECT a FROM ActivityLog a WHERE " +
           "a.entityType LIKE %:entityType% " +
           "AND a.timestamp BETWEEN :start AND :end " +
           "ORDER BY a.timestamp DESC")
    List<ActivityLog> findMaintenanceLogs(@Param("entityType") String entityType,
                                          @Param("start") LocalDateTime start,
                                          @Param("end") LocalDateTime end);

    @Query("SELECT a FROM ActivityLog a WHERE " +
           "a.entityType LIKE %:entityType% " +
           "AND a.action = :action " +
           "AND a.timestamp BETWEEN :start AND :end " +
           "ORDER BY a.timestamp DESC")
    List<ActivityLog> findMaintenanceLogsByAction(@Param("entityType") String entityType,
                                                   @Param("action") String action,
                                                   @Param("start") LocalDateTime start,
                                                   @Param("end") LocalDateTime end);

    @Query("SELECT a FROM ActivityLog a WHERE " +
           "a.entityType LIKE %:entityType% " +
           "AND a.user.userId = :userId " +
           "AND a.timestamp BETWEEN :start AND :end " +
           "ORDER BY a.timestamp DESC")
    List<ActivityLog> findMaintenanceLogsByUser(@Param("entityType") String entityType,
                                                 @Param("userId") Long userId,
                                                 @Param("start") LocalDateTime start,
                                                 @Param("end") LocalDateTime end);

    @Query("SELECT a FROM ActivityLog a WHERE " +
           "a.entityType LIKE %:entityType% " +
           "AND a.action = :action " +
           "AND a.user.userId = :userId " +
           "AND a.timestamp BETWEEN :start AND :end " +
           "ORDER BY a.timestamp DESC")
    List<ActivityLog> findMaintenanceLogsFull(@Param("entityType") String entityType,
                                               @Param("action") String action,
                                               @Param("userId") Long userId,
                                               @Param("start") LocalDateTime start,
                                               @Param("end") LocalDateTime end);

    @Query("SELECT DISTINCT a.action FROM ActivityLog a WHERE a.entityType LIKE '%MAINTENANCE%' ORDER BY a.action")
    List<String> findDistinctMaintenanceActions();
}
