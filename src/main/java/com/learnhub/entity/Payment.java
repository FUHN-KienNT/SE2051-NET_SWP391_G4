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

    /**
     * Creates an instance with the supplied values.
     */
    public Payment() {
        this.status = "pending";
        this.paymentMethod = "vnpay";
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param registrationId the registration id identifier
     * @param amount the amount
     * @param paymentMethod the payment method
     * @param transactionId the transaction id identifier
     * @param status the status
     */
    public Payment(UUID id, UUID registrationId, BigDecimal amount, String paymentMethod, String transactionId, String status) {
        this.id = id;
        this.registrationId = registrationId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.transactionId = transactionId;
        this.status = status;
    }

    /**
     * Returns id.
     *
     * @return the id
     */
    public UUID getId() { return id; }
    /**
     * Sets id.
     *
     * @param id the id identifier
     */
    public void setId(UUID id) { this.id = id; }

    /**
     * Returns registration id.
     *
     * @return the registration id
     */
    public UUID getRegistrationId() { return registrationId; }
    /**
     * Sets registration id.
     *
     * @param registrationId the registration id identifier
     */
    public void setRegistrationId(UUID registrationId) { this.registrationId = registrationId; }

    /**
     * Returns amount.
     *
     * @return the amount
     */
    public BigDecimal getAmount() { return amount; }
    /**
     * Sets amount.
     *
     * @param amount the amount
     */
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    /**
     * Returns payment method.
     *
     * @return the payment method
     */
    public String getPaymentMethod() { return paymentMethod; }
    /**
     * Sets payment method.
     *
     * @param paymentMethod the payment method
     */
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    /**
     * Returns transaction id.
     *
     * @return the transaction id
     */
    public String getTransactionId() { return transactionId; }
    /**
     * Sets transaction id.
     *
     * @param transactionId the transaction id identifier
     */
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    /**
     * Returns status.
     *
     * @return the status
     */
    public String getStatus() { return status; }
    /**
     * Sets status.
     *
     * @param status the status
     */
    public void setStatus(String status) { this.status = status; }

    /**
     * Returns created at.
     *
     * @return the created at
     */
    public Timestamp getCreatedAt() { return createdAt; }
    /**
     * Sets created at.
     *
     * @param createdAt the created at
     */
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    /**
     * Returns updated at.
     *
     * @return the updated at
     */
    public Timestamp getUpdatedAt() { return updatedAt; }
    /**
     * Sets updated at.
     *
     * @param updatedAt the updated at
     */
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    /**
     * Returns a string representation of this object.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "Payment{id=" + id + ", amount=" + amount + ", status='" + status + "'}";
    }
}
