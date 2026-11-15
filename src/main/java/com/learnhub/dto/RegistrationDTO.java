package com.learnhub.dto;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.UUID;

public class RegistrationDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID userId;
    private String userName;
    private String userEmail;
    private UUID courseId;
    private String courseTitle;
    private BigDecimal amount;
    private String paymentStatus;
    private String status;
    private short progressPercent;
    private Timestamp enrolledAt;
    private String paymentMethod;
    private String transactionId;

    /**
     * Creates an instance with the supplied values.
     */
    public RegistrationDTO() {
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
     * Returns course id.
     *
     * @return the course id
     */
    public UUID getCourseId() { return courseId; }
    /**
     * Sets course id.
     *
     * @param courseId the course id identifier
     */
    public void setCourseId(UUID courseId) { this.courseId = courseId; }

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
}
