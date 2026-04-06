# Architecture & Design Documentation

## Overview

This document explains the architectural decisions, design patterns, and implementation details of the Finance Backend application.

## System Architecture

### Layered Architecture

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│    (Controllers - REST Endpoints)       │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│          Security Layer                 │
│   (JWT Filter, Authentication)          │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         Business Logic Layer            │
│         (Services)                      │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         Data Access Layer               │
│    (Repositories - JPA)                 │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│            Database                     │
│           (MySQL)                       │
└─────────────────────────────────────────┘
```

## Design Patterns

### 1. Repository Pattern
**Location**: `repository/` package

**Purpose**: Abstracts data access logic from business logic

**Implementation**:
```java
public interface FinancialRecordRepository extends JpaRepository<FinancialRecord, Long> {
    // Custom queries
}
```

**Benefits**:
- Separation of concerns
- Easy to test (can mock repositories)
- Database-agnostic business logic

### 2. Service Layer Pattern
**Location**: `service/` package

**Purpose**: Encapsulates business logic

**Implementation**:
```java
@Service
@RequiredArgsConstructor
public class FinancialRecordService {
    private final FinancialRecordRepository repository;
    // Business logic methods
}
```

**Benefits**:
- Single responsibility
- Reusable business logic
- Transaction management

### 3. DTO Pattern
**Location**: `dto/` package

**Purpose**: Separates API contracts from domain models

**Implementation**:
```java
public class FinancialRecordRequest { /* API input */ }
public class FinancialRecordResponse { /* API output */ }
```

**Benefits**:
- API versioning flexibility
- Security (don't expose internal structure)
- Validation separation

### 4. Filter Pattern
**Location**: `security/JwtAuthenticationFilter`

**Purpose**: Intercepts requests for authentication

**Implementation**:
```java
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    // JWT validation logic
}
```

**Benefits**:
- Centralized authentication
- Stateless security
- Clean separation

## Security Architecture

### Authentication Flow

```
1. User sends credentials → /api/auth/login
2. Server validates credentials
3. Server generates JWT token
4. Client stores token
5. Client sends token in Authorization header
6. JwtAuthenticationFilter validates token
7. Request proceeds to controller
```

### Authorization Model

**Role Hierarchy**:
```
ADMIN (Full Access)
  ├── Can manage users
  ├── Can delete records
  └── All ANALYST permissions
      
ANALYST (Read/Write)
  ├── Can create records
  ├── Can update records
  └── All VIEWER permissions
      
VIEWER (Read Only)
  ├── Can view records
  └── Can view dashboard
```

**Implementation**:
- Method-level: `@PreAuthorize("hasRole('ADMIN')")`
- Service-level: Ownership validation
- Filter-level: JWT validation

## Data Model

### Entity Relationships

```
User (1) ──────< (N) FinancialRecord

User:
- id (PK)
- username (unique)
- email (unique)
- password (encrypted)
- role (enum)
- active (boolean)
- timestamps

FinancialRecord:
- id (PK)
- amount (decimal)
- type (enum: INCOME/EXPENSE)
- category (string)
- date (date)
- notes (text)
- user_id (FK)
- timestamps
```

### Design Decisions

**1. User-Record Relationship**
- One-to-Many (User → Records)
- Lazy loading for performance
- Cascade operations not used (explicit control)

**2. Enums for Types**
- `Role`: VIEWER, ANALYST, ADMIN
- `TransactionType`: INCOME, EXPENSE

**Benefits**:
- Type safety
- Database constraints
- Clear domain model

**3. BigDecimal for Money**
- Precise decimal arithmetic
- No floating-point errors
- Financial accuracy

**4. Timestamps**
- `createdAt`: Record creation time
- `updatedAt`: Last modification time
- Automatic via `@PrePersist` and `@PreUpdate`

## API Design

### RESTful Principles

**Resource-based URLs**:
```
/api/records          → Collection
/api/records/{id}     → Individual resource
/api/dashboard/summary → Aggregated data
```

**HTTP Methods**:
- GET: Retrieve data
- POST: Create new resource
- PUT: Update existing resource
- DELETE: Remove resource

**Status Codes**:
- 200: Success
- 201: Created
- 204: No Content (delete)
- 400: Bad Request (validation)
- 401: Unauthorized (no/invalid token)
- 403: Forbidden (insufficient permissions)
- 404: Not Found
- 500: Server Error

### Pagination & Filtering

**Query Parameters**:
```
?page=0              → Page number
&size=10             → Items per page
&sortBy=date         → Sort field
&sortDir=DESC        → Sort direction
&type=INCOME         → Filter by type
&category=Salary     → Filter by category
&startDate=2024-01-01 → Date range start
&endDate=2024-12-31   → Date range end
```

**Response Format**:
```json
{
  "content": [...],
  "pageable": {...},
  "totalElements": 100,
  "totalPages": 10,
  "size": 10,
  "number": 0
}
```

## Error Handling

### Global Exception Handler

**Location**: `exception/GlobalExceptionHandler`

**Handles**:
1. `ResourceNotFoundException` → 404
2. `UnauthorizedException` → 401
3. `AccessDeniedException` → 403
4. `MethodArgumentNotValidException` → 400
5. Generic `Exception` → 500

**Response Format**:
```json
{
  "status": 404,
  "message": "Record not found",
  "timestamp": "2024-01-15T10:00:00"
}
```

**Validation Errors**:
```json
{
  "status": 400,
  "errors": {
    "amount": "Amount must be greater than 0",
    "category": "Category is required"
  },
  "timestamp": "2024-01-15T10:00:00"
}
```

## Validation Strategy

### Input Validation

**Bean Validation (Jakarta)**:
```java
@NotBlank(message = "Username is required")
@Size(min = 3, max = 50)
private String username;

@DecimalMin(value = "0.01", message = "Amount must be greater than 0")
private BigDecimal amount;
```

**Custom Validation**:
- Duplicate username/email check
- Record ownership verification
- Role-based operation validation

## Performance Considerations

### Database Optimization

**1. Indexing**:
- Primary keys (automatic)
- Foreign keys (user_id)
- Unique constraints (username, email)

**2. Query Optimization**:
- Pagination to limit result sets
- Lazy loading for relationships
- Specific queries instead of fetching all

**3. Connection Pooling**:
- HikariCP (Spring Boot default)
- Efficient connection management

### Caching Strategy

**Current**: No caching (simplicity for assessment)

**Production Recommendations**:
- Cache dashboard summaries
- Cache user details
- Use Redis or Caffeine

## Security Best Practices

### Implemented

✅ Password encryption (BCrypt)
✅ JWT token-based authentication
✅ Role-based authorization
✅ Input validation
✅ SQL injection prevention (JPA)
✅ CORS configuration
✅ Stateless sessions

### Production Recommendations

- [ ] Use environment variables for secrets
- [ ] Implement rate limiting
- [ ] Add request logging
- [ ] Use HTTPS only
- [ ] Implement refresh tokens
- [ ] Add account lockout
- [ ] Implement audit logging
- [ ] Add CSRF protection for state-changing operations

## Testing Strategy

### Unit Testing (Recommended)
```java
@Test
void shouldCreateFinancialRecord() {
    // Given
    FinancialRecordRequest request = ...;
    
    // When
    FinancialRecordResponse response = service.createRecord(request, user);
    
    // Then
    assertNotNull(response.getId());
    assertEquals(request.getAmount(), response.getAmount());
}
```

### Integration Testing (Recommended)
```java
@SpringBootTest
@AutoConfigureMockMvc
class FinancialRecordControllerTest {
    @Test
    void shouldReturnRecordsForAuthenticatedUser() {
        // Test with MockMvc
    }
}
```

## Scalability Considerations

### Current Architecture
- Stateless (JWT) → Horizontal scaling ready
- Database connection pooling
- Pagination for large datasets

### Future Enhancements
- Add caching layer (Redis)
- Implement read replicas
- Add message queue for async operations
- Implement API rate limiting
- Add monitoring and metrics

## Configuration Management

### Application Properties

**Database**:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/finance_db
spring.jpa.hibernate.ddl-auto=update
```

**Security**:
```properties
jwt.secret=<secret-key>
jwt.expiration=86400000
```

**Production Recommendations**:
- Use environment variables
- Separate profiles (dev, staging, prod)
- Externalize configuration
- Use secrets management (AWS Secrets Manager, Vault)

## Deployment Architecture

### Local Development
```
Developer Machine
├── MySQL (localhost:3306)
└── Spring Boot App (localhost:8080)
```

### Production (Recommended)
```
Load Balancer
    ↓
Application Servers (Multiple instances)
    ↓
Database (Primary + Replicas)
    ↓
Cache Layer (Redis)
```

## Monitoring & Logging

### Current Logging
- Spring Boot default logging
- SQL query logging (development)
- Exception stack traces

### Production Recommendations
- Structured logging (JSON)
- Centralized log aggregation (ELK Stack)
- Application metrics (Micrometer + Prometheus)
- Health checks and readiness probes
- Distributed tracing (Zipkin, Jaeger)

## Trade-offs & Decisions

### 1. JWT vs Session-based Auth
**Chosen**: JWT
**Reason**: Stateless, scalable, suitable for microservices
**Trade-off**: Cannot revoke tokens easily

### 2. Role Enum vs Permission System
**Chosen**: Simple role enum
**Reason**: Clear, easy to understand, sufficient for requirements
**Trade-off**: Less flexible than fine-grained permissions

### 3. Hard Delete vs Soft Delete
**Chosen**: Hard delete
**Reason**: Simpler implementation, clear data lifecycle
**Trade-off**: Cannot recover deleted records

### 4. Embedded Security vs OAuth2
**Chosen**: Embedded JWT
**Reason**: Self-contained, no external dependencies
**Trade-off**: Not suitable for SSO scenarios

### 5. MySQL vs NoSQL
**Chosen**: MySQL (Relational)
**Reason**: Structured data, ACID compliance, relationships
**Trade-off**: Less flexible schema evolution

## Code Quality Practices

### Implemented
- Lombok for boilerplate reduction
- Constructor injection (immutability)
- Package organization by feature
- Meaningful naming conventions
- Separation of concerns

### Recommendations
- Add unit tests (JUnit 5)
- Add integration tests
- Use SonarQube for code quality
- Implement CI/CD pipeline
- Add API documentation (Swagger)

## Conclusion

This architecture prioritizes:
1. **Clarity**: Easy to understand and maintain
2. **Security**: Proper authentication and authorization
3. **Scalability**: Stateless design, pagination
4. **Maintainability**: Layered architecture, separation of concerns
5. **Correctness**: Validation, error handling, type safety

The design is intentionally kept simple and focused on demonstrating core backend engineering principles while remaining production-ready with minimal enhancements.
