<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Error - SPCMS</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        .error-container { max-width: 600px; margin: 0 auto; }
        .error-code { color: #d32f2f; font-size: 48px; font-weight: bold; }
        .error-message { color: #666; margin: 20px 0; }
        .back-link { color: #1976d2; text-decoration: none; }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">404</div>
        <div class="error-message">
            <h2>Page Not Found</h2>
            <p>The requested resource could not be found.</p>
            <p><a href="<c:url value='/dashboard'/>" class="back-link">Go to Dashboard</a></p>
        </div>
    </div>
</body>
</html>
