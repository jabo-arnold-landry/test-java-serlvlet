<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Redirect root to the Spring Boot dashboard
    String contextPath = request.getContextPath();
    response.sendRedirect(contextPath + "/dashboard");
%>
