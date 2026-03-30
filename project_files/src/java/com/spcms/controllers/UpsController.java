package com.spcms.controllers;

import com.spcms.models.Ups;
import com.spcms.services.UpsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/ups")
public class UpsController {

    @Autowired
    private UpsService upsService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("upsList", upsService.getAllUps());
        return "ups/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("ups", new Ups());
        return "ups/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute Ups ups, RedirectAttributes redirectAttributes) {
        upsService.createUps(ups);
        redirectAttributes.addFlashAttribute("success", "UPS saved successfully");
        return "redirect:/ups";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        model.addAttribute("ups", upsService.getUpsById(id)
                .orElseThrow(() -> new RuntimeException("UPS not found")));
        return "ups/form";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable Long id, Model model) {
        model.addAttribute("ups", upsService.getUpsById(id)
                .orElseThrow(() -> new RuntimeException("UPS not found")));
        model.addAttribute("batteries", upsService.getBatteriesByUpsId(id));
        return "ups/view";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        upsService.deleteUps(id);
        redirectAttributes.addFlashAttribute("success", "UPS deleted successfully");
        return "redirect:/ups";
    }
}
