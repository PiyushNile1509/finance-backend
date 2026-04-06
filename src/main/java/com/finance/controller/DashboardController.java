package com.finance.controller;

import com.finance.dto.DashboardSummary;
import com.finance.model.User;
import com.finance.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {
    
    private final DashboardService dashboardService;
    
    @GetMapping("/summary")
    @PreAuthorize("hasAnyRole('ADMIN', 'ANALYST', 'VIEWER')")
    public ResponseEntity<DashboardSummary> getDashboardSummary(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(dashboardService.getDashboardSummary(user));
    }
}
