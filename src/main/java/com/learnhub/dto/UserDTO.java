package com.learnhub.dto;

import java.io.Serializable;
import java.util.UUID;

/**
 * Data Transfer Object for transferring user account information between
 * Service, Controller, and JSP presentation layers without exposing sensitive data.
 *
 * @author NguyenLD - System Administration Module
 */
public class UserDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private UUID id;
    private String username;
    private String fullName;
    private String email;
    private UUID roleId;
    private String roleName;
    private String roleCode;
    private String status;
    private String phone;
    private String avatarUrl;
    private String statusNote;

    /**
     * Default no-argument constructor.
     */
    public UserDTO() {
    }

    /**
     * Parameterized constructor for basic user information.
     *
     * @param id       User unique identifier
     * @param username Account login username
     * @param email    Account registered email
     * @param roleId   Setting ID representing user role
     * @param roleName Display name of user role
     * @param status   Account status (active, inactive, locked)
     */
    public UserDTO(UUID id, String username, String email, UUID roleId,
                   String roleName, String status) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.roleId = roleId;
        this.roleName = roleName;
        this.status = status;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public UUID getRoleId() {
        return roleId;
    }

    public void setRoleId(UUID roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getRoleCode() {
        return roleCode;
    }

    public void setRoleCode(String roleCode) {
        this.roleCode = roleCode;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getStatusNote() {
        return statusNote;
    }

    public void setStatusNote(String statusNote) {
        this.statusNote = statusNote;
    }
}
