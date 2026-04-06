package com.finance.service;

import com.finance.dto.FinancialRecordRequest;
import com.finance.dto.FinancialRecordResponse;
import com.finance.exception.ResourceNotFoundException;
import com.finance.exception.UnauthorizedException;
import com.finance.model.FinancialRecord;
import com.finance.model.TransactionType;
import com.finance.model.User;
import com.finance.repository.FinancialRecordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class FinancialRecordService {
    
    private final FinancialRecordRepository recordRepository;
    
    @Transactional
    public FinancialRecordResponse createRecord(FinancialRecordRequest request, User user) {
        FinancialRecord record = new FinancialRecord();
        record.setAmount(request.getAmount());
        record.setType(request.getType());
        record.setCategory(request.getCategory());
        record.setDate(request.getDate());
        record.setNotes(request.getNotes());
        record.setUser(user);
        
        record = recordRepository.save(record);
        return toResponse(record);
    }
    
    public Page<FinancialRecordResponse> getRecords(User user, TransactionType type, String category,
                                                     LocalDate startDate, LocalDate endDate, Pageable pageable) {
        return recordRepository.findByFilters(user.getId(), type, category, startDate, endDate, pageable)
                .map(this::toResponse);
    }
    
    public FinancialRecordResponse getRecordById(Long id, User user) {
        FinancialRecord record = recordRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Record not found"));
        
        if (!record.getUser().getId().equals(user.getId())) {
            throw new UnauthorizedException("Access denied");
        }
        
        return toResponse(record);
    }
    
    @Transactional
    public FinancialRecordResponse updateRecord(Long id, FinancialRecordRequest request, User user) {
        FinancialRecord record = recordRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Record not found"));
        
        if (!record.getUser().getId().equals(user.getId())) {
            throw new UnauthorizedException("Access denied");
        }
        
        record.setAmount(request.getAmount());
        record.setType(request.getType());
        record.setCategory(request.getCategory());
        record.setDate(request.getDate());
        record.setNotes(request.getNotes());
        
        record = recordRepository.save(record);
        return toResponse(record);
    }
    
    @Transactional
    public void deleteRecord(Long id, User user) {
        FinancialRecord record = recordRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Record not found"));
        
        if (!record.getUser().getId().equals(user.getId())) {
            throw new UnauthorizedException("Access denied");
        }
        
        recordRepository.delete(record);
    }
    
    private FinancialRecordResponse toResponse(FinancialRecord record) {
        return new FinancialRecordResponse(
                record.getId(),
                record.getAmount(),
                record.getType(),
                record.getCategory(),
                record.getDate(),
                record.getNotes(),
                record.getCreatedAt(),
                record.getUpdatedAt()
        );
    }
}
