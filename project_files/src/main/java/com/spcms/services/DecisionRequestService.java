package com.spcms.services;

import com.spcms.models.DecisionRequest;
import com.spcms.repositories.DecisionRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class DecisionRequestService {

    @Autowired
    private DecisionRequestRepository decisionRequestRepository;

    public DecisionRequest create(DecisionRequest request) {
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

    public List<DecisionRequest> getByStatus(DecisionRequest.Status status) {
        return decisionRequestRepository.findByStatus(status);
    }

    public List<DecisionRequest> getByRequester(Long userId) {
        return decisionRequestRepository.findByRequestedBy_UserId(userId);
    }

    public void delete(Long id) {
        decisionRequestRepository.deleteById(id);
    }
}
