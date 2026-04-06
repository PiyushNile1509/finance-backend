package com.finance.config;

import com.finance.model.FinancialRecord;
import com.finance.model.Role;
import com.finance.model.TransactionType;
import com.finance.model.User;
import com.finance.repository.FinancialRecordRepository;
import com.finance.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {
    
    private final UserRepository userRepository;
    private final FinancialRecordRepository recordRepository;
    private final PasswordEncoder passwordEncoder;
    
    @Override
    public void run(String... args) {
        // Only initialize if database is empty
        if (userRepository.count() == 0) {
            log.info("Initializing sample data...");
            initializeUsers();
            log.info("Sample data initialized successfully!");
        }
    }
    
    private void initializeUsers() {
        // Create Admin user
        User admin = new User();
        admin.setUsername("admin");
        admin.setPassword(passwordEncoder.encode("admin123"));
        admin.setEmail("admin@finance.com");
        admin.setRole(Role.ADMIN);
        admin.setActive(true);
        admin = userRepository.save(admin);
        log.info("Created admin user: {}", admin.getUsername());
        
        // Create Analyst user
        User analyst = new User();
        analyst.setUsername("analyst");
        analyst.setPassword(passwordEncoder.encode("analyst123"));
        analyst.setEmail("analyst@finance.com");
        analyst.setRole(Role.ANALYST);
        analyst.setActive(true);
        analyst = userRepository.save(analyst);
        log.info("Created analyst user: {}", analyst.getUsername());
        
        // Create Viewer user
        User viewer = new User();
        viewer.setUsername("viewer");
        viewer.setPassword(passwordEncoder.encode("viewer123"));
        viewer.setEmail("viewer@finance.com");
        viewer.setRole(Role.VIEWER);
        viewer.setActive(true);
        viewer = userRepository.save(viewer);
        log.info("Created viewer user: {}", viewer.getUsername());
        
        // Create sample financial records for admin
        createSampleRecords(admin);
    }
    
    private void createSampleRecords(User user) {
        // Income records
        createRecord(user, new BigDecimal("5000.00"), TransactionType.INCOME, "Salary", 
                    LocalDate.now().minusDays(15), "Monthly salary payment");
        createRecord(user, new BigDecimal("500.00"), TransactionType.INCOME, "Freelance", 
                    LocalDate.now().minusDays(10), "Freelance project payment");
        
        // Expense records
        createRecord(user, new BigDecimal("1500.00"), TransactionType.EXPENSE, "Rent", 
                    LocalDate.now().minusDays(20), "Monthly rent payment");
        createRecord(user, new BigDecimal("300.00"), TransactionType.EXPENSE, "Groceries", 
                    LocalDate.now().minusDays(5), "Weekly groceries");
        createRecord(user, new BigDecimal("150.00"), TransactionType.EXPENSE, "Utilities", 
                    LocalDate.now().minusDays(12), "Electricity and water bills");
        createRecord(user, new BigDecimal("80.00"), TransactionType.EXPENSE, "Transportation", 
                    LocalDate.now().minusDays(3), "Monthly transport pass");
        createRecord(user, new BigDecimal("200.00"), TransactionType.EXPENSE, "Entertainment", 
                    LocalDate.now().minusDays(7), "Dining and movies");
        
        log.info("Created {} sample financial records", 7);
    }
    
    private void createRecord(User user, BigDecimal amount, TransactionType type, 
                            String category, LocalDate date, String notes) {
        FinancialRecord record = new FinancialRecord();
        record.setUser(user);
        record.setAmount(amount);
        record.setType(type);
        record.setCategory(category);
        record.setDate(date);
        record.setNotes(notes);
        recordRepository.save(record);
    }
}
