package com.spcms.repositories;

import com.spcms.models.Visitor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface VisitorRepository extends JpaRepository<Visitor, Long> {
    Optional<Visitor> findByPassNumber(String passNumber);
    List<Visitor> findByVisitDate(LocalDate visitDate);
    List<Visitor> findByVisitDateBetween(LocalDate start, LocalDate end);
    List<Visitor> findByNationalIdPassport(String nationalIdPassport);
    List<Visitor> findByHostEmployee_UserId(Long hostEmployeeId);
}
