package com.spcms.repositories;

import com.spcms.models.Ups;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UpsRepository extends JpaRepository<Ups, Long> {
    Optional<Ups> findByAssetTag(String assetTag);
    Optional<Ups> findBySerialNumber(String serialNumber);
    List<Ups> findByStatus(Ups.UpsStatus status);
    List<Ups> findByLocationRoom(String room);
    List<Ups> findByLocationZone(String zone);

    @Query("SELECT u FROM Ups u WHERE u.loadPercentage > :threshold")
    List<Ups> findOverloaded(java.math.BigDecimal threshold);

    @Query("SELECT u FROM Ups u WHERE u.bypassStatus = true")
    List<Ups> findOnBypass();

    // Date range queries for reporting
    @Query("SELECT u FROM Ups u WHERE u.createdAt >= :startDate AND u.createdAt < :endDate ORDER BY u.createdAt DESC")
    List<Ups> findByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT u FROM Ups u WHERE u.createdAt >= :startDate AND u.createdAt < :endDate AND u.status = :status ORDER BY u.createdAt DESC")
    List<Ups> findByDateRangeAndStatus(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate, @Param("status") Ups.UpsStatus status);

    @Query("SELECT u FROM Ups u WHERE u.createdAt >= :startDate AND u.createdAt < :endDate AND u.locationRoom = :location ORDER BY u.createdAt DESC")
    List<Ups> findByDateRangeAndLocation(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate, @Param("location") String location);

    @Query("SELECT u FROM Ups u WHERE u.createdAt >= :startDate AND u.createdAt < :endDate AND u.status = :status AND u.locationRoom = :location ORDER BY u.createdAt DESC")
    List<Ups> findByDateRangeStatusAndLocation(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate, @Param("status") Ups.UpsStatus status, @Param("location") String location);
}
