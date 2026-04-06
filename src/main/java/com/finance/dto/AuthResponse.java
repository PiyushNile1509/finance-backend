package com.finance.dto;

import com.finance.model.Role;

public class AuthResponse {
    private String token;
    private String username;
    private String email;
    private Role role;

    public AuthResponse(String token, String username, String email, Role role) {
        this.token = token;
        this.username = username;
        this.email = email;
        this.role = role;
    }

    public String getToken() { return token; }
    public String getUsername() { return username; }
    public String getEmail() { return email; }
    public Role getRole() { return role; }
}
