package com.spcms.repositories;

import com.spcms.models.ReportLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

@Repository
public interface ReportLogRepository extends JpaRepository<ReportLog, Long>, JpaSpecificationExecutor<ReportLog> {
}
