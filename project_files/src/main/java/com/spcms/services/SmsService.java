package com.spcms.services;

import com.spcms.models.Visitor;
import org.springframework.stereotype.Service;

@Service
public class SmsService {

    /**
     * Sends an SMS notification to the visitor.
     * Note: This is a placeholder implementation that logs to console.
     * To make it functional, integrate with an SMS gateway like Twilio, Infobip, or Africa's Talking.
     */
    public void sendApprovalSms(Visitor visitor) {
        String phoneNumber = visitor.getPhone();
        if (phoneNumber == null || phoneNumber.isBlank()) {
            System.err.println("Cannot send SMS: No phone number provided for visitor " + visitor.getFullName());
            return;
        }

        String message = String.format(
            "SPCMS: Hello %s, your visit request (Ref: VR-%d) has been APPROVED for %s. " +
            "Please present your ID at the reception. Welcome!",
            visitor.getFullName(),
            visitor.getVisitorId(),
            visitor.getVisitDate()
        );

        // MOCK SENDING LOGIC
        System.out.println("----------------------------------------");
        System.out.println("SENDING SMS TO: " + phoneNumber);
        System.out.println("MESSAGE CONTENT: " + message);
        System.out.println("----------------------------------------");
        
        // TODO: Implement actual API call to SMS Provider
        // Example (Twilio):
        // com.twilio.rest.api.v2010.account.Message.creator(
        //     new com.twilio.type.PhoneNumber(phoneNumber),
        //     new com.twilio.type.PhoneNumber(FROM_NUMBER),
        //     message
        // ).create();
    }
}
