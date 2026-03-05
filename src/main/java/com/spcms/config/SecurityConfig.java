package com.spcms.config;

import org.springframework.context.annotation.Configuration;

/**
 * Security Configuration Placeholder.
 * 
 * TODO: Integrate Spring Security with role-based access control.
 * Roles: ADMIN, TECHNICIAN, MANAGER, VIEWER
 * 
 * For now, all endpoints are open so students can develop without
 * authentication blocking their work. When Spring Security starter
 * is added, configure:
 *   - Form-based login
 *   - Role-based URL authorization
 *   - Session management
 *   - HTTPS enforcement
 */
@Configuration
public class SecurityConfig {
    // Spring Security is NOT on the classpath yet.
    // When added, implement WebSecurityConfigurerAdapter or
    // SecurityFilterChain bean here.
}
