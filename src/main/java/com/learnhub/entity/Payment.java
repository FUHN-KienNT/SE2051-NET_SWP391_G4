package com.learnhub.entity;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.UUID;

public class Payment implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID registrationId;
    private BigDecimal amount;
    private String paymentMethod;
    private String transactionId;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Payment() {
        this.status = "pending";
        this.paymentMethod = "vnpay";
    }

    public Payment(UUID id, UUID registrationId, BigDecimal amount, String paymentMethod, String transactionId, String status) {
        this.id = id;
        this.registrationId = registrationId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.transactionId = transactionId;
        this.status = status;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getRegistrationId() { return registrationId; }
    public void setRegistrationId(UUID registrationId) { this.registrationId = registrationId; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "Payment{id=" + id + ", amount=" + amount + ", status='" + status + "'}";
    }
}
