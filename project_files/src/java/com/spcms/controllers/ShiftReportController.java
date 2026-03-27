package com.spcms.controllers;

import com.spcms.models.ShiftReport;
import com.spcms.models.ShiftHandoverNote;
import com.spcms.services.ShiftReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;

@Controller
@RequestMapping("/shift-reports")
public class ShiftReportController {

    @Autowired
    private ShiftReportService shiftReportService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("reports", shiftReportService.getShiftReportsByDate(LocalDate.now()));
        return "shift-reports/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("shiftReport", new ShiftReport());
        return "shift-reports/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute ShiftReport report, RedirectAttributes redirectAttributes) {
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
}
