package com.spcms.services;

import com.spcms.models.DecisionRequest;
import com.spcms.models.User;
import com.spcms.repositories.DecisionRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class DecisionRequestService {

    @Autowired
    private DecisionRequestRepository decisionRequestRepository;

    public DecisionRequest create(DecisionRequest request) {
        if (request.getStatus() == null) {
            request.setStatus(DecisionRequest.DecisionStatus.PENDING);
        }
        return decisionRequestRepository.save(request);
    }

    public DecisionRequest update(DecisionRequest request) {
        return decisionRequestRepository.save(request);
    }

    public Optional<DecisionRequest> getById(Long id) {
        return decisionRequestRepository.findById(id);
    }

    public List<DecisionRequest> getAll() {
        return decisionRequestRepository.findAll();
    }

    public List<DecisionRequest> getPending() {
        return decisionRequestRepository.findAll().stream()
                .filter(r -> r.getStatus() == DecisionRequest.DecisionStatus.PENDING)
                .collect(Collectors.toList());
    }

    public void delete(Long id) {
        decisionRequestRepository.deleteById(id);
    }

    public DecisionRequest approve(Long id, Long approverId, String remarks) {
        DecisionRequest request = decisionRequestRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Decision request not found: " + id));
        User approver = new User();
        approver.setUserId(approverId);
        request.setApprovedBy(approver);
        request.setStatus(DecisionRequest.DecisionStatus.APPROVED);
        request.setDecisionTime(LocalDateTime.now());
        request.setRemarks(remarks);
        return decisionRequestRepository.save(request);
    }

    public DecisionRequest reject(Long id, Long approverId, String remarks) {
        DecisionRequest request = decisionRequestRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Decision request not found: " + id));
        User approver = new User();
        approver.setUserId(approverId);
        request.setApprovedBy(approver);
        request.setStatus(DecisionRequest.DecisionStatus.REJECTED);
        request.setDecisionTime(LocalDateTime.now());
        request.setRemarks(remarks);
        return decisionRequestRepository.save(request);
    }

    public List<DecisionRequest> getReport(LocalDate start, LocalDate end,
                                           DecisionRequest.DecisionStatus status,
                                           DecisionRequest.RequestType type) {
        List<DecisionRequest> all = decisionRequestRepository.findAll();
        LocalDateTime startTime = start != null ? start.atStartOfDay() : null;
        LocalDateTime endTime = end != null ? end.atTime(LocalTime.MAX) : null;

        return all.stream()
                .filter(r -> status == null || r.getStatus() == status)
                .filter(r -> type == null || r.getRequestType() == type)
                .filter(r -> {
                    if (startTime == null && endTime == null) {
                        return true;
                    }
                    if (r.getCreatedAt() == null) {
                        return false;
                    }
                    if (startTime != null && r.getCreatedAt().isBefore(startTime)) {
                        return false;
                    }
                    if (endTime != null && r.getCreatedAt().isAfter(endTime)) {
                        return false;
                    }
                    return true;
                })
                .collect(Collectors.toList());
    }
}
