package com.spcms.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.boot.web.servlet.server.ConfigurableServletWebServerFactory;
import org.springframework.context.annotation.Configuration;

import java.io.File;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/**
 * Ensures embedded Tomcat can resolve JSP files from src/main/webapp
 * when running from IDE/classpath launches.
 */
@Configuration
public class EmbeddedTomcatDocRootConfig implements WebServerFactoryCustomizer<ConfigurableServletWebServerFactory> {

    private static final Logger log = LoggerFactory.getLogger(EmbeddedTomcatDocRootConfig.class);

    @Override
    public void customize(ConfigurableServletWebServerFactory factory) {
        Path webAppDir = resolveWebAppDir();
        if (webAppDir != null) {
            factory.setDocumentRoot(webAppDir.toFile());
            log.info("Using embedded Tomcat document root: {}", webAppDir.toAbsolutePath().normalize());
        } else {
            log.warn("Could not resolve src/main/webapp document root. JSP views may not be found.");
        }
    }

    private Path resolveWebAppDir() {
        List<Path> candidates = new ArrayList<>();

        try {
            Path codeSourcePath = Paths.get(
                    EmbeddedTomcatDocRootConfig.class.getProtectionDomain().getCodeSource().getLocation().toURI()
            );
            if (Files.isDirectory(codeSourcePath) && codeSourcePath.endsWith("classes")) {
                Path projectRoot = codeSourcePath.getParent() != null ? codeSourcePath.getParent().getParent() : null;
                if (projectRoot != null) {
                    candidates.add(projectRoot.resolve("src/main/webapp"));
                }
            }
        } catch (URISyntaxException e) {
            log.debug("Unable to inspect code source path for webapp resolution", e);
        }

        Path userDir = Paths.get(System.getProperty("user.dir", "."));
        candidates.add(userDir.resolve("src/main/webapp"));
        candidates.add(userDir.resolve("project_files/src/main/webapp"));
        if (userDir.getParent() != null) {
            candidates.add(userDir.getParent().resolve("project_files/src/main/webapp"));
        }

        for (Path candidate : candidates) {
            Path normalized = candidate.toAbsolutePath().normalize();
            if (Files.isDirectory(normalized)) {
                File loginJsp = normalized.resolve("WEB-INF/jsp/login.jsp").toFile();
                if (loginJsp.exists()) {
                    return normalized;
                }
            }
        }
        return null;
    }
}

