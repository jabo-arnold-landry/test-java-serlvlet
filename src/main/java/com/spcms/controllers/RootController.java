package com.spcms.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class RootController {

    @GetMapping("/")
    public String root() {
        // Removed explicit redirect:/dashboard. Let Spring Security handle the root path redirection naturally.
        return "redirect:/dashboard";
    }
}
