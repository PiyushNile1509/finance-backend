package com.finance.service;

import com.finance.dto.DashboardSummary;
import com.finance.dto.FinancialRecordResponse;
import com.finance.model.FinancialRecord;
import com.finance.model.TransactionType;
import com.finance.model.User;
import com.finance.repository.FinancialRecordRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class DashboardService {

    private final FinancialRecordRepository recordRepository;

    public DashboardService(FinancialRecordRepository recordRepository) {
        this.recordRepository = recordRepository;
    }

    public DashboardSummary getDashboardSummary(User user) {
        BigDecimal totalIncome = recordRepository.sumByUserIdAndType(user.getId(), TransactionType.INCOME);
        BigDecimal totalExpenses = recordRepository.sumByUserIdAndType(user.getId(), TransactionType.EXPENSE);
        BigDecimal netBalance = totalIncome.subtract(totalExpenses);

        Map<String, BigDecimal> categoryTotals = new HashMap<>();
        List<Object[]> categoryData = recordRepository.getCategoryTotals(user.getId());
        for (Object[] row : categoryData) {
            categoryTotals.put((String) row[0], (BigDecimal) row[1]);
        }

        List<FinancialRecordResponse> recentActivity = recordRepository
                .findTop10ByUserIdOrderByDateDescCreatedAtDesc(user.getId())
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());

        return new DashboardSummary(totalIncome, totalExpenses, netBalance, categoryTotals, recentActivity);
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
