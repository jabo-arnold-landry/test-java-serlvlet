package com.spcms.controllers;

import com.spcms.models.ShiftReport;
import com.spcms.models.ShiftHandoverNote;
import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import com.spcms.services.ShiftReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Controller
@RequestMapping("/shift-reports")
public class ShiftReportController {

    @Autowired
    private ShiftReportService shiftReportService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("reports", shiftReportService.getAllShiftReports());
        return "shift-reports/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model, Authentication authentication) {
        ShiftReport report = new ShiftReport();
        report.setShiftDate(LocalDate.now());
        report.setLoginTime(LocalDateTime.now());

        User currentUser = getCurrentUser(authentication);
        if (currentUser != null) {
            report.setStaff(currentUser);
            model.addAttribute("currentUser", currentUser);
        }

        model.addAttribute("shiftReport", report);
        return "shift-reports/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute ShiftReport report, Authentication authentication, RedirectAttributes redirectAttributes) {
        User currentUser = getCurrentUser(authentication);
        if (currentUser == null) {
            redirectAttributes.addFlashAttribute("error", "Unable to resolve the logged-in user.");
            return "redirect:/login";
        }

        report.setStaff(currentUser);
        if (report.getShiftDate() == null) {
            report.setShiftDate(LocalDate.now());
        }
        if (report.getLoginTime() == null) {
            report.setLoginTime(LocalDateTime.now());
        }

        shiftReportService.createShiftReport(report);
        redirectAttributes.addFlashAttribute("success", "Shift report saved");
        return "redirect:/shift-reports";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable Long id, Model model) {
        model.addAttribute("report", shiftReportService.getShiftReportById(id)
                .orElseThrow(() -> new RuntimeException("Shift report not found")));
        model.addAttribute("handoverNotes", shiftReportService.getHandoverNotes(id));
        return "shift-reports/view";
    }

    @PostMapping("/handover/{reportId}")
    public String addHandoverNote(@PathVariable Long reportId,
            @ModelAttribute ShiftHandoverNote note,
            RedirectAttributes redirectAttributes) {
        ShiftReport report = shiftReportService.getShiftReportById(reportId)
                .orElseThrow(() -> new RuntimeException("Report not found"));
        note.setShiftReport(report);
        shiftReportService.addHandoverNote(note);
        redirectAttributes.addFlashAttribute("success", "Handover note added");
        return "redirect:/shift-reports/view/" + reportId;
    }

    @PostMapping("/close/{id}")
    public String closeShift(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        shiftReportService.closeShift(id);
        redirectAttributes.addFlashAttribute("success", "Shift closed successfully");
        return "redirect:/shift-reports";
    }

    private User getCurrentUser(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            return null;
        }
        return userRepository.findByUsername(authentication.getName()).orElse(null);
    }
}
