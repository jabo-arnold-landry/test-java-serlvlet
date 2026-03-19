package com.spcms.servlet;

import com.spcms.dao.MaintenanceCostDAO;
import com.spcms.models.MaintenanceCost;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.*;

@WebServlet("/maintenance/cost-analysis")
public class MaintenanceCostAnalysisServlet extends HttpServlet {
    private MaintenanceCostDAO costDAO = new MaintenanceCostDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LocalDate startDate = LocalDate.now().minusMonths(1);
        LocalDate endDate = LocalDate.now();

        String startDateParam = request.getParameter("startDate");
        String endDateParam = request.getParameter("endDate");

        if (startDateParam != null && !startDateParam.isEmpty()) {
            startDate = LocalDate.parse(startDateParam);
        }
        if (endDateParam != null && !endDateParam.isEmpty()) {
            endDate = LocalDate.parse(endDateParam);
        }

        List<MaintenanceCost> allCosts = costDAO.getCostsByDateRange(startDate, endDate);
        double totalCost = costDAO.getTotalCost(startDate, endDate);
        double upsCost = costDAO.getTotalCostByType("UPS", startDate, endDate);
        double coolingCost = costDAO.getTotalCostByType("COOLING", startDate, endDate);
        Map<String, Double> equipmentCosts = costDAO.getCostByEquipmentType(startDate, endDate);

        request.setAttribute("allCosts", allCosts);
        request.setAttribute("totalCost", totalCost);
        request.setAttribute("upsCost", upsCost);
        request.setAttribute("coolingCost", coolingCost);
        request.setAttribute("equipmentCosts", equipmentCosts);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);

        request.getRequestDispatcher("/WEB-INF/jsp/maintenance/cost-analysis.jsp").forward(request, response);
    }
}