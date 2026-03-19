package com.spcms.controllers;

import com.spcms.models.Equipment;
import com.spcms.services.EquipmentService;
import com.spcms.services.FileStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/equipment")
public class EquipmentController {

    @Autowired
    private EquipmentService equipmentService;

    @Autowired
    private FileStorageService fileStorageService;

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
                       @RequestParam(value = "configFile", required = false) MultipartFile configFile,
                       @RequestParam(value = "networkDiagramFile", required = false) MultipartFile networkDiagramFile,
                       @RequestParam(value = "rackLayoutFile", required = false) MultipartFile rackLayoutFile,
                       @RequestParam(value = "maintenanceReportFile", required = false) MultipartFile maintenanceReportFile,
                       @RequestParam(value = "photosFile", required = false) MultipartFile photosFile,
                       RedirectAttributes redirectAttributes) {

        // If editing, preserve existing file paths when no new file is uploaded
        Equipment existingEquipment = null;
        if (equipment.getEquipmentId() != null) {
            existingEquipment = equipmentService.getEquipmentById(equipment.getEquipmentId()).orElse(null);
        }

        // Save the equipment first to get the ID (for new records)
        Equipment savedEquipment = equipmentService.createEquipment(equipment);
        Long eqId = savedEquipment.getEquipmentId();

        boolean filesUpdated = false;

        // Handle Config File upload
        if (configFile != null && !configFile.isEmpty()) {
            // Delete old file if exists
            if (existingEquipment != null && existingEquipment.getConfigFilePath() != null) {
                fileStorageService.deleteFile(existingEquipment.getConfigFilePath());
            }
            String path = fileStorageService.storeFile(configFile, eqId, "config");
            savedEquipment.setConfigFilePath(path);
            filesUpdated = true;
        } else if (existingEquipment != null) {
            savedEquipment.setConfigFilePath(existingEquipment.getConfigFilePath());
            filesUpdated = true;
        }

        // Handle Network Diagram upload
        if (networkDiagramFile != null && !networkDiagramFile.isEmpty()) {
            if (existingEquipment != null && existingEquipment.getNetworkDiagramRef() != null) {
                fileStorageService.deleteFile(existingEquipment.getNetworkDiagramRef());
            }
            String path = fileStorageService.storeFile(networkDiagramFile, eqId, "network-diagram");
            savedEquipment.setNetworkDiagramRef(path);
            filesUpdated = true;
        } else if (existingEquipment != null) {
            savedEquipment.setNetworkDiagramRef(existingEquipment.getNetworkDiagramRef());
            filesUpdated = true;
        }

        // Handle Rack Layout Diagram upload
        if (rackLayoutFile != null && !rackLayoutFile.isEmpty()) {
            if (existingEquipment != null && existingEquipment.getRackLayoutDiagram() != null) {
                fileStorageService.deleteFile(existingEquipment.getRackLayoutDiagram());
            }
            String path = fileStorageService.storeFile(rackLayoutFile, eqId, "rack-layout");
            savedEquipment.setRackLayoutDiagram(path);
            filesUpdated = true;
        } else if (existingEquipment != null) {
            savedEquipment.setRackLayoutDiagram(existingEquipment.getRackLayoutDiagram());
            filesUpdated = true;
        }

        // Handle Maintenance Report upload
        if (maintenanceReportFile != null && !maintenanceReportFile.isEmpty()) {
            if (existingEquipment != null && existingEquipment.getMaintenanceReportPath() != null) {
                fileStorageService.deleteFile(existingEquipment.getMaintenanceReportPath());
            }
            String path = fileStorageService.storeFile(maintenanceReportFile, eqId, "maintenance-report");
            savedEquipment.setMaintenanceReportPath(path);
            filesUpdated = true;
        } else if (existingEquipment != null) {
            savedEquipment.setMaintenanceReportPath(existingEquipment.getMaintenanceReportPath());
            filesUpdated = true;
        }

        // Handle Photos upload
        if (photosFile != null && !photosFile.isEmpty()) {
            if (existingEquipment != null && existingEquipment.getPhotosPath() != null) {
                fileStorageService.deleteFile(existingEquipment.getPhotosPath());
            }
            String path = fileStorageService.storeFile(photosFile, eqId, "photos");
            savedEquipment.setPhotosPath(path);
            filesUpdated = true;
        } else if (existingEquipment != null) {
            savedEquipment.setPhotosPath(existingEquipment.getPhotosPath());
            filesUpdated = true;
        }

        // Save again with file paths
        if (filesUpdated) {
            equipmentService.updateEquipment(savedEquipment);
        }

        redirectAttributes.addFlashAttribute("success", "Equipment saved successfully");
        return "redirect:/equipment";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        Equipment equipment = equipmentService.getEquipmentById(id)
                .orElseThrow(() -> new RuntimeException("Equipment not found"));
        model.addAttribute("equipment", equipment);

        // Pass original filenames for display in the form
        model.addAttribute("configFileName", fileStorageService.getOriginalFilename(equipment.getConfigFilePath()));
        model.addAttribute("networkDiagramFileName", fileStorageService.getOriginalFilename(equipment.getNetworkDiagramRef()));
        model.addAttribute("rackLayoutFileName", fileStorageService.getOriginalFilename(equipment.getRackLayoutDiagram()));
        model.addAttribute("maintenanceReportFileName", fileStorageService.getOriginalFilename(equipment.getMaintenanceReportPath()));
        model.addAttribute("photosFileName", fileStorageService.getOriginalFilename(equipment.getPhotosPath()));

        return "equipment/form";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable Long id, Model model) {
        Equipment equipment = equipmentService.getEquipmentById(id)
                .orElseThrow(() -> new RuntimeException("Equipment not found"));
        model.addAttribute("equipment", equipment);

        // Pass original filenames for display
        model.addAttribute("configFileName", fileStorageService.getOriginalFilename(equipment.getConfigFilePath()));
        model.addAttribute("networkDiagramFileName", fileStorageService.getOriginalFilename(equipment.getNetworkDiagramRef()));
        model.addAttribute("rackLayoutFileName", fileStorageService.getOriginalFilename(equipment.getRackLayoutDiagram()));
        model.addAttribute("maintenanceReportFileName", fileStorageService.getOriginalFilename(equipment.getMaintenanceReportPath()));
        model.addAttribute("photosFileName", fileStorageService.getOriginalFilename(equipment.getPhotosPath()));

        // Pass file extensions for icon display
        model.addAttribute("configFileExt", fileStorageService.getFileExtension(equipment.getConfigFilePath()));
        model.addAttribute("networkDiagramFileExt", fileStorageService.getFileExtension(equipment.getNetworkDiagramRef()));
        model.addAttribute("rackLayoutFileExt", fileStorageService.getFileExtension(equipment.getRackLayoutDiagram()));
        model.addAttribute("maintenanceReportFileExt", fileStorageService.getFileExtension(equipment.getMaintenanceReportPath()));
        model.addAttribute("photosFileExt", fileStorageService.getFileExtension(equipment.getPhotosPath()));

        return "equipment/view";
    }

    /**
     * Download a file attachment for a specific equipment.
     */
    @GetMapping("/download/{id}/{docType}")
    public ResponseEntity<Resource> downloadFile(@PathVariable Long id, @PathVariable String docType) {
        Equipment equipment = equipmentService.getEquipmentById(id)
                .orElseThrow(() -> new RuntimeException("Equipment not found"));

        String filePath = switch (docType) {
            case "config" -> equipment.getConfigFilePath();
            case "network-diagram" -> equipment.getNetworkDiagramRef();
            case "rack-layout" -> equipment.getRackLayoutDiagram();
            case "maintenance-report" -> equipment.getMaintenanceReportPath();
            case "photos" -> equipment.getPhotosPath();
            default -> throw new RuntimeException("Unknown document type: " + docType);
        };

        if (filePath == null || filePath.isBlank()) {
            throw new RuntimeException("No file attached for type: " + docType);
        }

        Resource resource = fileStorageService.loadFileAsResource(filePath);
        String originalFilename = fileStorageService.getOriginalFilename(filePath);

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + originalFilename + "\"")
                .body(resource);
    }

    /**
     * Remove a specific file attachment from an equipment record.
     */
    @PostMapping("/remove-file/{id}/{docType}")
    public String removeFile(@PathVariable Long id, @PathVariable String docType,
                             RedirectAttributes redirectAttributes) {
        Equipment equipment = equipmentService.getEquipmentById(id)
                .orElseThrow(() -> new RuntimeException("Equipment not found"));

        switch (docType) {
            case "config" -> {
                fileStorageService.deleteFile(equipment.getConfigFilePath());
                equipment.setConfigFilePath(null);
            }
            case "network-diagram" -> {
                fileStorageService.deleteFile(equipment.getNetworkDiagramRef());
                equipment.setNetworkDiagramRef(null);
            }
            case "rack-layout" -> {
                fileStorageService.deleteFile(equipment.getRackLayoutDiagram());
                equipment.setRackLayoutDiagram(null);
            }
            case "maintenance-report" -> {
                fileStorageService.deleteFile(equipment.getMaintenanceReportPath());
                equipment.setMaintenanceReportPath(null);
            }
            case "photos" -> {
                fileStorageService.deleteFile(equipment.getPhotosPath());
                equipment.setPhotosPath(null);
            }
        }

        equipmentService.updateEquipment(equipment);
        redirectAttributes.addFlashAttribute("success", "File removed successfully");
        return "redirect:/equipment/edit/" + id;
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        // Delete associated files first
        Equipment equipment = equipmentService.getEquipmentById(id).orElse(null);
        if (equipment != null) {
            fileStorageService.deleteFile(equipment.getConfigFilePath());
            fileStorageService.deleteFile(equipment.getNetworkDiagramRef());
            fileStorageService.deleteFile(equipment.getRackLayoutDiagram());
            fileStorageService.deleteFile(equipment.getMaintenanceReportPath());
            fileStorageService.deleteFile(equipment.getPhotosPath());
        }

        equipmentService.deleteEquipment(id);
        redirectAttributes.addFlashAttribute("success", "Equipment deleted successfully");
        return "redirect:/equipment";
    }
}
