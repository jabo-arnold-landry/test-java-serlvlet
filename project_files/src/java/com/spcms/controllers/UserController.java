package com.spcms.controllers;

import com.spcms.models.User;
import com.spcms.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("users", userService.getAllUsers());
        return "users/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("user", new User());
        model.addAttribute("roles", User.Role.values());
        return "users/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute User user, RedirectAttributes redirectAttributes) {
        userService.createUser(user);
        redirectAttributes.addFlashAttribute("success", "User created successfully");
        return "redirect:/users";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        model.addAttribute("user", userService.getUserById(id)
                .orElseThrow(() -> new RuntimeException("User not found")));
        model.addAttribute("roles", User.Role.values());
        return "users/form";
    }

    @PostMapping("/deactivate/{id}")
    public String deactivate(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        userService.deactivateUser(id);
        redirectAttributes.addFlashAttribute("success", "User deactivated");
        return "redirect:/users";
    }

    @GetMapping("/activity/{id}")
    public String activityLog(@PathVariable Long id, Model model) {
        model.addAttribute("user", userService.getUserById(id)
                .orElseThrow(() -> new RuntimeException("User not found")));
        model.addAttribute("logs", userService.getUserActivityLogs(id));
        return "users/activity";
    }
}
