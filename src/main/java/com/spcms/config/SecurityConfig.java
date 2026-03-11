package com.spcms.config;

import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
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

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .authorizeHttpRequests(auth -> auth
                // Public access - MUST come first
                .requestMatchers(
                    new AntPathRequestMatcher("/login"),
                    new AntPathRequestMatcher("/login/**"),
                    new AntPathRequestMatcher("/perform_login"),
                    new AntPathRequestMatcher("/error"),
                    new AntPathRequestMatcher("/error/**"),
                    new AntPathRequestMatcher("/css/**"),
                    new AntPathRequestMatcher("/js/**"),
                    new AntPathRequestMatcher("/images/**"),
                    new AntPathRequestMatcher("/webjars/**"),
                    new AntPathRequestMatcher("/register-visitor"),
                    new AntPathRequestMatcher("/register-visitor/**")
                ).permitAll()

                // User management - ADMIN only
                .requestMatchers(new AntPathRequestMatcher("/users/**")).hasRole("ADMIN")

                // Visitor registration and checking - TECHNICIAN or ADMIN
                .requestMatchers(
                    new AntPathRequestMatcher("/visitors/register/**"),
                    new AntPathRequestMatcher("/visitors/checkin/**"),
                    new AntPathRequestMatcher("/visitors/checkout/**")
                ).hasAnyRole("TECHNICIAN", "ADMIN")

                // Visitor approval and dashboard - MANAGER or ADMIN
                .requestMatchers(
                    new AntPathRequestMatcher("/visitors/approve/**"),
                    new AntPathRequestMatcher("/visitors/reject/**")
                ).hasAnyRole("MANAGER", "ADMIN")

                // Reports generation - MANAGER or ADMIN
                .requestMatchers(
                    new AntPathRequestMatcher("/reports/generate/**"),
                    new AntPathRequestMatcher("/reports/downtime-trend/**")
                ).hasAnyRole("MANAGER", "ADMIN")

                // Maintenance - TECHNICIAN, MANAGER, ADMIN
                .requestMatchers(new AntPathRequestMatcher("/maintenance/**")).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN")

                // Monitoring - TECHNICIAN, MANAGER, ADMIN
                .requestMatchers(new AntPathRequestMatcher("/monitoring/**")).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN")

                // Incidents - TECHNICIAN, MANAGER, ADMIN
                .requestMatchers(new AntPathRequestMatcher("/incidents/**")).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN")

                // Shift reports - TECHNICIAN, MANAGER, ADMIN
                .requestMatchers(new AntPathRequestMatcher("/shift-reports/**")).hasAnyRole("TECHNICIAN", "MANAGER", "ADMIN")

                // Alerts - All authenticated
                .requestMatchers(new AntPathRequestMatcher("/alerts/**")).authenticated()

                // Equipment, UPS, Cooling CRUD - TECHNICIAN, MANAGER, ADMIN
                .requestMatchers(
                    new AntPathRequestMatcher("/ups/new"),
                    new AntPathRequestMatcher("/ups/save"),
                    new AntPathRequestMatcher("/ups/edit/**"),
                    new AntPathRequestMatcher("/ups/delete/**")
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
                .permitAll()
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
                    case "ROLE_VIEWER":
                        targetUrl = request.getContextPath() + "/visitor-portal";
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
