package com.spcms.controllers;

import com.spcms.models.User;
import com.spcms.models.Visitor;
import com.spcms.services.VisitorService;
import com.spcms.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.security.Principal;

@Controller
@RequestMapping("/visitor-portal")
public class VisitorPortalController {

    @Autowired
    private VisitorService visitorService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public String portalForm(Model model, Principal principal) {
        if (principal != null) {
            userRepository.findByUsername(principal.getName()).ifPresent(user -> {
                model.addAttribute("currentUser", user);
                Visitor v = new Visitor();
                v.setFullName(user.getFullName());
                v.setCompany("N/A");
                model.addAttribute("visitor", v);
            });
        }
        model.addAttribute("staffList", userRepository.findAll()); // For host dropdown
        return "visitor-portal";
    }

    @PostMapping("/request")
    public String requestVisit(@ModelAttribute Visitor visitor, RedirectAttributes redirectAttributes) {
        // Assume default values from form, pass down hostEmployee
        Visitor saved = visitorService.registerVisitor(visitor);
        visitorService.submitForApproval(saved.getVisitorId());
        
        redirectAttributes.addFlashAttribute("success", "Your visit request has been sent for approval. Your Reference: " + saved.getPassNumber());
        return "redirect:/visitor-portal";
    }
}
