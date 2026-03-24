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
    public String loginPage(HttpServletRequest request) {
        return "login";
    }
}
