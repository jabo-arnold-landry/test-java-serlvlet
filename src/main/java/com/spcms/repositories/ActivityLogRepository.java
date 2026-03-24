package com.spcms.repositories;

import com.spcms.models.ActivityLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ActivityLogRepository extends JpaRepository<ActivityLog, Long> {
    List<ActivityLog> findByUser_UserIdOrderByTimestampDesc(Long userId);
    List<ActivityLog> findByTimestampBetweenOrderByTimestampDesc(LocalDateTime start, LocalDateTime end);
    List<ActivityLog> findByEntityTypeAndEntityId(String entityType, Long entityId);
    void deleteByUser_UserId(Long userId);
}
