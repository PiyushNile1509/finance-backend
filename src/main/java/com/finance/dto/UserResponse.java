package com.finance.dto;

import com.finance.model.Role;

import java.time.LocalDateTime;

public class UserResponse {
    private Long id;
    private String username;
    private String email;
    private Role role;
    private Boolean active;
    private LocalDateTime createdAt;

    public UserResponse(Long id, String username, String email, Role role, Boolean active, LocalDateTime createdAt) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.role = role;
        this.active = active;
        this.createdAt = createdAt;
    }

    public Long getId() { return id; }
    public String getUsername() { return username; }
    public String getEmail() { return email; }
    public Role getRole() { return role; }
    public Boolean getActive() { return active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
