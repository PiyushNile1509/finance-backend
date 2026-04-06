package com.finance.repository;

import com.finance.model.FinancialRecord;
import com.finance.model.TransactionType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface FinancialRecordRepository extends JpaRepository<FinancialRecord, Long> {
    
    Page<FinancialRecord> findByUserId(Long userId, Pageable pageable);
    
    @Query("SELECT f FROM FinancialRecord f WHERE f.user.id = :userId " +
           "AND (:type IS NULL OR f.type = :type) " +
           "AND (:category IS NULL OR f.category = :category) " +
           "AND (:startDate IS NULL OR f.date >= :startDate) " +
           "AND (:endDate IS NULL OR f.date <= :endDate)")
    Page<FinancialRecord> findByFilters(
        @Param("userId") Long userId,
        @Param("type") TransactionType type,
        @Param("category") String category,
        @Param("startDate") LocalDate startDate,
        @Param("endDate") LocalDate endDate,
        Pageable pageable
    );
    
    @Query("SELECT COALESCE(SUM(f.amount), 0) FROM FinancialRecord f " +
           "WHERE f.user.id = :userId AND f.type = :type")
    BigDecimal sumByUserIdAndType(@Param("userId") Long userId, @Param("type") TransactionType type);
    
    @Query("SELECT f.category, SUM(f.amount) FROM FinancialRecord f " +
           "WHERE f.user.id = :userId GROUP BY f.category")
    List<Object[]> getCategoryTotals(@Param("userId") Long userId);
    
    List<FinancialRecord> findTop10ByUserIdOrderByDateDescCreatedAtDesc(Long userId);
}
