package com.spcms.controllers;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * Controller to serve the login page for Spring Security.
 */
@Controller
public class LoginController {

    @GetMapping("/login")
    @ResponseBody
    public String loginPage(HttpServletRequest request) {
        String ctx = request.getContextPath();
        String error = request.getParameter("error");
        String logout = request.getParameter("logout");

        String errorHtml = "";
        if (error != null) {
            errorHtml = """
                <div style="background:rgba(239,68,68,0.12);border:1px solid rgba(239,68,68,0.3);
                            color:#fca5a5;padding:12px 16px;border-radius:10px;margin-bottom:16px;font-size:14px;">
                    ⚠ Invalid username or password. Please try again.
                </div>
                """;
        }
        if (logout != null) {
            errorHtml = """
                <div style="background:rgba(16,185,129,0.12);border:1px solid rgba(16,185,129,0.3);
                            color:#6ee7b7;padding:12px 16px;border-radius:10px;margin-bottom:16px;font-size:14px;">
                    ✓ You have been logged out successfully.
                </div>
                """;
        }

        return """
            <!DOCTYPE html>
            <html>
            <head><title>SPCMS Login</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
            <style>
                body { background: #0a0f1e; color: #f1f5f9; font-family: 'Inter', sans-serif;
                       display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
                .login-card { background: #111827; border: 1px solid rgba(255,255,255,0.08);
                              border-radius: 16px; padding: 32px; max-width: 400px; width: 100%%; }
                .form-control { background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);
                                color: #f1f5f9; border-radius: 10px; padding: 12px 16px; }
                .form-control:focus { background: rgba(255,255,255,0.06); border-color: #3b82f6;
                                      box-shadow: 0 0 0 3px rgba(59,130,246,0.15); color: #f1f5f9; }
                .form-control::placeholder { color: #64748b; }
                .btn-login { width: 100%%; background: linear-gradient(135deg, #3b82f6, #2563eb);
                             border: none; color: white; font-weight: 600; padding: 12px;
                             border-radius: 10px; cursor: pointer; font-size: 15px; }
                .btn-login:hover { box-shadow: 0 6px 24px rgba(59,130,246,0.35); transform: translateY(-1px); }
                .logo { width: 56px; height: 56px; background: linear-gradient(135deg, #3b82f6, #10b981);
                        border-radius: 16px; display: inline-flex; align-items: center;
                        justify-content: center; font-size: 28px; margin-bottom: 16px;
                        box-shadow: 0 0 30px rgba(59,130,246,0.3); }
                .form-label { color: #94a3b8; font-size: 13px; font-weight: 500; }
            </style>
            </head>
            <body>
            <div>
                <div style="text-align:center;margin-bottom:32px;">
                    <div class="logo">⚡</div>
                    <h4 style="font-weight:700;">SmartPower &amp; Cooling</h4>
                    <p style="color:#94a3b8;font-size:13px;">Management System - SPCMS v1.0</p>
                </div>
                <div class="login-card">
                    %s
                    <form action="%s/perform_login" method="post">
                        <div class="mb-3">
                            <label class="form-label">Username</label>
                            <input type="text" class="form-control" name="username" placeholder="Enter your username" required autofocus>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Password</label>
                            <input type="password" class="form-control" name="password" placeholder="Enter your password" required>
                        </div>
                        <button type="submit" class="btn-login">Sign In</button>
                    </form>
                </div>
            </div>
            </body>
            </html>
            """.formatted(errorHtml, ctx);
    }
}
