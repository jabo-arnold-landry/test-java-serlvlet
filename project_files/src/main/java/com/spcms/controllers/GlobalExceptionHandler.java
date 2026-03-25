package com.spcms.controllers;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;
import jakarta.servlet.http.HttpServletRequest;

/**
 * Global exception handler to catch and log all application errors
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ModelAndView handleException(HttpServletRequest request, Exception ex) {
        // Log the full exception
        System.err.println("================== ERROR OCCURRED ==================");
        System.err.println("URL: " + request.getRequestURL());
        System.err.println("Exception Type: " + ex.getClass().getName());
        System.err.println("Message: " + ex.getMessage());
        System.err.println("Full Stack Trace:");
        ex.printStackTrace(System.err);
        System.err.println("===================================================");

        ModelAndView mav = new ModelAndView("error");
        mav.addObject("errorCode", "500");
        mav.addObject("errorMessage", "Internal Server Error: " + ex.getMessage());
        mav.addObject("exception", ex);
        mav.addObject("url", request.getRequestURL().toString());
        
        return mav;
    }
}
