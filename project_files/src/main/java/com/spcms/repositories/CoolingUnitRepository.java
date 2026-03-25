package com.spcms.repositories;

import com.spcms.models.CoolingUnit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface CoolingUnitRepository extends JpaRepository<CoolingUnit, Long> {
    Optional<CoolingUnit> findByAssetTag(String assetTag);
    Optional<CoolingUnit> findBySerialNumber(String serialNumber);
    List<CoolingUnit> findByStatus(CoolingUnit.CoolingStatus status);
    List<CoolingUnit> findByLocationRoom(String room);
    List<CoolingUnit> findByLocationZone(String zone);

    @Query("SELECT c FROM CoolingUnit c WHERE c.roomTemperature > :threshold")
    List<CoolingUnit> findHighTemperature(BigDecimal threshold);

    @Query("SELECT c FROM CoolingUnit c WHERE c.compressorStatus = 'STOPPED' AND c.status = 'ACTIVE'")
    List<CoolingUnit> findActiveWithStoppedCompressor();
}
