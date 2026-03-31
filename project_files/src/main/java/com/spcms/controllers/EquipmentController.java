package com.spcms.controllers;

import com.spcms.models.Equipment;
import com.spcms.services.EquipmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/equipment")
public class EquipmentController {

    @Autowired
    private EquipmentService equipmentService;

    @Autowired
    private com.spcms.services.FileStorageService fileStorageService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("equipmentList", equipmentService.getAllEquipment());
        return "equipment/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("equipment", new Equipment());
        return "equipment/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute Equipment equipment, 
                       @RequestParam(value = "configFile", required = false) org.springframework.web.multipart.MultipartFile configFile,
                       @RequestParam(value = "diagramFile", required = false) org.springframework.web.multipart.MultipartFile diagramFile,
                       @RequestParam(value = "maintenanceReportFile", required = false) org.springframework.web.multipart.MultipartFile maintenanceReportFile,
                       @RequestParam(value = "photosFile", required = false) org.springframework.web.multipart.MultipartFile photosFile,
                       RedirectAttributes redirectAttributes) {
        
        try {
            if (configFile != null && !configFile.isEmpty()) {
                equipment.setConfigFilePath(fileStorageService.storeServiceReport(configFile));
            }
            if (diagramFile != null && !diagramFile.isEmpty()) {
                equipment.setNetworkDiagramRef(fileStorageService.storeServiceReport(diagramFile));
            }
            if (maintenanceReportFile != null && !maintenanceReportFile.isEmpty()) {
                equipment.setMaintenanceReportPath(fileStorageService.storeServiceReport(maintenanceReportFile));
            }
            if (photosFile != null && !photosFile.isEmpty()) {
                equipment.setPhotosPath(fileStorageService.storeServiceReport(photosFile));
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to upload file attachments.");
        }

        equipmentService.createEquipment(equipment);
        redirectAttributes.addFlashAttribute("success", "Equipment saved successfully");
        return "redirect:/equipment";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable("id") Long id, Model model) {
        model.addAttribute("equipment", equipmentService.getEquipmentById(id)
                .orElseThrow(() -> new RuntimeException("Equipment not found")));
        return "equipment/form";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable("id") Long id, Model model) {
        model.addAttribute("equipment", equipmentService.getEquipmentById(id)
                .orElseThrow(() -> new RuntimeException("Equipment not found")));
        return "equipment/view";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable("id") Long id, RedirectAttributes redirectAttributes) {
        equipmentService.deleteEquipment(id);
        redirectAttributes.addFlashAttribute("success", "Equipment deleted successfully");
        return "redirect:/equipment";
    }
}
