package com.spcms.repositories;

import com.spcms.models.DailyConsolidatedReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface DailyConsolidatedReportRepository extends JpaRepository<DailyConsolidatedReport, Long> {
    Optional<DailyConsolidatedReport> findByReportDate(LocalDate date);
    List<DailyConsolidatedReport> findByReportDateBetweenOrderByReportDateDesc(LocalDate start, LocalDate end);
}
