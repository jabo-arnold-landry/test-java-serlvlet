package com.spcms.repositories;

import com.spcms.models.VisitorCheckInOut;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface VisitorCheckInOutRepository extends JpaRepository<VisitorCheckInOut, Long> {
    List<VisitorCheckInOut> findByVisitor_VisitorId(Long visitorId);

    @Query("SELECT v FROM VisitorCheckInOut v WHERE v.visitClosed = false")
    List<VisitorCheckInOut> findActiveVisitors();

    @Query("SELECT v FROM VisitorCheckInOut v WHERE v.escort.userId = :escortId AND v.visitClosed = false")
    List<VisitorCheckInOut> findByEscort(@org.springframework.data.repository.query.Param("escortId") Long escortId);

    @Query("SELECT v FROM VisitorCheckInOut v WHERE v.visitClosed = true AND CAST(v.checkInTime AS date) >= :startDate AND CAST(v.checkInTime AS date) <= :endDate ORDER BY v.checkInTime DESC")
    List<VisitorCheckInOut> findVisitHistory(@org.springframework.data.repository.query.Param("startDate") java.time.LocalDate startDate, @org.springframework.data.repository.query.Param("endDate") java.time.LocalDate endDate);

    @Query("SELECT v.visitor, COUNT(v) FROM VisitorCheckInOut v WHERE v.visitClosed = true GROUP BY v.visitor ORDER BY COUNT(v) DESC")
    List<Object[]> findHighFrequencyVisitors();

    @Query("SELECT COUNT(v) FROM VisitorCheckInOut v WHERE v.visitClosed = true AND CAST(v.checkOutTime AS date) = CURRENT_DATE")
    long countCompletedToday();

    List<VisitorCheckInOut> findByVisitClosed(boolean visitClosed);
    List<VisitorCheckInOut> findByEscort_UserIdAndVisitClosedOrderByCheckInTimeDesc(Long userId, boolean visitClosed);
}
