package com.fpt.lms.dto;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.UUID;

public class PaymentRequestDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID registrationId;
    private UUID courseId;
    private String courseTitle;
    private BigDecimal amount;
    private String clientIp;
    private String paymentMethod;
    private String returnUrl;

    public PaymentRequestDTO() {
        this.paymentMethod = "vnpay";
    }

    public UUID getRegistrationId() { return registrationId; }
    public void setRegistrationId(UUID registrationId) { this.registrationId = registrationId; }

    public UUID getCourseId() { return courseId; }
    public void setCourseId(UUID courseId) { this.courseId = courseId; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getClientIp() { return clientIp; }
    public void setClientIp(String clientIp) { this.clientIp = clientIp; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getReturnUrl() { return returnUrl; }
    public void setReturnUrl(String returnUrl) { this.returnUrl = returnUrl; }
}
