package com.fpt.lms.entity;

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
    private User user;
    private Course course;

    public Registration() {
        this.progressPercent = 0;
        this.amount = BigDecimal.ZERO;
        this.status = "enrolled";
        this.paymentStatus = "pending";
    }

    public Registration(UUID id, UUID userId, UUID courseId, BigDecimal amount, UUID paymentMethodId) {
        this();
        this.id = id;
        this.userId = userId;
        this.courseId = courseId;
        this.amount = amount;
        this.paymentMethodId = paymentMethodId;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }

    public UUID getStudentId() { return userId; }
    public void setStudentId(UUID studentId) { this.userId = studentId; }

    public UUID getCourseId() { return courseId; }
    public void setCourseId(UUID courseId) { this.courseId = courseId; }

    public Timestamp getEnrolledAt() { return enrolledAt; }
    public void setEnrolledAt(Timestamp enrolledAt) { this.enrolledAt = enrolledAt; }

    public Timestamp getRegisterDate() { return enrolledAt; }
    public void setRegisterDate(Timestamp registerDate) { this.enrolledAt = registerDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public short getProgressPercent() { return progressPercent; }
    public void setProgressPercent(short progressPercent) { this.progressPercent = progressPercent; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public BigDecimal getTotalFee() { return amount; }
    public void setTotalFee(BigDecimal totalFee) { this.amount = totalFee; }

    public UUID getPaymentMethodId() { return paymentMethodId; }
    public void setPaymentMethodId(UUID paymentMethodId) { this.paymentMethodId = paymentMethodId; }

    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public String getPaymentMethodName() { return paymentMethodName; }
    public void setPaymentMethodName(String paymentMethodName) { this.paymentMethodName = paymentMethodName; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Course getCourse() { return course; }
    public void setCourse(Course course) { this.course = course; }

    @Override
    public String toString() {
        return "Registration{id=" + id + ", userId=" + userId + ", courseId=" + courseId + ", status='" + status + "'}";
    }
}
