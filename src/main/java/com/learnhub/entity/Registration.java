package com.learnhub.entity;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.UUID;

public class Registration implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID userId;
    private UUID courseId;
    private Timestamp enrolledAt;
    private String status;
    private short progressPercent;
    private BigDecimal amount;
    private UUID paymentMethodId;
    private String transactionId;
    private String paymentStatus;
    private Timestamp paidAt;

    // Joined / helper fields
    private String userName;
    private String userEmail;
    private String courseTitle;
    private String paymentMethodName;

    /**
     * Creates an instance with the supplied values.
     */
    public Registration() {
        this.progressPercent = 0;
        this.amount = BigDecimal.ZERO;
        this.status = "enrolled";
        this.paymentStatus = "pending";
    }

    public UUID getId() { return id; }
    /**
     * Sets id.
     *
     * @param id the id identifier
     */
    public void setId(UUID id) { this.id = id; }

    /**
     * Returns user id.
     *
     * @return the user id
     */
    public UUID getUserId() { return userId; }
    /**
     * Sets user id.
     *
     * @param userId the user id identifier
     */
    public void setUserId(UUID userId) { this.userId = userId; }

    public UUID getCourseId() { return courseId; }
    /**
     * Sets course id.
     *
     * @param courseId the course id identifier
     */
    public void setCourseId(UUID courseId) { this.courseId = courseId; }

    /**
     * Returns enrolled at.
     *
     * @return the enrolled at
     */
    public Timestamp getEnrolledAt() { return enrolledAt; }
    /**
     * Sets enrolled at.
     *
     * @param enrolledAt the enrolled at
     */
    public void setEnrolledAt(Timestamp enrolledAt) { this.enrolledAt = enrolledAt; }

    public String getStatus() { return status; }
    /**
     * Sets status.
     *
     * @param status the status
     */
    public void setStatus(String status) { this.status = status; }

    /**
     * Returns progress percent.
     *
     * @return the progress percent
     */
    public short getProgressPercent() { return progressPercent; }
    /**
     * Sets progress percent.
     *
     * @param progressPercent the progress percent
     */
    public void setProgressPercent(short progressPercent) { this.progressPercent = progressPercent; }

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

    public UUID getPaymentMethodId() { return paymentMethodId; }
    /**
     * Sets payment method id.
     *
     * @param paymentMethodId the payment method id identifier
     */
    public void setPaymentMethodId(UUID paymentMethodId) { this.paymentMethodId = paymentMethodId; }

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
     * Returns payment status.
     *
     * @return the payment status
     */
    public String getPaymentStatus() { return paymentStatus; }
    /**
     * Sets payment status.
     *
     * @param paymentStatus the payment status
     */
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    /**
     * Returns paid at.
     *
     * @return the paid at
     */
    public Timestamp getPaidAt() { return paidAt; }
    /**
     * Sets paid at.
     *
     * @param paidAt the paid at
     */
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }

    /**
     * Returns user name.
     *
     * @return the user name
     */
    public String getUserName() { return userName; }
    /**
     * Sets user name.
     *
     * @param userName the user name
     */
    public void setUserName(String userName) { this.userName = userName; }

    /**
     * Returns user email.
     *
     * @return the user email
     */
    public String getUserEmail() { return userEmail; }
    /**
     * Sets user email.
     *
     * @param userEmail the user email
     */
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    /**
     * Returns course title.
     *
     * @return the course title
     */
    public String getCourseTitle() { return courseTitle; }
    /**
     * Sets course title.
     *
     * @param courseTitle the course title
     */
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    /**
     * Returns payment method name.
     *
     * @return the payment method name
     */
    public String getPaymentMethodName() { return paymentMethodName; }
    /**
     * Sets payment method name.
     *
     * @param paymentMethodName the payment method name
     */
    public void setPaymentMethodName(String paymentMethodName) { this.paymentMethodName = paymentMethodName; }

    @Override
    public String toString() {
        return "Registration{id=" + id + ", userId=" + userId + ", courseId=" + courseId + ", status='" + status + "'}";
    }
}
