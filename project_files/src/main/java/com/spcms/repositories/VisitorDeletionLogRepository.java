package com.spcms.repositories;

import com.spcms.models.VisitorDeletionLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VisitorDeletionLogRepository extends JpaRepository<VisitorDeletionLog, Long> {
    List<VisitorDeletionLog> findAllByOrderByDeletedAtDesc();
}
