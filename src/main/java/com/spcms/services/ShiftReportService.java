package com.spcms.services;

import com.spcms.models.ShiftReport;
import com.spcms.models.ShiftHandoverNote;
import com.spcms.repositories.ShiftReportRepository;
import com.spcms.repositories.ShiftHandoverNoteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class ShiftReportService {

    @Autowired
    private ShiftReportRepository shiftReportRepository;

    @Autowired
    private ShiftHandoverNoteRepository shiftHandoverNoteRepository;

    // ==================== Shift Report CRUD ====================

    public ShiftReport createShiftReport(ShiftReport report) {
        return shiftReportRepository.save(report);
    }

    public Optional<ShiftReport> getShiftReportById(Long id) {
        return shiftReportRepository.findById(id);
    }

    public List<ShiftReport> getAllShiftReports() {
        return shiftReportRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"));
    }

    public List<ShiftReport> getShiftReportsByDate(LocalDate date) {
        return shiftReportRepository.findByShiftDateOrderByCreatedAtDesc(date);
    }

    public List<ShiftReport> getShiftReportsByStaff(Long staffId) {
        return shiftReportRepository.findByStaff_UserIdOrderByShiftDateDesc(staffId);
    }

    public List<ShiftReport> getShiftReportsByDateRange(LocalDate start, LocalDate end) {
        return shiftReportRepository.findByShiftDateBetween(start, end);
    }

    public ShiftReport updateShiftReport(ShiftReport report) {
        return shiftReportRepository.save(report);
    }

    // ==================== Handover Notes ====================

    public ShiftHandoverNote addHandoverNote(ShiftHandoverNote note) {
        return shiftHandoverNoteRepository.save(note);
    }

    public List<ShiftHandoverNote> getHandoverNotes(Long reportId) {
        return shiftHandoverNoteRepository.findByShiftReport_ReportId(reportId);
    }

    // ==================== Analytics ====================

    public java.math.BigDecimal getAverageLoadByDate(LocalDate date) {
        java.math.BigDecimal avg = shiftReportRepository.avgLoadByDate(date);
        return avg != null ? avg : java.math.BigDecimal.ZERO;
    }

    public Integer getTotalDowntimeByDate(LocalDate date) {
        Integer total = shiftReportRepository.sumDowntimeByDate(date);
        return total != null ? total : 0;
    }
}
