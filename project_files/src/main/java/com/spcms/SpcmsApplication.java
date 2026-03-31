package com.spcms;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class SpcmsApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(SpcmsApplication.class);
    }

    @Override
    public void onStartup(jakarta.servlet.ServletContext servletContext) throws jakarta.servlet.ServletException {
        super.onStartup(servletContext);

        // Explicitly configure multipart for Smart Tomcat or external deployments
        // where Spring Boot's internal auto-configuration may not attach to the Servlet.
        jakarta.servlet.ServletRegistration dispatcher = servletContext.getServletRegistration("dispatcherServlet");
        if (dispatcher instanceof jakarta.servlet.ServletRegistration.Dynamic) {
            java.io.File tmpDir = new java.io.File(System.getProperty("user.dir"), "tomcat-tmp-dir");
            if (!tmpDir.exists()) {
                tmpDir.mkdirs();
            }
            jakarta.servlet.MultipartConfigElement multipartConfigElement =
                    new jakarta.servlet.MultipartConfigElement(tmpDir.getAbsolutePath(), 52428800L, 52428800L, 0);
            ((jakarta.servlet.ServletRegistration.Dynamic) dispatcher).setMultipartConfig(multipartConfigElement);
        }
    }

    @org.springframework.context.annotation.Bean
    public jakarta.servlet.MultipartConfigElement multipartConfigElement() {
        org.springframework.boot.web.servlet.MultipartConfigFactory factory = new org.springframework.boot.web.servlet.MultipartConfigFactory();
        java.io.File tmpDir = new java.io.File(System.getProperty("user.dir"), "tomcat-tmp-dir");
        if (!tmpDir.exists()) {
            tmpDir.mkdirs();
        }
        factory.setLocation(tmpDir.getAbsolutePath());
        factory.setMaxFileSize(org.springframework.util.unit.DataSize.ofMegabytes(50));
        factory.setMaxRequestSize(org.springframework.util.unit.DataSize.ofMegabytes(50));
        return factory.createMultipartConfig();
    }

    public static void main(String[] args) {
        SpringApplication.run(SpcmsApplication.class, args);
    }

}
