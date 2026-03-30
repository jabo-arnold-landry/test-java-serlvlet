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
}
