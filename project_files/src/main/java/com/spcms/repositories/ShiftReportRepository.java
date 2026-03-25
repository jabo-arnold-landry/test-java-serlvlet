package com.spcms.repositories;

import com.spcms.models.ShiftReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface ShiftReportRepository extends JpaRepository<ShiftReport, Long> {
    List<ShiftReport> findByShiftDateOrderByCreatedAtDesc(LocalDate date);
    List<ShiftReport> findByStaff_UserIdOrderByShiftDateDesc(Long staffId);
    List<ShiftReport> findByShiftDateBetween(LocalDate start, LocalDate end);
    List<ShiftReport> findByShiftType(ShiftReport.ShiftType type);

    @Query("SELECT AVG(s.maxLoadPercent) FROM ShiftReport s WHERE s.shiftDate = :date")
    java.math.BigDecimal avgLoadByDate(LocalDate date);

    @Query("SELECT SUM(s.downtimeDurationMin) FROM ShiftReport s WHERE s.shiftDate = :date")
    Integer sumDowntimeByDate(LocalDate date);
}
