package com.spcms.repositories;

import com.spcms.models.Ups;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
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
}
