package com.spcms.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class RootController {

    @GetMapping("/")
    public String root() {
        // Spring Security will automatically intercept this and redirect to /login if unauthenticated.
        // If authenticated, it will redirect successfully to /dashboard (or wherever).
        return "redirect:/dashboard";
    }
}
