<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SPCMS - Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Inter', sans-serif;
            background: #0c1121;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-wrapper {
            width: 100%;
            max-width: 380px;
            padding: 20px;
            text-align: center;
        }

        .logo-icon {
            width: 56px;
            height: 56px;
            border-radius: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 14px;
            overflow: hidden;
            position: relative;
            box-shadow: 0 4px 20px rgba(33, 150, 243, 0.3);
        }

        .logo-icon svg {
            width: 56px;
            height: 56px;
        }

        .brand-title {
            font-size: 24px;
            font-weight: 800;
            color: #ffffff;
            margin-bottom: 4px;
        }

        .brand-sub {
            font-size: 13px;
            color: #5b6785;
            margin-bottom: 24px;
        }

        .login-card {
            background: #131929;
            border-radius: 16px;
            padding: 24px 24px 28px;
            text-align: left;
        }

        .alert {
            border-radius: 8px;
            font-size: 12px;
            padding: 9px 12px;
            margin-bottom: 16px;
        }
        .alert-danger  { background: rgba(239,68,68,0.1);  border: 1px solid rgba(239,68,68,0.25);  color: #f87171; }
        .alert-success { background: rgba(16,185,129,0.1); border: 1px solid rgba(16,185,129,0.25); color: #34d399; }
        .alert-warning { background: rgba(245,158,11,0.1); border: 1px solid rgba(245,158,11,0.25); color: #fbbf24; }

        .field-group { margin-bottom: 16px; }

        .field-label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #c9d1e0;
            margin-bottom: 6px;
        }

        .field-input {
            width: 100%;
            background: #0d1322;
            border: 1.5px solid #1e2a40;
            border-radius: 10px;
            padding: 11px 14px;
            font-size: 13px;
            color: #e2e8f0;
            font-family: 'Inter', sans-serif;
            transition: border-color 0.2s, box-shadow 0.2s;
            outline: none;
        }

        .field-input::placeholder { color: #3a4a65; }

        .field-input:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59,130,246,0.12);
        }

        .btn-signin {
            width: 100%;
            background: linear-gradient(135deg, #4d8ef9 0%, #2563eb 100%);
            border: none;
            border-radius: 10px;
            padding: 13px;
            font-size: 14px;
            font-weight: 700;
            color: #ffffff;
            cursor: pointer;
            font-family: 'Inter', sans-serif;
            margin-top: 6px;
            transition: opacity 0.2s, transform 0.15s, box-shadow 0.2s;
        }

        .btn-signin:hover {
            opacity: 0.9;
            transform: translateY(-1px);
            box-shadow: 0 6px 22px rgba(59,130,246,0.38);
        }

        .btn-signin:active { transform: translateY(0); }
    </style>
</head>
<body>
    <div class="login-wrapper">
        <div class="logo-icon">
            <svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
                <defs>
                    <linearGradient id="bgGrad" x1="0" y1="0" x2="56" y2="56" gradientUnits="userSpaceOnUse">
                        <stop offset="0%" stop-color="#2196f3"/>
                        <stop offset="45%" stop-color="#1e88e5"/>
                        <stop offset="100%" stop-color="#ff6d00"/>
                    </linearGradient>
                </defs>
                <!-- Background rounded rect -->
                <rect width="56" height="56" rx="14" fill="url(#bgGrad)"/>
                <!-- Lightning bolt -->
                <polygon points="31,10 18,30 27,30 25,46 38,26 29,26" fill="white" opacity="0.97"/>
            </svg>
        </div>
        <h1 class="brand-title">SmartPower &amp; Cooling</h1>
        <p class="brand-sub">Management System - SPCMS v1.0</p>

        <div class="login-card">
            <c:if test="${param.error != null}">
                <div class="alert alert-danger">Invalid username or password. Please try again.</div>
            </c:if>
            <c:if test="${param.logout != null}">
                <div class="alert alert-success">You have been successfully logged out.</div>
            </c:if>
            <c:if test="${param.expired != null}">
                <div class="alert alert-warning">Your session has expired. Please log in again.</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/perform_login" method="post">
                <c:if test="${not empty _csrf}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>

                <div class="field-group">
                    <label class="field-label" for="username">Username</label>
                    <input id="username" type="text" class="field-input" name="username"
                           placeholder="Enter your username" required autofocus>
                </div>

                <div class="field-group">
                    <label class="field-label" for="password">Password</label>
                    <input id="password" type="password" class="field-input" name="password"
                           placeholder="Enter your password" required>
                </div>

                <button type="submit" class="btn-signin">Sign In</button>
            </form>
        </div>
    </div>
</body>
</html>
