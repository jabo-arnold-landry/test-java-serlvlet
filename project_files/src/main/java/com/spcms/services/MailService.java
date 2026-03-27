package com.spcms.services;

import com.spcms.models.Visitor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class MailService {

    @Autowired
    private JavaMailSender mailSender;

    public void sendApprovalEmail(Visitor visitor) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(visitor.getVisitorEmail());
        message.setSubject("Visit Request Approved - SPCMS");
        
        StringBuilder text = new StringBuilder();
        text.append("Dear ").append(visitor.getFullName()).append(",\n\n");
        text.append("We are pleased to inform you that your visit request has been APPROVED.\n\n");
        text.append("Visit Details:\n");
        text.append("- Reference: VR-").append(visitor.getVisitorId()).append("\n");
        text.append("- Date: ").append(visitor.getVisitDate()).append("\n");
        text.append("- Company: ").append(visitor.getCompany()).append("\n");
        text.append("- Department: ").append(visitor.getDepartmentToVisit()).append("\n");
        if (visitor.getArrivalTime() != null) {
            text.append("- Expected Time: ").append(visitor.getArrivalTime()).append("\n");
        }
        text.append("\nUpon arrival, please present your Identification (ID/Passport: ")
            .append(visitor.getNationalIdPassport()).append(") at the reception desk to receive your temporary badge.\n\n");
        text.append("Thank you,\n");
        text.append("SPCMS Administration");

        message.setText(text.toString());
        
        try {
            mailSender.send(message);
        } catch (Exception e) {
            // Log error but don't fail the approval process
            System.err.println("Failed to send approval email to " + visitor.getVisitorEmail() + ": " + e.getMessage());
        }
    }
}
