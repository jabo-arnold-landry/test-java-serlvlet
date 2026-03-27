package com.spcms.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.resource.NoResourceFoundException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Global exception handler to catch and log all application errors
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Handle missing static resources (e.g. uploaded files that no longer exist)
     * Returns 404 instead of 500.
     */
    @ExceptionHandler(NoResourceFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ModelAndView handleNoResourceFound(HttpServletRequest request, NoResourceFoundException ex) {
        System.err.println("Resource not found: " + request.getRequestURL());

        ModelAndView mav = new ModelAndView("error");
        mav.addObject("errorCode", "404");
        mav.addObject("errorMessage", "The requested resource was not found: " + ex.getResourcePath());
        mav.addObject("url", request.getRequestURL().toString());

        return mav;
    }

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
