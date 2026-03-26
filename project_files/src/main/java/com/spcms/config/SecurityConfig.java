package com.spcms.config;

import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import com.spcms.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.DispatcherType;
import java.util.Collections;

/**
 * Security Configuration with Role-Based Access Control (RBAC).
 *
 * Roles: ADMIN, TECHNICIAN, MANAGER, VIEWER
 * - ADMIN: Full access to all modules
 * - MANAGER: Access to reports, approvals, incidents, monitoring, visitors
 * - TECHNICIAN: Access to monitoring, maintenance, incidents, shift reports, visitors
 * - VIEWER: Read-only access to dashboard and reports
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    @Lazy
    private UserService userService;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .authorizeHttpRequests(auth -> auth
                // Allow JSP Forwards and Errors (Spring Boot 3 / Security 6 requirement)
                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()
                
                // Public access - MUST come first
                .requestMatchers(
                    new AntPathRequestMatcher("/"),
                    new AntPathRequestMatcher("/index.jsp"),
                    new AntPathRequestMatcher("/login"),
                    new AntPathRequestMatcher("/login/**"),
                    new AntPathRequestMatcher("/perform_login"),
                    new AntPathRequestMatcher("/error"),
                    new AntPathRequestMatcher("/error/**"),
                    new AntPathRequestMatcher("/css/**"),
                    new AntPathRequestMatcher("/js/**"),
                    new AntPathRequestMatcher("/images/**"),
                    new AntPathRequestMatcher("/webjars/**"),
                    new AntPathRequestMatcher("/uploads/**")
                ).permitAll()

                // User management - ADMIN only
                .requestMatchers(new AntPathRequestMatcher("/users/**")).hasRole("ADMIN")

                // Visitor Portal - SECURITY, TECHNICIAN, MANAGER, ADMIN
                .requestMatchers(new AntPathRequestMatcher("/visitor-portal/**")).hasAnyRole("SECURITY", "TECHNICIAN", "MANAGER", "ADMIN")

                // Visitor registration and checking - TECHNICIAN or ADMIN
                .requestMatchers(
                    new AntPathRequestMatcher("/visitors/register/**"),
                    new AntPathRequestMatcher("/visitors/checkin/**"),
                    new AntPathRequestMatcher("/visitors/checkout/**")
                ).hasAnyRole("TECHNICIAN", "ADMIN")

                // legacy Visitor Management Dashboard
                .requestMatchers(new AntPathRequestMatcher("/visitors")).hasAnyRole("MANAGER", "ADMIN")

                // Visitor approval and dashboard - MANAGER or ADMIN
                .requestMatchers(
                    new AntPathRequestMatcher("/visitors/approve/**"),
                    new AntPathRequestMatcher("/visitors/reject/**")
                ).hasAnyRole("MANAGER", "ADMIN")

                // Reports generation - TECHNICIAN, MANAGER or ADMIN
                .requestMatchers(
                    new AntPathRequestMatcher("/reports/generate/**"),
                    new AntPathRequestMatcher("/reports/downtime-trend/**"),
                    new AntPathRequestMatcher("/reports/project/**"),
                    new AntPathRequestMatcher("/reports/sla-compliance/**")
                ).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN")

                // Maintenance - TECHNICIAN, MANAGER, ADMIN
                .requestMatchers(new AntPathRequestMatcher("/maintenance/**")).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN")

                // Monitoring - TECHNICIAN, MANAGER, ADMIN
                .requestMatchers(new AntPathRequestMatcher("/monitoring/**")).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN")

                // Incidents - TECHNICIAN, MANAGER, ADMIN, SECURITY
                .requestMatchers(new AntPathRequestMatcher("/incidents/**")).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN", "SECURITY")

                // Shift reports - TECHNICIAN, MANAGER, ADMIN, SECURITY
                .requestMatchers(new AntPathRequestMatcher("/shift-reports/**")).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN", "SECURITY")

                // Alerts - All authenticated
                .requestMatchers(new AntPathRequestMatcher("/alerts/**")).authenticated()

                // Equipment, UPS, Cooling CRUD & UPS Reports - TECHNICIAN, MANAGER, ADMIN
                .requestMatchers(
                    new AntPathRequestMatcher("/ups/new"),
                    new AntPathRequestMatcher("/ups/save"),
                    new AntPathRequestMatcher("/ups/edit/**"),
                    new AntPathRequestMatcher("/ups/delete/**"),
                    new AntPathRequestMatcher("/ups/reports"),
                    new AntPathRequestMatcher("/ups/reports/**")
                ).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN")
                .requestMatchers(
                    new AntPathRequestMatcher("/cooling/new"),
                    new AntPathRequestMatcher("/cooling/save"),
                    new AntPathRequestMatcher("/cooling/edit/**"),
                    new AntPathRequestMatcher("/cooling/delete/**")
                ).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN")
                .requestMatchers(
                    new AntPathRequestMatcher("/equipment/new"),
                    new AntPathRequestMatcher("/equipment/save"),
                    new AntPathRequestMatcher("/equipment/edit/**"),
                    new AntPathRequestMatcher("/equipment/delete/**")
                ).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN")

                // All other pages - authenticated
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login")
                .loginProcessingUrl("/perform_login")
                .successHandler(roleBasedSuccessHandler())
                .failureUrl("/login?error=true")
                .usernameParameter("username")
                .passwordParameter("password")
            )
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login?logout=true")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
                .permitAll()
            );

        return http.build();
    }

    @Bean
    public AuthenticationSuccessHandler roleBasedSuccessHandler() {
        return (HttpServletRequest request, HttpServletResponse response, Authentication authentication) -> {
            String targetUrl = request.getContextPath() + "/dashboard";

            // Record login event and update lastLogin timestamp
            String username = authentication.getName();
            String ipAddress = request.getRemoteAddr();
            userRepository.findByUsername(username).ifPresent(user ->
                userService.recordLogin(user.getUserId(), ipAddress)
            );

            for (GrantedAuthority authority : authentication.getAuthorities()) {
                String role = authority.getAuthority();
                switch (role) {
                    case "ROLE_ADMIN":
                        targetUrl = request.getContextPath() + "/dashboard";
                        break;
                    case "ROLE_MANAGER":
                        targetUrl = request.getContextPath() + "/dashboard";
                        break;
                    case "ROLE_TECHNICIAN":
                        targetUrl = request.getContextPath() + "/monitoring";
                        break;
                    case "ROLE_SECURITY":
                        targetUrl = request.getContextPath() + "/visitor-portal";
                        break;
                    case "ROLE_VIEWER":
                        targetUrl = request.getContextPath() + "/dashboard";
                        break;
                }
            }

            response.sendRedirect(targetUrl);
        };
    }

    @Bean
    public UserDetailsService userDetailsService() {
        return username -> {
            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

            if (!user.getIsActive()) {
                throw new UsernameNotFoundException("User account is deactivated: " + username);
            }

            return new org.springframework.security.core.userdetails.User(
                    user.getUsername(),
                    user.getPassword(),
                    user.getIsActive(),
                    true, true, true,
                    Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()))
            );
        };
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
