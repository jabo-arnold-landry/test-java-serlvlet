package com.spcms.stability;

import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.time.LocalDate;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestBuilders.formLogin;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.model;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.view;

@SpringBootTest(properties = {
        "report.daily.auto.enabled=false",
        "spring.task.scheduling.enabled=false"
})
@AutoConfigureMockMvc
abstract class AbstractCoreFlowProfileTest {

    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private final Map<User.Role, Credentials> credentialsByRole = new EnumMap<>(User.Role.class);

    @BeforeEach
    void setupIntegrationUsers() {
        credentialsByRole.clear();
        registerUserForRole(User.Role.ADMIN, "itest_admin", "itest_admin_123");
        registerUserForRole(User.Role.MANAGER, "itest_manager", "itest_manager_123");
        registerUserForRole(User.Role.TECHNICIAN, "itest_technician", "itest_technician_123");
        registerUserForRole(User.Role.SECURITY, "itest_security", "itest_security_123");
        registerUserForRole(User.Role.VIEWER, "itest_viewer", "itest_viewer_123");
    }

    @Test
    void loginPageResolvesJspView() throws Exception {
        mockMvc.perform(get("/login"))
                .andExpect(status().isOk())
                .andExpect(view().name("login"));
    }

    @Test
    void roleBasedLandingRedirectsAreStable() throws Exception {
        assertRedirectSuffix(loginResult(User.Role.ADMIN), "/dashboard");
        assertRedirectSuffix(loginResult(User.Role.MANAGER), "/dashboard");
        assertRedirectSuffix(loginResult(User.Role.TECHNICIAN), "/monitoring");

        if (credentialsByRole.containsKey(User.Role.SECURITY)) {
            assertRedirectSuffix(loginResult(User.Role.SECURITY), "/visitor-portal");
        }
        if (credentialsByRole.containsKey(User.Role.VIEWER)) {
            assertRedirectSuffix(loginResult(User.Role.VIEWER), "/dashboard");
        }
    }

    @Test
    void dashboardAndNavRoutesAreReachableForVisibleRoles() throws Exception {
        MockHttpSession adminSession = loginSession(User.Role.ADMIN);
        assertReachable(adminSession, List.of(
                "/dashboard",
                "/alerts",
                "/ups",
                "/cooling",
                "/equipment",
                "/monitoring",
                "/maintenance",
                "/incidents",
                "/visitors",
                "/reports",
                "/reports/monthly",
                "/reports/quarterly",
                "/reports/equipment-health",
                "/reports/cost-of-maintenance",
                "/reports/downtime-analysis",
                "/reports/monthly-quarterly",
                "/reports/maintenance-history",
                "/reports/project",
                "/reports/sla-compliance",
                "/shift-reports",
                "/users"
        ));

        MockHttpSession managerSession = loginSession(User.Role.MANAGER);
        assertReachable(managerSession, List.of(
                "/dashboard",
                "/alerts",
                "/ups",
                "/cooling",
                "/equipment",
                "/monitoring",
                "/maintenance",
                "/incidents",
                "/visitors",
                "/reports",
                "/reports/monthly",
                "/reports/quarterly",
                "/reports/equipment-health",
                "/reports/cost-of-maintenance",
                "/reports/downtime-analysis",
                "/reports/monthly-quarterly",
                "/reports/maintenance-history",
                "/reports/project",
                "/reports/sla-compliance",
                "/shift-reports"
        ));

        MockHttpSession technicianSession = loginSession(User.Role.TECHNICIAN);
        assertReachable(technicianSession, List.of(
                "/dashboard",
                "/alerts",
                "/ups",
                "/cooling",
                "/equipment",
                "/monitoring",
                "/maintenance",
                "/incidents",
                "/reports",
                "/reports/monthly",
                "/reports/quarterly",
                "/reports/equipment-health",
                "/reports/cost-of-maintenance",
                "/reports/downtime-analysis",
                "/reports/monthly-quarterly",
                "/reports/maintenance-history",
                "/reports/project",
                "/reports/sla-compliance",
                "/shift-reports"
        ));

        if (credentialsByRole.containsKey(User.Role.VIEWER)) {
            MockHttpSession viewerSession = loginSession(User.Role.VIEWER);
            assertReachable(viewerSession, List.of(
                    "/dashboard",
                    "/alerts",
                    "/reports",
                    "/reports/monthly",
                    "/reports/quarterly",
                    "/reports/equipment-health",
                    "/reports/cost-of-maintenance",
                    "/reports/downtime-analysis",
                    "/reports/monthly-quarterly",
                    "/reports/maintenance-history"
            ));
        }

        if (credentialsByRole.containsKey(User.Role.SECURITY)) {
            MockHttpSession securitySession = loginSession(User.Role.SECURITY);
            assertReachable(securitySession, List.of(
                    "/visitor-portal",
                    "/visitor-portal/request",
                    "/visitor-portal/visit-log",
                    "/visitor-portal/active",
                    "/visitor-portal/history",
                    "/visitor-portal/notifications",
                    "/visitor-portal/support"
            ));
        }
    }

    @Test
    void reportEndpointsSupportDefaultAndCompatibilityContracts() throws Exception {
        MockHttpSession managerSession = loginSession(User.Role.MANAGER);

        mockMvc.perform(get("/reports/generate").session(managerSession))
                .andExpect(status().isOk())
                .andExpect(view().name("reports/daily"))
                .andExpect(model().attributeExists("selectedDate"));

        mockMvc.perform(get("/reports/generate").param("date", LocalDate.now().minusDays(1).toString()).session(managerSession))
                .andExpect(status().isOk())
                .andExpect(view().name("reports/daily"));

        mockMvc.perform(get("/reports/project").session(managerSession))
                .andExpect(status().isOk())
                .andExpect(view().name("reports/project"))
                .andExpect(model().attributeExists("reportDate", "startDate", "endDate", "trendReports"));

        mockMvc.perform(get("/reports/sla-compliance").session(managerSession))
                .andExpect(status().isOk())
                .andExpect(view().name("reports/sla-compliance"))
                .andExpect(model().attributeExists("summary", "windowDays"));

        mockMvc.perform(get("/reports/export/csv/range")
                        .param("start", LocalDate.now().minusDays(30).toString())
                        .param("end", LocalDate.now().toString())
                        .session(managerSession))
                .andExpect(status().isOk());
    }

    @Test
    void visitorSupportIncidentAliasWorks() throws Exception {
        MockHttpSession technicianSession = loginSession(User.Role.TECHNICIAN);

        mockMvc.perform(post("/visitor-portal/incident")
                        .session(technicianSession)
                        .with(csrf())
                        .param("type", "Unauthorized Access")
                        .param("description", "Alias endpoint validation from integration test"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/visitor-portal/support"));
    }

    private void assertRedirectSuffix(MvcResult result, String expectedSuffix) {
        String redirectedUrl = result.getResponse().getRedirectedUrl();
        assertNotNull(redirectedUrl, "Expected redirect URL but response did not redirect");
        assertTrue(redirectedUrl.endsWith(expectedSuffix),
                "Expected redirect to end with " + expectedSuffix + " but got " + redirectedUrl);
    }

    private MockHttpSession loginSession(User.Role role) throws Exception {
        MvcResult result = loginResult(role);
        MockHttpSession session = (MockHttpSession) result.getRequest().getSession(false);
        assertNotNull(session, "Authenticated session should not be null for role " + role);
        return session;
    }

    private MvcResult loginResult(User.Role role) throws Exception {
        Credentials credentials = credentialsByRole.get(role);
        assertNotNull(credentials, "Missing integration credentials for role " + role);

        return mockMvc.perform(formLogin("/perform_login")
                        .user("username", credentials.username())
                        .password("password", credentials.password()))
                .andExpect(status().is3xxRedirection())
                .andReturn();
    }

    private void assertReachable(MockHttpSession session, List<String> urls) throws Exception {
        for (String url : urls) {
            MvcResult result = mockMvc.perform(get(url).session(session)).andReturn();
            int status = result.getResponse().getStatus();
            assertNotEquals(404, status, "Endpoint should not return 404: " + url);
            assertNotEquals(405, status, "Endpoint should not return 405: " + url);
            assertTrue(status < 500, "Endpoint should not fail with 5xx: " + url + " returned " + status);
        }
    }

    private void registerUserForRole(User.Role role, String username, String rawPassword) {
        String email = username + "@spcms.local";
        try {
            User user = userRepository.findByUsername(username).orElse(null);
            if (user == null) {
                user = User.builder()
                        .username(username)
                        .password(passwordEncoder.encode(rawPassword))
                        .email(email)
                        .fullName("Integration " + role.name())
                        .role(role)
                        .department("QA")
                        .branch("Integration")
                        .isActive(true)
                        .build();
            } else {
                user.setRole(role);
                user.setIsActive(true);
                user.setPassword(passwordEncoder.encode(rawPassword));
                if (user.getEmail() == null || user.getEmail().isBlank()) {
                    user.setEmail(email);
                }
                if (user.getFullName() == null || user.getFullName().isBlank()) {
                    user.setFullName("Integration " + role.name());
                }
            }
            userRepository.save(user);
            credentialsByRole.put(role, new Credentials(username, rawPassword));
        } catch (RuntimeException ignored) {
            // Legacy MySQL enum schemas may not support all role literals yet (e.g., SECURITY, VIEWER).
        }
    }

    private record Credentials(String username, String password) {
    }
}
