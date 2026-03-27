# SPCMS - How to Run the Project

This guide provides step-by-step instructions to run the **SmartPower & Cooling Management System (SPCMS)** locally.

## Prerequisites

1.  **Java 17**: This project requires JDK 17 or higher.
2.  **Maven**: For dependency management and building.
3.  **MySQL Database**:
    -   Ensure MySQL is running on port **3307**.
    -   Create a database named **`spcms_db`**.
    -   The application uses user **`root`** with no password by default (check `application.properties` to change).

## Option 1: Run with Maven (Recommended)

Open your terminal in the project root (`e:\test-java-serlvlet`) and run:

```bash
mvn spring-boot:run
```

The server will start on port **8081** by default.

## Option 2: Run with java -jar (Fallback)

If you don't have Maven installed or in your PATH, you can run the pre-built application file directly from the terminal:

```bash
java -jar target/test-java-serlvlet.war
```

## Option 3: Run from your IDE

## Accessing the Application

Once the server has started, you can access the application in your browser at:
`http://localhost:8081`

## Troubleshooting

-   **Database Connection Refused**: Check if MySQL is running on port 3307 and that `spcms_db` exists.
-   **Port 8081 Already in Use**: Change the `server.port` property in `src/main/resources/application.properties`.
-   **404 Not Found**: Ensure you are accessing the correct URL and that JSP files are compiled (Spring Boot handles this with `tomcat-embed-jasper`).
