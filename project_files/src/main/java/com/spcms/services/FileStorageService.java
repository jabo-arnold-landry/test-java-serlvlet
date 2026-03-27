package com.spcms.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

/**
 * Service for handling file uploads (service reports, etc.).
 * Files are stored in the configured upload directory.
 */
@Service
public class FileStorageService {

    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(
            ".pdf", ".doc", ".docx", ".jpg", ".jpeg", ".png", ".xls", ".xlsx"
    );

    @Value("${file.upload-dir:./uploads}")
    private String uploadDir;

    private Path uploadPath;

    @PostConstruct
    public void init() {
        uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
        try {
            Files.createDirectories(uploadPath);
            Files.createDirectories(uploadPath.resolve("service-reports"));
        } catch (IOException e) {
            throw new RuntimeException("Could not create upload directories", e);
        }
    }

    /**
     * Store a service report file and return the relative path.
     */
    public String storeServiceReport(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return null;
        }

        try {
            String originalName = file.getOriginalFilename();
            String extension = "";
            if (originalName != null && originalName.contains(".")) {
                extension = originalName.substring(originalName.lastIndexOf(".")).toLowerCase(Locale.ROOT);
            }

            if (!ALLOWED_EXTENSIONS.contains(extension)) {
                throw new IllegalArgumentException("Unsupported file type. Allowed: PDF, DOC, DOCX, JPG, PNG, XLS, XLSX");
            }

            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String uniqueName = "SR_" + timestamp + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;

            Path targetPath = uploadPath.resolve("service-reports").resolve(uniqueName);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            return "service-reports/" + uniqueName;
        } catch (IOException e) {
            throw new RuntimeException("Failed to store service report file", e);
        }
    }

    /**
     * Delete a previously stored file.
     */
    public void deleteFile(String relativePath) {
        if (relativePath == null || relativePath.isBlank()) {
            return;
        }
        try {
            Path filePath = uploadPath.resolve(relativePath);
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            System.err.println("Failed to delete file: " + relativePath + " - " + e.getMessage());
        }
    }

    /**
     * Get the full path for a stored file (for download/serving).
     */
    public Path getFilePath(String relativePath) {
        return uploadPath.resolve(relativePath).normalize();
    }
}
