package com.spcms.controllers;

import com.spcms.models.ShiftHandoverNote;
import com.spcms.models.ShiftReport;
import com.spcms.services.ShiftReportService;
import com.spcms.services.UserService;
import com.spcms.models.User;
import org.springframework.beans.factory.annotation.Autowired;
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
    private UserService userService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("reports", shiftReportService.getAllShiftReports());
        return "shift-reports/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        ShiftReport report = new ShiftReport();
        report.setShiftDate(LocalDate.now());
        model.addAttribute("shiftReport", report);
        model.addAttribute("users", userService.getActiveUsers());
        return "shift-reports/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute ShiftReport report, RedirectAttributes redirectAttributes) {
        Long staffId = report.getStaff() != null ? report.getStaff().getUserId() : null;
        if (staffId == null) {
            redirectAttributes.addFlashAttribute("error", "Please select a staff member");
            return "redirect:/shift-reports/new";
        }

        User staff = userService.getUserById(staffId).orElse(null);
        if (staff == null) {
            redirectAttributes.addFlashAttribute("error", "Selected staff user does not exist");
            return "redirect:/shift-reports/new";
        }

        report.setStaff(staff);
        shiftReportService.createShiftReport(report);
        redirectAttributes.addFlashAttribute("success", "Shift report saved");
        return "redirect:/shift-reports";
    }

    @PostMapping("/close/{id}")
    public String close(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        ShiftReport report = shiftReportService.getShiftReportById(id)
                .orElseThrow(() -> new RuntimeException("Shift report not found"));

        if (report.getLogoutTime() == null) {
            report.setLogoutTime(LocalDateTime.now());
            shiftReportService.updateShiftReport(report);
            redirectAttributes.addFlashAttribute("success", "Shift closed");
        } else {
            redirectAttributes.addFlashAttribute("success", "Shift is already closed");
        }

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
}
