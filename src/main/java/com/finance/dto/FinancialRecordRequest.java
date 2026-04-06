package com.finance.dto;

import com.finance.model.TransactionType;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class FinancialRecordRequest {
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    private BigDecimal amount;
    
    @NotNull(message = "Type is required")
    private TransactionType type;
    
    @NotBlank(message = "Category is required")
    private String category;
    
    @NotNull(message = "Date is required")
    private LocalDate date;
    
    @Size(max = 500, message = "Notes cannot exceed 500 characters")
    private String notes;
}
