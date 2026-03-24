# Technical Report for IT Administrator
## Smart Power & Cooling Management System (SPCMS)

**Report Date:** March 18, 2026  
**Project:** SPCMS - Smart Power & Cooling Management System  
**Target Audience:** IT Administrator (System Administrator Role)  
**Compliance:** Project documentation for compliance & auditing purposes

---

## Executive Summary

The Smart Power & Cooling Management System (SPCMS) is a Spring Boot-based Java web application deployed on Apache Tomcat 10.1, designed to monitor and manage critical infrastructure components including UPS systems, cooling units, and IT equipment with real-time load monitoring, incident tracking, and automated reporting.

---

## 1. System Architecture & Technology Stack

### 1.1 Technology Stack
| Component | Technology | Version |
|-----------|-----------|---------|
| **Framework** | Spring Boot | 3.x |
| **ORM** | Hibernate (JPA) | 6.x |
| **Database** | Relational (MySQL/PostgreSQL compatible) | Latest stable |
| **Web Server** | Apache Tomcat | 10.1.x |
| **Security** | Spring Security | 6.x (Role-Based Access Control) |
| **Build Tool** | Maven | 3.8+ |
| **Java Version** | JDK 21 (target compatibility) | 21+ |
| **Frontend** | JSP, Bootstrap, JavaScript (ES6+) | Legacy + Modern |

### 1.2 System Architecture Layers
```
Presentation Layer (JSP Views / Web UI)
      ↓
Controller Layer (Spring MVC @Controller)
      ↓
Service Layer (Business Logic & Data Processing)
      ↓
Repository Layer (JPA/Hibernate ORM)
      ↓
Database Layer (Persistent Data Storage)
```

---

## 2. Infrastructure & Deployment

### 2.1 Deployment Environment
- **Server:** Apache Tomcat 10.1.x
- **Port:** 8080 (configurable)
- **Context Path:** `/spcms`
- **Configuration Location:** `./conf/server.xml`, `./conf/context.xml`
- **Log Directory:** `./logs/` (Tomcat async file handler rotation: 90 days)

### 2.2 Database Configuration
- **Connection Pool:** HikariCP (via Spring Boot default)
- **Schema Initialization:** Automatic DDL (spring.jpa.hibernate.ddl-auto)
- **Location:** `src/main/resources/schema_reference.sql` (reference schema)

### 2.3 System Startup Process
1. Tomcat starts and loads SPCMS WAR application
2. Spring Boot auto-configuration initializes DataSource
3. Hibernate auto-generates/updates database schema
4. `DataInitializer` component seeds default users (admin, technician, manager)
5. Application is ready to serve HTTP requests

---

## 3. Security & Access Control

### 3.1 Authentication
- **Mechanism:** Form-based login with Spring Security
- **Password Encoding:** BCrypt with 10 rounds
- **Session Management:** HTTP Session with JSESSIONID cookies
- **Logout:** Invalidates session and deletes cookies

### 3.2 Role-Based Access Control (RBAC)
| Role | Permissions | Key Endpoints |
|------|-----------|---------------|
| **ADMIN** | Full system access (all modules, user management) | `/users/**`, `/reports/generate/**`, `/maintenance/**` |
| **MANAGER** | Report generation, visitor approvals, incident tracking | `/reports/**`, `/visitors/approve/**` |
| **TECHNICIAN** | Monitoring, maintenance, incidents, shift reports | `/monitoring/**`, `/maintenance/**`, `/incidents/**` |
| **VIEWER** | Read-only dashboard and reports | `/dashboard`, `/reports` |

### 3.3 Security Configuration
- **CSRF Protection:** Disabled (API requirement; consider enabling for UI-only deployments)
- **HTTPS:** Not enforced at application level (configure at reverse proxy/load balancer)
- **Default Credentials:** (Must be changed post-deployment)
  - Admin: `admin` / `admin123`
  - Manager: `manager` / `manager123`
  - Technician: `technician` / `tech123`

---

## 4. System Components & Responsibilities

### 4.1 Core Models
| Entity | Purpose | Key Fields |
|--------|---------|-----------|
| **User** | System users with roles and permissions | username, email, role, isActive |
| **Equipment** | IT infrastructure (servers, network devices) | name, location, maintenanceReportPath |
| **UPS** | Uninterruptible Power Supplies | model, capacity, batteryCount, serviceReportPath |
| **UpsBattery** | UPS battery modules | model, installDate, nextReplacementDate |
| **CoolingUnit** | Air conditioning/cooling systems | model, capacity, serviceReportPath |
| **MonitoringLog** | Real-time sensor data (load %, temperature) | equipmentType, loadPercentage, temperature, recordedAt |
| **Alert** | System alerts for threshold breaches | title, severity, equipment, resolvedAt |
| **Incident** | Equipment failures & downtime tracking | description, downtimeDurationMin, reportedBy, resolvedAt |
| **ShiftReport** | Shift-based operational summary | shiftDate, shiftType, avgLoad, downtimeDurationMin |
| **DailyConsolidatedReport** | Daily aggregated metrics | reportDate, avgDailyLoad, mttrMinutes, mtbfHours |

### 4.2 Service Layer Responsibilities
- **ReportService:** Generates daily/shift reports, calculates MTTR (Mean Time To Repair), MTBF (Mean Time Between Failures)
- **UpsReportService:** UPS-specific metrics and CSV export
- **UserService:** User CRUD, role assignment, password management
- **MonitoringService:** Log collection, threshold monitoring (if implemented)
- **IncidentService:** Incident tracking, downtime aggregation

### 4.3 Controller Endpoints (HTTP API)
| Controller | Base Path | Key Methods |
|-----------|-----------|-----------|
| **DashboardController** | `/dashboard` | GET → Real-time metrics dashboard |
| **ReportController** | `/reports` | GET daily/range/trend reports |
| **UpsReportController** | `/ups/report` | GET UPS metrics, CSV export |
| **IncidentController** | `/incidents` | CRUD for incidents |
| **MaintenanceController** | `/maintenance` | Log maintenance activities |
| **UserController** | `/users` | CRUD for user management (ADMIN only) |
| **VisitorController** | `/visitors` | Visitor check-in/check-out approval |

---

## 5. Data Flow & Processing

### 5.1 Report Generation Flow
```
Monitoring Logs (MonitoringLog entity)
    ↓
ReportService.generateDailyReport(date)
    ↓
Calculation (ReportCalculationUtil):
  - Avg Daily Load from load_percentage readings
  - Avg Room Temperature from temperature readings
  - Total Incidents & Downtime from Incident records
  - MTTR = Total Downtime Min / Total Incidents
  - MTBF = Hours in Day / (Total Incidents + 1)
    ↓
DailyConsolidatedReport (saved to DB)
    ↓
Retrieve via /reports endpoints → Display in reports/daily.jsp
```

### 5.2 Incident & Downtime Tracking
- Technicians log incidents via `/incidents/new`
- Each incident records:
  - Equipment affected
  - Start time, resolution time (downtime duration in minutes)
  - Root cause, resolution notes
- ReportService aggregates downtime per day/shift
- Displayed in dashboard alerts and daily reports

---

## 6. Database Schema (Reference)

Key tables (auto-generated by Hibernate, reference at `schema_reference.sql`):
- `users` - System users
- `equipment`, `ups`, `cooling_units` - Asset inventory
- `monitoring_logs` - Real-time sensor readings
- `incidents` - Equipment failures & downtime events
- `shift_reports`, `daily_consolidated_reports` - Aggregated metrics
- `alerts` - System alerts
- `visitor_check_ins`, `visit_approvals` - Visitor management

---

## 7. Compliance & Audit

### 7.1 Activity Logging
- **Login/Logout Events:** Tracked via Spring Security (logs visible in application logs)
- **User Management:** All user create/edit/delete via `/users/**` (ADMIN only) logged
- **Report Generation:** Access to restricted reports (`/reports/generate/**`) requires MANAGER/ADMIN role
- **Incident Creation/Modification:** Tracked with user attribution (reportedBy, lastModifiedBy fields in models)

### 7.2 Data Security Recommendations
1. **Enable HTTPS** in production (configure at Tomcat or reverse proxy)
2. **Rotate Default Credentials** immediately after deployment
3. **Database Encryption:** Enable encryption-at-rest for sensitive data
4. **Backup Strategy:** Regular database backups recommended
5. **Access Logs:** Monitor `./logs/localhost_access_log.*.txt` for unauthorized access attempts

### 7.3 Compliance Checklist
- ✅ Role-Based Access Control (RBAC) implemented
- ✅ User authentication (Spring Security + BCrypt)
- ✅ Audit trail for report generation (role-restricted endpoints)
- ✅ Session management with logout capability
- ⚠️ HTTPS/TLS - Not enforced at application level (configure externally)
- ⚠️ Data encryption - Configure via database or application settings
- 📋 Regular backup/disaster recovery - Recommended practice

---

## 8. Operational Procedures

### 8.1 Application Startup
```bash
cd d:\Academic_Class\test-java-serlvlet
mvn clean package
# Deploy target/spcms.war to Tomcat webapps/
# Or use IDE smart-tomcat plugin
```

### 8.2 Monitoring Health
- **Access:** http://localhost:8080/spcms/dashboard
- **Logs:** `./logs/localhost_access_log.*.txt` (Tomcat rotates daily)
- **Database:** Check spring.jpa logs in console output

### 8.3 User Management
- **Add User:** Login as admin → `/users` → Create new user
- **Reset Password:** Admin can edit user → reset via `/users/edit/{id}`
- **Disable User:** Set `isActive = false` on user record

### 8.4 Troubleshooting
| Issue | Likely Cause | Solution |
|-------|------------|---------|
| 403 Forbidden on `/reports/generate` | User lacks MANAGER/ADMIN role | Verify user role in database or assign via admin panel |
| Database connection error | DB unavailable or wrong credentials | Check `application.properties` database URL/credentials |
| JSP rendering errors | Missing dependencies or Tomcat version mismatch | Ensure JSP taglibs are in classpath (pom.xml: jstl, spring-security-taglibs) |
| Login loop | Session misconfiguration | Clear cookies, check `SecurityConfig.java` CSRF/session settings |

---

## 9. Maintenance & Support

### 9.1 Regular Maintenance Tasks
- **Weekly:** Review logs for errors or unauthorized access
- **Monthly:** Verify backup integrity, test disaster recovery
- **Quarterly:** Update dependencies (Spring Boot, Hibernate security patches)
- **Annually:** Security audit, penetration testing (recommended)

### 9.2 Support Contacts
- **Technical Issues:** Development team (GitHub: jabo-arnold-landry/test-java-serlvlet)
- **Database:** Database administrator (verify connection pool settings in `application.properties`)
- **Infrastructure:** IT Operations (Tomcat deployment & HTTPS configuration)

### 9.3 Change Log
- See [CHANGELOG.md](../CHANGELOG.md) for versioned release notes.

---

## 10. Conclusion

SPCMS is a role-based, Spring Boot-powered infrastructure management system with comprehensive reporting, audit capability, and operational oversight. IT Administrators must ensure:
1. Default credentials are changed immediately post-deployment
2. HTTPS/TLS is configured at the infrastructure level
3. Regular backups and disaster recovery procedures are in place
4. Log monitoring and access control reviews are conducted periodically

For further assistance, consult the code documentation or contact the development team.

---

**Document Version:** 1.0  
**Last Updated:** March 18, 2026  
**Classification:** Internal - Technical Documentation
