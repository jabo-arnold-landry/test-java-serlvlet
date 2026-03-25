package com.spcms.controllers;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;


/**
 * Controller to serve the login page for Spring Security.
 */
@Controller
public class LoginController {

    @GetMapping("/login")
    public String loginPage() {
        return "login";
    }
}
