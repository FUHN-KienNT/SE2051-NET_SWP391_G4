package com.learnhub.entity;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.UUID;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private UUID id;
    private String username;
    private String fullName;
    private String email;
    private String password;
    private boolean requiresPasswordChange;
    private UUID roleId;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper / joined fields
    private String roleName;
    private String roleCode;
    private String phone;
    private String avatarUrl;
    private String statusNote;

    /**
     * Creates an instance with the supplied values.
     */
    public User() {
    }

    /**
     * Creates an instance with the supplied values.
     *
     * @param id the id identifier
     * @param username the username
     * @param email the email
     * @param password the password
     * @param roleId the role id identifier
     * @param status the status
     */
    public User(UUID id, String username, String email, String password, UUID roleId, String status) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.roleId = roleId;
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
     * Returns username.
     *
     * @return the username
     */
    public String getUsername() { return username; }
    /**
     * Sets username.
     *
     * @param username the username
     */
    public void setUsername(String username) { this.username = username; }

    /**
     * Returns full name.
     *
     * @return the full name
     */
    public String getFullName() { return fullName; }
    /**
     * Sets full name.
     *
     * @param fullName the full name
     */
    public void setFullName(String fullName) { this.fullName = fullName; }

    /**
     * Returns email.
     *
     * @return the email
     */
    public String getEmail() { return email; }
    /**
     * Sets email.
     *
     * @param email the email
     */
    public void setEmail(String email) { this.email = email; }

    /**
     * Returns password.
     *
     * @return the password
     */
    public String getPassword() { return password; }
    /**
     * Sets password.
     *
     * @param password the password
     */
    public void setPassword(String password) { this.password = password; }

    /**
     * Checks whether requires password change.
     *
     * @return true when the condition holds; false otherwise
     */
    public boolean isRequiresPasswordChange() { return requiresPasswordChange; }
    /**
     * Sets requires password change.
     *
     * @param requiresPasswordChange the requires password change
     */
    public void setRequiresPasswordChange(boolean requiresPasswordChange) { this.requiresPasswordChange = requiresPasswordChange; }

    /**
     * Returns role id.
     *
     * @return the role id
     */
    public UUID getRoleId() { return roleId; }
    /**
     * Sets role id.
     *
     * @param roleId the role id identifier
     */
    public void setRoleId(UUID roleId) { this.roleId = roleId; }

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
     * Returns role name.
     *
     * @return the role name
     */
    public String getRoleName() { return roleName; }
    /**
     * Sets role name.
     *
     * @param roleName the role name
     */
    public void setRoleName(String roleName) { this.roleName = roleName; }

    /**
     * Returns role code.
     *
     * @return the role code
     */
    public String getRoleCode() { return roleCode; }
    /**
     * Sets role code.
     *
     * @param roleCode the role code
     */
    public void setRoleCode(String roleCode) { this.roleCode = roleCode; }

    /**
     * Returns phone.
     *
     * @return the phone
     */
    public String getPhone() { return phone; }
    /**
     * Sets phone.
     *
     * @param phone the phone
     */
    public void setPhone(String phone) { this.phone = phone; }

    /**
     * Returns avatar url.
     *
     * @return the avatar url
     */
    public String getAvatarUrl() { return avatarUrl; }
    /**
     * Sets avatar url.
     *
     * @param avatarUrl the avatar url
     */
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    /**
     * Returns status note.
     *
     * @return the status note
     */
    public String getStatusNote() { return statusNote; }
    /**
     * Sets status note.
     *
     * @param statusNote the status note
     */
    public void setStatusNote(String statusNote) { this.statusNote = statusNote; }

    /**
     * Returns a string representation of this object.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "User{id=" + id + ", username='" + username + "', email='" + email + "'}";
    }
}
