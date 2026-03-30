# SPCMS - SmartPower & Cooling Management System

A Spring Boot web application for managing data center infrastructure — UPS systems, cooling units, equipment monitoring, incident tracking, visitor management, and reporting.

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| **JDK** | 17 or higher (21 recommended) | [Download](https://adoptium.net/) |
| **Maven** | 3.8+ | Or use the bundled `mvnw` wrapper |
| **MySQL** | 8.0+ | Required for production |
| **IntelliJ IDEA** | 2023.2+ recommended | Community or Ultimate |
| **Apache Tomcat** | 10.1+ (Jakarta EE) | For external WAR deployment |

---

## Database Setup

1. Install and start MySQL Server
2. Create the database:
   ```sql
   CREATE DATABASE spcms_db;
   ```
3. The default config uses `root` with **no password**. If your setup differs, update `application.properties`:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/spcms_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
   spring.datasource.username=root
   spring.datasource.password=YOUR_PASSWORD
   ```
4. Tables are auto-created by Hibernate (`ddl-auto=update`) on first run.

---

## Getting Started

### 1. Clone & Switch to `dev` Branch
```bash
git clone <repository-url>
cd test-java-serlvlet
git checkout dev
```

### 2. Open in IntelliJ IDEA

> **Important:** Open the `project_files/` subdirectory, NOT the root `test-java-serlvlet/` folder.

- **File → Open** → navigate to `test-java-serlvlet/project_files/`
- Select `pom.xml` → **Open as Project**
- Wait for Maven import to complete

### 3. Configure JDK in IntelliJ
- **File → Project Structure → Project**
- Set **SDK** to your JDK 17+ installation
- Set **Language Level** to 17
- Click **OK**

### 4. Enable Annotation Processing (for Lombok)
- **File → Settings → Build → Compiler → Annotation Processors**
- Check **Enable annotation processing**

### 5. Build
```bash
cd project_files
mvn clean compile
```
Or in IntelliJ: **Build → Rebuild Project**

---

## Running the Application

### Option A: Embedded Spring Boot (Development)
```bash
cd project_files
mvn spring-boot:run
```
Access at: **http://localhost:8081/test-java-serlvlet**

### Option B: External Tomcat (Production)
1. Build the WAR:
   ```bash
   cd project_files
   mvn clean package -DskipTests
   ```
2. Copy `target/spcms_war.war` to Tomcat's `webapps/` directory
3. Start Tomcat
4. Access at: **http://localhost:8080/spcms_war**

### Option C: Smart Tomcat Plugin (IntelliJ)
1. Install the **Smart Tomcat** plugin in IntelliJ
2. Configure a Tomcat run configuration pointing to your Tomcat installation
3. Run from IntelliJ

---

## Default Login

The application seeds a default admin user on first startup:

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `admin` |

> Change the default password after first login.

---

## Project Structure

```
test-java-serlvlet/
└── project_files/              ← This is the project root
    ├── pom.xml                 ← Maven build file
    ├── src/
    │   ├── main/
    │   │   ├── java/com/spcms/
    │   │   │   ├── config/     ← Security, web, data init config
    │   │   │   ├── controllers/← Spring MVC controllers
    │   │   │   ├── dao/        ← JDBC data access objects
    │   │   │   ├── dto/        ← Data transfer objects
    │   │   │   ├── models/     ← JPA entity classes
    │   │   │   ├── repositories/← Spring Data JPA repos
    │   │   │   ├── services/   ← Business logic
    │   │   │   ├── servlet/    ← Legacy servlet components
    │   │   │   └── util/       ← Utility classes
    │   │   ├── resources/
    │   │   │   └── application.properties
    │   │   └── webapp/WEB-INF/jsp/  ← JSP views
    │   └── test/               ← Integration tests
    └── .idea/                  ← IntelliJ config
```

---

## Key Modules

| Module | URL Path | Description |
|--------|----------|-------------|
| Dashboard | `/dashboard` | System overview & statistics |
| UPS Management | `/ups` | UPS unit monitoring & maintenance |
| Cooling Management | `/cooling` | Cooling system tracking |
| Equipment | `/equipment` | Equipment registry |
| Monitoring | `/monitoring` | Real-time monitoring logs |
| Maintenance | `/maintenance` | Maintenance scheduling |
| Incidents | `/incidents` | Incident reporting & resolution |
| Visitors | `/visitors` | Visitor check-in/out |
| Visitor Portal | `/visitor-portal` | Self-service visitor portal |
| Reports | `/reports` | Daily, monthly, quarterly reports |
| Shift Reports | `/shift-reports` | Shift handover reports |
| User Management | `/users` | Admin user CRUD (Admin only) |
| Alerts | `/alerts` | System alerts & notifications |

---

## User Roles

| Role | Access Level |
|------|-------------|
| `ADMIN` | Full access, user management |
| `MANAGER` | Dashboard, reports, all modules except user management |
| `TECHNICIAN` | Monitoring, maintenance, incidents |
| `SECURITY` | Visitor portal |
| `VIEWER` | Read-only dashboard & reports |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `JDK isn't specified for module 'spcms'` | File → Project Structure → Project → set SDK to JDK 17+ |
| `package com.spcms.models does not exist` | Ensure you opened `project_files/` not the root folder |
| `Name for argument of type [java.lang.Long] not specified` | Run `mvn clean compile` — the `-parameters` flag is configured |
| `Cannot connect to MySQL` | Verify MySQL is running and `spcms_db` database exists |
| Lombok getters/setters not found | Enable annotation processing in IntelliJ settings |

---

## Tech Stack

- **Backend:** Spring Boot 3.2.5, Spring Security, Spring Data JPA
- **Frontend:** JSP, Bootstrap 5.3, Bootstrap Icons
- **Database:** MySQL 8.0 (H2 available for testing)
- **Build:** Maven 3.8+
- **Java:** 17+ (compiled with `-parameters` flag)
