package com.spcms.controllers;

import com.spcms.models.User;
import com.spcms.services.UserService;
import jakarta.servlet.http.HttpServletRequest;
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
    public String save(@ModelAttribute User user, HttpServletRequest request, RedirectAttributes redirectAttributes) {
        String ipAddress = request.getRemoteAddr();
        if (user.getUserId() != null) {
            userService.updateUser(user, ipAddress);
            redirectAttributes.addFlashAttribute("success", "User updated successfully");
        } else {
            userService.createUser(user, ipAddress);
            redirectAttributes.addFlashAttribute("success", "User created successfully");
        }
        return "redirect:/users";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable("id") Long id, Model model) {
        model.addAttribute("user", userService.getUserById(id)
                .orElseThrow(() -> new RuntimeException("User not found")));
        model.addAttribute("roles", User.Role.values());
        return "users/form";
    }

    @PostMapping("/deactivate/{id}")
    public String deactivate(@PathVariable("id") Long id, RedirectAttributes redirectAttributes) {
        userService.deactivateUser(id);
        redirectAttributes.addFlashAttribute("success", "User deactivated");
        return "redirect:/users";
    }

    @PostMapping("/reactivate/{id}")
    public String reactivate(@PathVariable("id") Long id, RedirectAttributes redirectAttributes) {
        userService.reactivateUser(id);
        redirectAttributes.addFlashAttribute("success", "User reactivated");
        return "redirect:/users";
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable("id") Long id, RedirectAttributes redirectAttributes) {
        try {
            userService.deleteUser(id);
            redirectAttributes.addFlashAttribute("success", "User deleted successfully");
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("error", "Cannot delete user because they are referenced by other records. Please deactivate the user instead.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "An error occurred while deleting the user.");
        }
        return "redirect:/users";
    }

    @GetMapping("/activity/{id}")
    public String activityLog(@PathVariable("id") Long id, Model model) {
        model.addAttribute("user", userService.getUserById(id)
                .orElseThrow(() -> new RuntimeException("User not found")));
        model.addAttribute("logs", userService.getUserActivityLogs(id));
        return "users/activity";
    }
}
