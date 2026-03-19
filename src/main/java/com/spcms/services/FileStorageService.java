package com.spcms.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * Service for handling file upload, download, and deletion operations.
 * Files are organized into subdirectories by equipment ID and document type.
 */
@Service
public class FileStorageService {

    @Value("${file.upload-dir:./uploads}")
    private String uploadDir;

    private Path rootLocation;

    @PostConstruct
    public void init() {
        rootLocation = Paths.get(uploadDir).toAbsolutePath().normalize();
        try {
            Files.createDirectories(rootLocation);
        } catch (IOException e) {
            throw new RuntimeException("Could not create upload directory: " + uploadDir, e);
        }
    }

    /**
     * Store a file in a subdirectory organized by equipment ID and document type.
     *
     * @param file         the uploaded file
     * @param equipmentId  the equipment ID for directory organization
     * @param docType      the document type (e.g., "config", "network-diagram", "rack-layout", "maintenance-report", "photos")
     * @return the relative path to the stored file
     */
    public String storeFile(MultipartFile file, Long equipmentId, String docType) {
        if (file == null || file.isEmpty()) {
            return null;
        }

        try {
            String originalFilename = StringUtils.cleanPath(file.getOriginalFilename());

            // Security check: prevent path traversal
            if (originalFilename.contains("..")) {
                throw new RuntimeException("Invalid file path: " + originalFilename);
            }

            // Generate a unique filename to prevent collisions
            String uniqueFilename = UUID.randomUUID().toString().substring(0, 8) + "_" + originalFilename;

            // Create subdirectory: uploads/equipment/{equipmentId}/{docType}/
            Path targetDir = rootLocation.resolve("equipment")
                    .resolve(String.valueOf(equipmentId))
                    .resolve(docType);
            Files.createDirectories(targetDir);

            // Store the file
            Path targetPath = targetDir.resolve(uniqueFilename);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            // Return relative path from upload root
            return rootLocation.relativize(targetPath).toString().replace("\\", "/");
        } catch (IOException e) {
            throw new RuntimeException("Failed to store file: " + file.getOriginalFilename(), e);
        }
    }

    /**
     * Load a file as a Resource for downloading.
     *
     * @param relativePath the relative path from the upload root
     * @return the file as a Resource
     */
    public Resource loadFileAsResource(String relativePath) {
        try {
            Path filePath = rootLocation.resolve(relativePath).normalize();
            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists() && resource.isReadable()) {
                return resource;
            } else {
                throw new RuntimeException("File not found: " + relativePath);
            }
        } catch (MalformedURLException e) {
            throw new RuntimeException("File not found: " + relativePath, e);
        }
    }

    /**
     * Delete a file by its relative path.
     *
     * @param relativePath the relative path from the upload root
     */
    public void deleteFile(String relativePath) {
        if (relativePath == null || relativePath.isBlank()) {
            return;
        }
        try {
            Path filePath = rootLocation.resolve(relativePath).normalize();
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            // Log but don't throw - file deletion failure is not critical
            System.err.println("Warning: Could not delete file: " + relativePath);
        }
    }

    /**
     * Extract the original filename from a stored file path.
     *
     * @param storedPath the stored file path (with UUID prefix)
     * @return the original filename
     */
    public String getOriginalFilename(String storedPath) {
        if (storedPath == null || storedPath.isBlank()) {
            return null;
        }
        String filename = Paths.get(storedPath).getFileName().toString();
        // Remove the UUID prefix (8 chars + underscore)
        int underscoreIdx = filename.indexOf('_');
        if (underscoreIdx > 0 && underscoreIdx <= 9) {
            return filename.substring(underscoreIdx + 1);
        }
        return filename;
    }

    /**
     * Get the file extension from a path.
     *
     * @param path the file path
     * @return the file extension (e.g., "pdf", "png")
     */
    public String getFileExtension(String path) {
        if (path == null) return "";
        int dotIndex = path.lastIndexOf('.');
        return dotIndex > 0 ? path.substring(dotIndex + 1).toLowerCase() : "";
    }
}
