package com.spcms.controllers;

import com.spcms.models.CoolingUnit;
import com.spcms.services.CoolingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/cooling")
public class CoolingController {

    @Autowired
    private CoolingService coolingService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("coolingList", coolingService.getAllCoolingUnits());
        return "cooling/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("coolingUnit", new CoolingUnit());
        return "cooling/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute CoolingUnit coolingUnit, RedirectAttributes redirectAttributes) {
        coolingService.createCoolingUnit(coolingUnit);
        redirectAttributes.addFlashAttribute("success", "Cooling unit saved successfully");
        return "redirect:/cooling";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        model.addAttribute("coolingUnit", coolingService.getCoolingUnitById(id)
                .orElseThrow(() -> new RuntimeException("Cooling unit not found")));
        return "cooling/form";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable Long id, Model model) {
        model.addAttribute("coolingUnit", coolingService.getCoolingUnitById(id)
                .orElseThrow(() -> new RuntimeException("Cooling unit not found")));
        return "cooling/view";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        coolingService.deleteCoolingUnit(id);
        redirectAttributes.addFlashAttribute("success", "Cooling unit deleted successfully");
        return "redirect:/cooling";
    }
}
