<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Visitor Registration</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-primary: #0a0f1e;
            --bg-secondary: #111827;
            --border-color: rgba(255,255,255,0.08);
            --accent-blue: #3b82f6;
            --accent-green: #10b981;
            --text-primary: #f1f5f9;
            --text-muted: #94a3b8;
        }
        * { box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background-image:
                radial-gradient(ellipse at 80% 80%, rgba(59,130,246,0.08) 0%, transparent 60%),
                radial-gradient(ellipse at 20% 20%, rgba(16,185,129,0.06) 0%, transparent 50%);
        }
        .login-container { width: 100%; max-width: 500px; padding: 20px; }
        .login-brand { text-align: center; margin-bottom: 32px; }
        .login-brand h4 { font-weight: 700; font-size: 22px; margin: 0 0 4px 0; }
        .login-brand p { color: var(--text-muted); font-size: 13px; margin: 0; }
        .login-card { background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: 16px; padding: 32px; }
        .form-label { color: var(--text-muted); font-size: 13px; font-weight: 500; margin-bottom: 6px; }
        .form-control { background: rgba(255,255,255,0.04); border: 1px solid var(--border-color); color: var(--text-primary); border-radius: 10px; padding: 10px 14px; font-size: 14px; transition: border-color 0.2s, box-shadow 0.2s; }
        .form-control:focus { background: rgba(255,255,255,0.06); border-color: var(--accent-blue); box-shadow: 0 0 0 3px rgba(59,130,246,0.15); color: var(--text-primary); outline: none; }
        .form-control::placeholder { color: var(--text-muted); }
        .btn-login { width: 100%; background: linear-gradient(135deg, var(--accent-blue), #2563eb); border: none; color: white; font-weight: 600; padding: 12px; border-radius: 10px; font-size: 14px; cursor: pointer; transition: transform 0.1s, box-shadow 0.2s; margin-top: 16px; }
        .btn-login:hover { transform: translateY(-1px); box-shadow: 0 6px 24px rgba(59,130,246,0.35); }
        .alert { border-radius: 10px; font-size: 13px; padding: 10px 14px; margin-bottom: 16px; }
        .alert-danger { background: rgba(239,68,68,0.08); border: 1px solid rgba(239,68,68,0.25); color: #f87171; }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-brand">
            <h4>Register to Visit</h4>
            <p>Create an account to submit visit requests</p>
        </div>

        <div class="login-card">
            <c:if test="${not empty error}">
                <div class="alert alert-danger"><i class="bi bi-exclamation-circle"></i> ${error}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/register-visitor" method="post">
                <c:if test="${not empty _csrf}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>

                <div class="mb-3">
                    <label class="form-label">Full Name</label>
                    <input type="text" class="form-control" name="fullName" placeholder="John Doe" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Email Address</label>
                    <input type="email" class="form-control" name="email" placeholder="john@example.com" required>
                </div>
                <div class="row">
                    <div class="col-6 mb-3">
                        <label class="form-label">Username</label>
                        <input type="text" class="form-control" name="username" placeholder="johndoe" required>
                    </div>
                    <div class="col-6 mb-3">
                        <label class="form-label">Password</label>
                        <input type="password" class="form-control" name="password" placeholder="••••••••" required>
                    </div>
                </div>

                <button type="submit" class="btn-login"><i class="bi bi-person-plus"></i> Create Account</button>
                <div class="text-center mt-3">
                    <a href="${pageContext.request.contextPath}/login" style="color: var(--text-muted); text-decoration: none; font-size: 13px;">Already have an account? Sign In</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
