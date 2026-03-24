package com.spcms.repositories;

import com.spcms.models.ShiftHandoverNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ShiftHandoverNoteRepository extends JpaRepository<ShiftHandoverNote, Long> {
    List<ShiftHandoverNote> findByShiftReport_ReportId(Long reportId);
}
