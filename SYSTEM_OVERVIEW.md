# System Overview

Visual representation of the Finance Backend system architecture and flows.

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                            │
│  (Web Browser, Mobile App, Postman, cURL, etc.)                │
└─────────────────────────────────────────────────────────────────┘
                              ↓ HTTP/HTTPS
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │    Auth      │  │   Financial  │  │  Dashboard   │         │
│  │  Controller  │  │   Records    │  │  Controller  │         │
│  │              │  │  Controller  │  │              │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      SECURITY LAYER                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         JWT Authentication Filter                        │  │
│  │  • Validates JWT tokens                                  │  │
│  │  • Sets security context                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         Role-Based Authorization                         │  │
│  │  • @PreAuthorize annotations                             │  │
│  │  • Method-level security                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    BUSINESS LOGIC LAYER                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │    User      │  │   Financial  │  │  Dashboard   │         │
│  │   Service    │  │   Records    │  │   Service    │         │
│  │              │  │   Service    │  │              │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    DATA ACCESS LAYER                            │
│  ┌──────────────┐  ┌──────────────────────────────────┐        │
│  │    User      │  │   Financial Records              │        │
│  │  Repository  │  │   Repository                     │        │
│  │  (JPA)       │  │   (JPA)                          │        │
│  └──────────────┘  └──────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE LAYER                             │
│                      MySQL Database                             │
│  ┌──────────────┐           ┌──────────────────────┐           │
│  │    users     │ 1     N   │  financial_records   │           │
│  │              │───────────│                      │           │
│  └──────────────┘           └──────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

## 🔐 Authentication Flow

```
┌─────────┐                                              ┌─────────┐
│ Client  │                                              │ Server  │
└────┬────┘                                              └────┬────┘
     │                                                        │
     │  1. POST /api/auth/login                              │
     │    { username, password }                             │
     ├──────────────────────────────────────────────────────>│
     │                                                        │
     │                                    2. Validate         │
     │                                       credentials      │
     │                                                        │
     │                                    3. Generate JWT     │
     │                                       token            │
     │                                                        │
     │  4. Return token + user info                          │
     │<──────────────────────────────────────────────────────┤
     │    { token, username, email, role }                   │
     │                                                        │
     │  5. Store token (localStorage/memory)                 │
     │                                                        │
     │  6. Subsequent requests with token                    │
     │    Authorization: Bearer <token>                      │
     ├──────────────────────────────────────────────────────>│
     │                                                        │
     │                                    7. Validate token   │
     │                                    8. Extract user     │
     │                                    9. Check permissions│
     │                                                        │
     │  10. Return response                                  │
     │<──────────────────────────────────────────────────────┤
     │                                                        │
```

## 🚦 Authorization Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    Request Arrives                           │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       ↓
┌──────────────────────────────────────────────────────────────┐
│         JWT Authentication Filter                            │
│  • Extract token from Authorization header                   │
│  • Validate token signature                                  │
│  • Check token expiration                                    │
│  • Load user details                                         │
│  • Set SecurityContext                                       │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       ↓
┌──────────────────────────────────────────────────────────────┐
│         Method-Level Security Check                          │
│  @PreAuthorize("hasRole('ADMIN')")                           │
│  • Check user's role                                         │
│  • Allow or deny access                                      │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       ↓
┌──────────────────────────────────────────────────────────────┐
│         Service-Level Validation                             │
│  • Verify resource ownership                                 │
│  • Check business rules                                      │
│  • Validate operation permissions                            │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       ↓
┌──────────────────────────────────────────────────────────────┐
│         Execute Business Logic                               │
└──────────────────────────────────────────────────────────────┘
```

## 👥 Role-Based Access Matrix

```
┌─────────────────────┬─────────┬──────────┬─────────┐
│      Operation      │ VIEWER  │ ANALYST  │  ADMIN  │
├─────────────────────┼─────────┼──────────┼─────────┤
│ View Records        │    ✓    │    ✓     │    ✓    │
│ View Dashboard      │    ✓    │    ✓     │    ✓    │
│ Create Records      │    ✗    │    ✓     │    ✓    │
│ Update Records      │    ✗    │    ✓     │    ✓    │
│ Delete Records      │    ✗    │    ✗     │    ✓    │
│ View Users          │    ✗    │    ✗     │    ✓    │
│ Manage Users        │    ✗    │    ✗     │    ✓    │
└─────────────────────┴─────────┴──────────┴─────────┘
```

## 📊 Data Flow - Create Financial Record

```
┌─────────┐
│ Client  │
└────┬────┘
     │
     │ POST /api/records
     │ { amount, type, category, date, notes }
     │ Authorization: Bearer <token>
     ↓
┌────────────────────────────────────────┐
│  FinancialRecordController             │
│  • @PreAuthorize("hasAnyRole(          │
│     'ADMIN', 'ANALYST')")              │
│  • Extract authenticated user          │
└────┬───────────────────────────────────┘
     │
     │ Validate request
     ↓
┌────────────────────────────────────────┐
│  FinancialRecordService                │
│  • Create new FinancialRecord entity   │
│  • Set user reference                  │
│  • Set timestamps                      │
└────┬───────────────────────────────────┘
     │
     │ Save entity
     ↓
┌────────────────────────────────────────┐
│  FinancialRecordRepository             │
│  • JPA save operation                  │
│  • Generate ID                         │
└────┬───────────────────────────────────┘
     │
     │ SQL INSERT
     ↓
┌────────────────────────────────────────┐
│  MySQL Database                        │
│  INSERT INTO financial_records ...     │
└────┬───────────────────────────────────┘
     │
     │ Return saved entity
     ↓
┌────────────────────────────────────────┐
│  Convert to DTO                        │
│  FinancialRecordResponse               │
└────┬───────────────────────────────────┘
     │
     │ HTTP 200 OK
     │ { id, amount, type, ... }
     ↓
┌─────────┐
│ Client  │
└─────────┘
```

## 📈 Dashboard Summary Calculation

```
┌─────────────────────────────────────────────────────────┐
│  GET /api/dashboard/summary                             │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│  DashboardService                                       │
│                                                         │
│  1. Calculate Total Income                              │
│     SELECT SUM(amount) FROM financial_records           │
│     WHERE user_id = ? AND type = 'INCOME'               │
│                                                         │
│  2. Calculate Total Expenses                            │
│     SELECT SUM(amount) FROM financial_records           │
│     WHERE user_id = ? AND type = 'EXPENSE'              │
│                                                         │
│  3. Calculate Net Balance                               │
│     netBalance = totalIncome - totalExpenses            │
│                                                         │
│  4. Get Category Totals                                 │
│     SELECT category, SUM(amount)                        │
│     FROM financial_records                              │
│     WHERE user_id = ?                                   │
│     GROUP BY category                                   │
│                                                         │
│  5. Get Recent Activity                                 │
│     SELECT * FROM financial_records                     │
│     WHERE user_id = ?                                   │
│     ORDER BY date DESC, created_at DESC                 │
│     LIMIT 10                                            │
│                                                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│  Return DashboardSummary                                │
│  {                                                      │
│    totalIncome: 5000.00,                                │
│    totalExpenses: 2000.00,                              │
│    netBalance: 3000.00,                                 │
│    categoryTotals: { ... },                             │
│    recentActivity: [ ... ]                              │
│  }                                                      │
└─────────────────────────────────────────────────────────┘
```

## 🗄️ Database Schema

```
┌─────────────────────────────────────────┐
│              users                      │
├─────────────────────────────────────────┤
│ id (PK)              BIGINT             │
│ username             VARCHAR(255) UQ    │
│ password             VARCHAR(255)       │
│ email                VARCHAR(255) UQ    │
│ role                 VARCHAR(50)        │
│ active               BOOLEAN            │
│ created_at           TIMESTAMP          │
│ updated_at           TIMESTAMP          │
└─────────────────────────────────────────┘
                  │
                  │ 1:N
                  │
                  ↓
┌─────────────────────────────────────────┐
│        financial_records                │
├─────────────────────────────────────────┤
│ id (PK)              BIGINT             │
│ amount               DECIMAL(19,2)      │
│ type                 VARCHAR(50)        │
│ category             VARCHAR(255)       │
│ date                 DATE               │
│ notes                VARCHAR(500)       │
│ user_id (FK)         BIGINT             │
│ created_at           TIMESTAMP          │
│ updated_at           TIMESTAMP          │
└─────────────────────────────────────────┘
```

## 🔄 Request/Response Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    HTTP Request                              │
│  Method: POST                                                │
│  URL: /api/records                                           │
│  Headers:                                                    │
│    Content-Type: application/json                            │
│    Authorization: Bearer eyJhbGc...                          │
│  Body:                                                       │
│    {                                                         │
│      "amount": 1000.00,                                      │
│      "type": "INCOME",                                       │
│      "category": "Salary",                                   │
│      "date": "2024-01-15",                                   │
│      "notes": "Monthly salary"                               │
│    }                                                         │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       ↓
┌──────────────────────────────────────────────────────────────┐
│              Spring Boot Processing                          │
│  1. JWT Filter validates token                               │
│  2. Controller receives FinancialRecordRequest DTO           │
│  3. @Valid triggers validation                               │
│  4. @PreAuthorize checks role                                │
│  5. Service processes business logic                         │
│  6. Repository saves to database                             │
│  7. Entity converted to FinancialRecordResponse DTO          │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       ↓
┌──────────────────────────────────────────────────────────────┐
│                    HTTP Response                             │
│  Status: 200 OK                                              │
│  Headers:                                                    │
│    Content-Type: application/json                            │
│  Body:                                                       │
│    {                                                         │
│      "id": 1,                                                │
│      "amount": 1000.00,                                      │
│      "type": "INCOME",                                       │
│      "category": "Salary",                                   │
│      "date": "2024-01-15",                                   │
│      "notes": "Monthly salary",                              │
│      "createdAt": "2024-01-15T10:00:00",                     │
│      "updatedAt": "2024-01-15T10:00:00"                      │
│    }                                                         │
└──────────────────────────────────────────────────────────────┘
```

## 🛡️ Security Layers

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: Network Security                                  │
│  • HTTPS (recommended for production)                       │
│  • CORS configuration                                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: Authentication                                    │
│  • JWT token validation                                     │
│  • Token expiration check                                   │
│  • User identity verification                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: Authorization                                     │
│  • Role-based access control                                │
│  • Method-level security (@PreAuthorize)                    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  Layer 4: Business Logic Validation                         │
│  • Resource ownership verification                          │
│  • Business rule enforcement                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  Layer 5: Data Validation                                   │
│  • Input validation (Bean Validation)                       │
│  • SQL injection prevention (JPA)                           │
│  • Data integrity constraints                               │
└─────────────────────────────────────────────────────────────┘
```

## 📦 Package Structure

```
com.finance
│
├── config/
│   ├── SecurityConfig.java          # Spring Security configuration
│   └── DataInitializer.java         # Sample data initialization
│
├── controller/
│   ├── AuthController.java          # Authentication endpoints
│   ├── UserController.java          # User management endpoints
│   ├── FinancialRecordController.java  # Financial records CRUD
│   └── DashboardController.java     # Dashboard analytics
│
├── dto/
│   ├── LoginRequest.java            # Login input
│   ├── RegisterRequest.java         # Registration input
│   ├── AuthResponse.java            # Auth output
│   ├── FinancialRecordRequest.java  # Record input
│   ├── FinancialRecordResponse.java # Record output
│   ├── DashboardSummary.java        # Dashboard output
│   └── UserResponse.java            # User output
│
├── exception/
│   ├── GlobalExceptionHandler.java  # Centralized error handling
│   ├── ResourceNotFoundException.java
│   └── UnauthorizedException.java
│
├── model/
│   ├── User.java                    # User entity
│   ├── Role.java                    # Role enum
│   ├── FinancialRecord.java         # Financial record entity
│   └── TransactionType.java         # Transaction type enum
│
├── repository/
│   ├── UserRepository.java          # User data access
│   └── FinancialRecordRepository.java  # Record data access
│
├── security/
│   ├── JwtUtil.java                 # JWT token utilities
│   └── JwtAuthenticationFilter.java # JWT validation filter
│
├── service/
│   ├── UserService.java             # User business logic
│   ├── FinancialRecordService.java  # Record business logic
│   └── DashboardService.java        # Dashboard business logic
│
└── FinanceBackendApplication.java   # Main application class
```

## 🚀 Deployment Architecture (Recommended)

```
┌─────────────────────────────────────────────────────────────┐
│                    Load Balancer                            │
│                  (AWS ALB / Nginx)                          │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        ↓            ↓            ↓
┌──────────┐  ┌──────────┐  ┌──────────┐
│  App     │  │  App     │  │  App     │
│ Instance │  │ Instance │  │ Instance │
│    1     │  │    2     │  │    3     │
└────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │             │
     └─────────────┼─────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────────┐
│              Database Cluster                               │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │   Primary    │────────>│   Replica    │                 │
│  │   MySQL      │         │   MySQL      │                 │
│  └──────────────┘         └──────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

---

This visual overview provides a comprehensive understanding of the system architecture, data flows, and security mechanisms implemented in the Finance Backend application.
