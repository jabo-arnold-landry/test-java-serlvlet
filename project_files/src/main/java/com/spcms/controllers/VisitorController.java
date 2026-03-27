package com.spcms.controllers;

import com.spcms.models.Visitor;
import com.spcms.services.VisitorService;
import com.spcms.services.IncidentService;
import com.spcms.models.Incident;
import com.spcms.models.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.security.Principal;
import java.util.List;

@Controller
@RequestMapping("/visitors")
public class VisitorController {

    @GetMapping
    public String list() {
        return "redirect:/visitor-portal/visit-log";
    }

    @GetMapping("/register")
    public String showRegisterForm() {
        return "redirect:/visitor-portal/request";
    }

    @PostMapping("/approve/{approvalId}")
    public String approve(@PathVariable("approvalId") Long approvalId) {
        return "redirect:/visitor-portal/approve/" + approvalId;
    }

    @PostMapping("/reject/{approvalId}")
    public String reject(@PathVariable("approvalId") Long approvalId) {
        return "redirect:/visitor-portal/reject/" + approvalId;
    }

    @PostMapping("/checkin")
    public String checkIn() {
        return "redirect:/visitor-portal/visit-log";
    }

    @PostMapping("/checkout/{checkId}")
    public String checkOut(@PathVariable("checkId") Long checkId) {
        return "redirect:/visitor-portal/checkout/" + checkId;
    }
}
