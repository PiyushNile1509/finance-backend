package com.finance.controller;

import com.finance.dto.FinancialRecordRequest;
import com.finance.dto.FinancialRecordResponse;
import com.finance.model.TransactionType;
import com.finance.model.User;
import com.finance.service.FinancialRecordService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/records")
@RequiredArgsConstructor
public class FinancialRecordController {
    
    private final FinancialRecordService recordService;
    
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ANALYST')")
    public ResponseEntity<FinancialRecordResponse> createRecord(
            @Valid @RequestBody FinancialRecordRequest request,
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(recordService.createRecord(request, user));
    }
    
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ANALYST', 'VIEWER')")
    public ResponseEntity<Page<FinancialRecordResponse>> getRecords(
            @RequestParam(required = false) TransactionType type,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "date") String sortBy,
            @RequestParam(defaultValue = "DESC") String sortDir,
            @AuthenticationPrincipal User user) {
        
        Sort sort = sortDir.equalsIgnoreCase("ASC") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return ResponseEntity.ok(recordService.getRecords(user, type, category, startDate, endDate, pageable));
    }
    
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ANALYST', 'VIEWER')")
    public ResponseEntity<FinancialRecordResponse> getRecordById(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(recordService.getRecordById(id, user));
    }
    
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ANALYST')")
    public ResponseEntity<FinancialRecordResponse> updateRecord(
            @PathVariable Long id,
            @Valid @RequestBody FinancialRecordRequest request,
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(recordService.updateRecord(id, request, user));
    }
    
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteRecord(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        recordService.deleteRecord(id, user);
        return ResponseEntity.noContent().build();
    }
}
