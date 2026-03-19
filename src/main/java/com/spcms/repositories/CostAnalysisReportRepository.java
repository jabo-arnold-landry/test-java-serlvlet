package com.spcms.repositories;

import com.spcms.models.CostAnalysisReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface CostAnalysisReportRepository extends JpaRepository<CostAnalysisReport, Long> {

    Optional<CostAnalysisReport> findByReportDate(LocalDate reportDate);

    Optional<CostAnalysisReport> findByBranchAndReportDate(String branch, LocalDate reportDate);

    List<CostAnalysisReport> findByReportDateBetweenOrderByReportDateDesc(LocalDate start, LocalDate end);

    List<CostAnalysisReport> findByBranchAndReportDateBetweenOrderByReportDateDesc(
            String branch, LocalDate start, LocalDate end);

    List<CostAnalysisReport> findAllByBranchOrderByReportDateDesc(String branch);
}
