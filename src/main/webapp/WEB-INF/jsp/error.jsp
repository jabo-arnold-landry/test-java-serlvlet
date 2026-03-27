<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Error</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            margin-top: 50px;
        }
        .error-container {
            max-width: 800px;
            margin: auto;
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .error-code {
            font-size: 48px;
            font-weight: bold;
            color: #dc3545;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">${errorCode}</div>
        <h2>Something went wrong!</h2>
        <p class="text-muted">Error: ${errorMessage}</p>
        
        <c:if test="${not empty exception}">
            <div class="alert alert-danger" style="margin-top: 20px;">
                <strong>Exception Details:</strong>
                <pre style="margin-top: 10px; overflow-x: auto;">${exception}</pre>
            </div>
        </c:if>
        
        <hr>
        <p><a href="${pageContext.request.contextPath}/reports" class="btn btn-primary">Back to Reports</a></p>
    </div>
</body>
</html>
