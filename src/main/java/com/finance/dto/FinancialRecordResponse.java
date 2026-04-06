package com.finance.dto;

import com.finance.model.TransactionType;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class FinancialRecordResponse {
    private Long id;
    private BigDecimal amount;
    private TransactionType type;
    private String category;
    private LocalDate date;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public FinancialRecordResponse(Long id, BigDecimal amount, TransactionType type, String category,
                                   LocalDate date, String notes, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.amount = amount;
        this.type = type;
        this.category = category;
        this.date = date;
        this.notes = notes;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getId() { return id; }
    public BigDecimal getAmount() { return amount; }
    public TransactionType getType() { return type; }
    public String getCategory() { return category; }
    public LocalDate getDate() { return date; }
    public String getNotes() { return notes; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    public void setId(Long id) { this.id = id; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public void setType(TransactionType type) { this.type = type; }
    public void setCategory(String category) { this.category = category; }
    public void setDate(LocalDate date) { this.date = date; }
    public void setNotes(String notes) { this.notes = notes; }
}
