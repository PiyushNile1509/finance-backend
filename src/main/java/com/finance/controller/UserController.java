package com.finance.controller;

import com.finance.dto.UserResponse;
import com.finance.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }
    
    @PutMapping("/{userId}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> updateUserStatus(
            @PathVariable Long userId,
            @RequestParam Boolean active) {
        return ResponseEntity.ok(userService.updateUserStatus(userId, active));
    }
}
