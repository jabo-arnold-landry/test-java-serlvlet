package com.spcms.repositories;

import com.spcms.models.BranchPerformanceReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface BranchPerformanceReportRepository extends JpaRepository<BranchPerformanceReport, Long> {

    Optional<BranchPerformanceReport> findByBranchAndReportDate(String branch, LocalDate reportDate);

    List<BranchPerformanceReport> findByReportDate(LocalDate reportDate);

    List<BranchPerformanceReport> findByBranchAndReportDateBetweenOrderByReportDateDesc(
            String branch, LocalDate start, LocalDate end);

    List<BranchPerformanceReport> findByReportDateBetweenOrderByReportDateDesc(LocalDate start, LocalDate end);

    List<BranchPerformanceReport> findAllByBranchOrderByReportDateDesc(String branch);
}
