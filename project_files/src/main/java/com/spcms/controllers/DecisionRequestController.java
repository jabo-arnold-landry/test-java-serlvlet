package com.spcms.controllers;

import com.spcms.models.DecisionRequest;
import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import com.spcms.services.DecisionRequestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.security.Principal;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

@Controller
@RequestMapping("/decisions")
public class DecisionRequestController {

    @Autowired
    private DecisionRequestService decisionRequestService;

    @Autowired
    private UserRepository userRepository;

    private User getCurrentUser(Principal principal) {
        if (principal == null) return null;
        return userRepository.findByUsername(principal.getName()).orElse(null);
    }

    @GetMapping
    public String list(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        List<DecisionRequest> requests;
        if (user.getRole() == User.Role.ADMIN) {
            requests = decisionRequestService.getAll();
        } else {
            requests = decisionRequestService.getByRequester(user.getUserId());
        }

        requests.sort(Comparator.comparing(DecisionRequest::getRequestedAt,
                Comparator.nullsLast(Comparator.naturalOrder())).reversed());
        model.addAttribute("decisionRequests", requests);
        model.addAttribute("currentUser", user);
        model.addAttribute("requestTypes", DecisionRequest.RequestType.values());
        return "decisions/list";
    }

    @GetMapping("/new")
    public String createForm(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        model.addAttribute("decisionRequest", new DecisionRequest());
        model.addAttribute("requestTypes", DecisionRequest.RequestType.values());
        model.addAttribute("isEdit", false);
        return "decisions/form";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable Long id, Model model, Principal principal,
                           RedirectAttributes redirectAttributes) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        return decisionRequestService.getById(id)
                .map(existing -> {
                    boolean isOwner = existing.getRequestedBy() != null
                            && existing.getRequestedBy().getUserId().equals(user.getUserId());
                    boolean isAdmin = user.getRole() == User.Role.ADMIN;
                    boolean editable = existing.getStatus() == DecisionRequest.Status.PENDING;

                    if (!isAdmin && (!isOwner || !editable)) {
                        redirectAttributes.addFlashAttribute("error",
                                "You can only edit your own pending requests.");
                        return "redirect:/decisions";
                    }
                    model.addAttribute("decisionRequest", existing);
                    model.addAttribute("requestTypes", DecisionRequest.RequestType.values());
                    model.addAttribute("isEdit", true);
                    return "decisions/form";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("error", "Decision request not found.");
                    return "redirect:/decisions";
                });
    }

    @PostMapping("/save")
    public String save(@ModelAttribute DecisionRequest form,
                       Principal principal,
                       RedirectAttributes redirectAttributes) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        DecisionRequest request;
        boolean isEdit = form.getRequestId() != null;

        if (isEdit) {
            request = decisionRequestService.getById(form.getRequestId())
                    .orElse(null);
            if (request == null) {
                redirectAttributes.addFlashAttribute("error", "Decision request not found.");
                return "redirect:/decisions";
            }

            boolean isOwner = request.getRequestedBy() != null
                    && request.getRequestedBy().getUserId().equals(user.getUserId());
            boolean isAdmin = user.getRole() == User.Role.ADMIN;

            if (!isAdmin && (!isOwner || request.getStatus() != DecisionRequest.Status.PENDING)) {
                redirectAttributes.addFlashAttribute("error",
                        "You can only edit your own pending requests.");
                return "redirect:/decisions";
            }
        } else {
            request = new DecisionRequest();
            request.setRequestedBy(user);
            request.setStatus(DecisionRequest.Status.PENDING);
        }

        request.setRequestType(form.getRequestType());
        request.setTitle(form.getTitle());
        request.setDescription(form.getDescription());
        request.setJustification(form.getJustification());
        request.setAssetOrSystem(form.getAssetOrSystem());
        request.setVendorOrSupplier(form.getVendorOrSupplier());
        request.setQuantity(form.getQuantity());
        request.setEstimatedCost(form.getEstimatedCost());

        if (!isEdit) {
            request.setRequestedBy(user);
        } else if (user.getRole() != User.Role.ADMIN) {
            request.setStatus(DecisionRequest.Status.PENDING);
            request.setApprovedBy(null);
            request.setDecisionAt(null);
            request.setDecisionNotes(null);
        }

        decisionRequestService.update(request);
        redirectAttributes.addFlashAttribute("success",
                "Decision request " + (isEdit ? "updated" : "submitted") + " successfully.");
        return "redirect:/decisions";
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id, Principal principal,
                         RedirectAttributes redirectAttributes) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        return decisionRequestService.getById(id)
                .map(request -> {
                    boolean isOwner = request.getRequestedBy() != null
                            && request.getRequestedBy().getUserId().equals(user.getUserId());
                    boolean isAdmin = user.getRole() == User.Role.ADMIN;
                    boolean deletable = request.getStatus() == DecisionRequest.Status.PENDING;

                    if (!isAdmin && (!isOwner || !deletable)) {
                        redirectAttributes.addFlashAttribute("error",
                                "You can only delete your own pending requests.");
                        return "redirect:/decisions";
                    }
                    decisionRequestService.delete(id);
                    redirectAttributes.addFlashAttribute("success", "Decision request deleted.");
                    return "redirect:/decisions";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("error", "Decision request not found.");
                    return "redirect:/decisions";
                });
    }

    @PostMapping("/approve/{id}")
    public String approve(@PathVariable Long id,
                          @RequestParam(value = "decisionNotes", required = false) String decisionNotes,
                          Principal principal,
                          RedirectAttributes redirectAttributes) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        return decisionRequestService.getById(id)
                .map(request -> {
                    if (request.getStatus() != DecisionRequest.Status.PENDING) {
                        redirectAttributes.addFlashAttribute("error", "Only pending requests can be approved.");
                        return "redirect:/decisions";
                    }
                    request.setStatus(DecisionRequest.Status.APPROVED);
                    request.setApprovedBy(user);
                    request.setDecisionAt(LocalDateTime.now());
                    request.setDecisionNotes(decisionNotes);
                    decisionRequestService.update(request);
                    redirectAttributes.addFlashAttribute("success", "Decision request approved.");
                    return "redirect:/decisions";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("error", "Decision request not found.");
                    return "redirect:/decisions";
                });
    }

    @PostMapping("/reject/{id}")
    public String reject(@PathVariable Long id,
                         @RequestParam(value = "decisionNotes", required = false) String decisionNotes,
                         Principal principal,
                         RedirectAttributes redirectAttributes) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        return decisionRequestService.getById(id)
                .map(request -> {
                    if (request.getStatus() != DecisionRequest.Status.PENDING) {
                        redirectAttributes.addFlashAttribute("error", "Only pending requests can be rejected.");
                        return "redirect:/decisions";
                    }
                    request.setStatus(DecisionRequest.Status.REJECTED);
                    request.setApprovedBy(user);
                    request.setDecisionAt(LocalDateTime.now());
                    request.setDecisionNotes(decisionNotes);
                    decisionRequestService.update(request);
                    redirectAttributes.addFlashAttribute("success", "Decision request rejected.");
                    return "redirect:/decisions";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("error", "Decision request not found.");
                    return "redirect:/decisions";
                });
    }

    @GetMapping("/report")
    public String report(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        List<DecisionRequest> all = decisionRequestService.getAll();
        all.sort(Comparator.comparing(DecisionRequest::getRequestedAt,
                Comparator.nullsLast(Comparator.naturalOrder())).reversed());

        long total = all.size();
        long pending = all.stream().filter(r -> r.getStatus() == DecisionRequest.Status.PENDING).count();
        long approved = all.stream().filter(r -> r.getStatus() == DecisionRequest.Status.APPROVED).count();
        long rejected = all.stream().filter(r -> r.getStatus() == DecisionRequest.Status.REJECTED).count();

        BigDecimal approvedCost = all.stream()
                .filter(r -> r.getStatus() == DecisionRequest.Status.APPROVED)
                .map(DecisionRequest::getEstimatedCost)
                .filter(c -> c != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        model.addAttribute("decisionRequests", all);
        model.addAttribute("totalCount", total);
        model.addAttribute("pendingCount", pending);
        model.addAttribute("approvedCount", approved);
        model.addAttribute("rejectedCount", rejected);
        model.addAttribute("approvedCostTotal", approvedCost);
        return "decisions/report";
    }
}
