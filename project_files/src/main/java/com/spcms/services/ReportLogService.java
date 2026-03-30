package com.spcms.services;

import com.spcms.dto.reports.ReportLogFilterDto;
import com.spcms.models.ReportLog;
import com.spcms.models.User;
import com.spcms.repositories.ReportLogRepository;
import com.spcms.repositories.UserRepository;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class ReportLogService {

    private final ReportLogRepository reportLogRepository;
    private final UserRepository userRepository;

    public ReportLogService(ReportLogRepository reportLogRepository, UserRepository userRepository) {
        this.reportLogRepository = reportLogRepository;
        this.userRepository = userRepository;
    }

    public ReportLog saveExportLog(String reportType,
                                   String username,
                                   String fileFormat,
                                   String filePath,
                                   String filtersUsed,
                                   ReportLog.ExportStatus status,
                                   String errorMessage) {
        User generatedBy = null;
        if (username != null && !username.isBlank()) {
            generatedBy = userRepository.findByUsername(username).orElse(null);
        }

        ReportLog log = ReportLog.builder()
                .reportType(reportType)
                .generatedBy(generatedBy)
                .fileFormat(fileFormat)
                .filePath(filePath)
                .filtersUsed(filtersUsed)
                .status(status)
                .errorMessage(errorMessage)
                .build();

        return reportLogRepository.save(log);
    }

    public List<ReportLog> getLogs(ReportLogFilterDto filter, User currentUser) {
        Specification<ReportLog> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (filter.getStartDate() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("generatedAt"), filter.getStartDate().atStartOfDay()));
            }
            if (filter.getEndDate() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("generatedAt"), LocalDateTime.of(filter.getEndDate(), LocalTime.MAX)));
            }
            if (filter.getReportType() != null && !filter.getReportType().isBlank()) {
                predicates.add(cb.equal(cb.lower(root.get("reportType")), filter.getReportType().toLowerCase()));
            }
            if (filter.getUserId() != null) {
                predicates.add(cb.equal(root.get("generatedBy").get("userId"), filter.getUserId()));
            }

            if (currentUser != null && currentUser.getRole() == User.Role.TECHNICIAN) {
                predicates.add(cb.equal(root.get("generatedBy").get("userId"), currentUser.getUserId()));
                predicates.add(root.get("reportType").in("maintenance", "shift"));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        return reportLogRepository.findAll(spec, Sort.by(Sort.Direction.DESC, "generatedAt"));
    }

    public List<User> getSelectableUsers(User currentUser) {
        if (currentUser != null && currentUser.getRole() == User.Role.TECHNICIAN) {
            return List.of(currentUser);
        }
        return userRepository.findAll(Sort.by(Sort.Direction.ASC, "fullName"));
    }

    public Optional<User> findUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }
}
