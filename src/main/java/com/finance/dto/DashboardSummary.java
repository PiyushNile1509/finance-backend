package com.finance.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class DashboardSummary {
    private BigDecimal totalIncome;
    private BigDecimal totalExpenses;
    private BigDecimal netBalance;
    private Map<String, BigDecimal> categoryTotals;
    private List<FinancialRecordResponse> recentActivity;

    public DashboardSummary(BigDecimal totalIncome, BigDecimal totalExpenses, BigDecimal netBalance,
                             Map<String, BigDecimal> categoryTotals, List<FinancialRecordResponse> recentActivity) {
        this.totalIncome = totalIncome;
        this.totalExpenses = totalExpenses;
        this.netBalance = netBalance;
        this.categoryTotals = categoryTotals;
        this.recentActivity = recentActivity;
    }

    public BigDecimal getTotalIncome() { return totalIncome; }
    public BigDecimal getTotalExpenses() { return totalExpenses; }
    public BigDecimal getNetBalance() { return netBalance; }
    public Map<String, BigDecimal> getCategoryTotals() { return categoryTotals; }
    public List<FinancialRecordResponse> getRecentActivity() { return recentActivity; }
}
