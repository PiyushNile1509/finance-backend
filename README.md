# Finance Data Processing and Access Control Backend

A Spring Boot backend application for managing financial records with role-based access control, JWT authentication, and comprehensive dashboard analytics.

## 🎯 Features

### Core Functionality
- **User & Role Management**: Three-tier role system (VIEWER, ANALYST, ADMIN)
- **Financial Records**: Full CRUD operations with filtering and pagination
- **Dashboard Analytics**: Aggregated summaries including income, expenses, and category breakdowns
- **JWT Authentication**: Secure token-based authentication
- **Role-Based Access Control**: Granular permissions based on user roles
- **Input Validation**: Comprehensive validation with meaningful error messages
- **Error Handling**: Centralized exception handling with appropriate HTTP status codes

### Optional Enhancements Implemented
- ✅ JWT Authentication with token-based sessions
- ✅ Pagination & Sorting for record listings
- ✅ Advanced Search & Filtering (by type, category, date range)
- ✅ Comprehensive validation and error handling
- ✅ CORS configuration for frontend integration

## 🏗️ Architecture

### Project Structure
```
src/main/java/com/finance/
├── config/              # Security and application configuration
├── controller/          # REST API endpoints
├── dto/                 # Data Transfer Objects
├── exception/           # Custom exceptions and global error handler
├── model/               # JPA entities
├── repository/          # Data access layer
├── security/            # JWT utilities and authentication filters
└── service/             # Business logic layer
```

### Technology Stack
- **Framework**: Spring Boot 3.2.0
- **Language**: Java 17
- **Database**: MySQL
- **Security**: Spring Security + JWT
- **ORM**: Spring Data JPA (Hibernate)
- **Build Tool**: Maven
- **Validation**: Jakarta Validation

## 🚀 Getting Started

### Prerequisites
- Java 17 or higher
- Maven 3.6+
- MySQL 8.0+

### Database Setup
1. Install MySQL and start the service
2. Create a database (or let the app create it automatically):
```sql
CREATE DATABASE finance_db;
```

3. Update database credentials in `src/main/resources/application.properties`:
```properties
spring.datasource.username=your_username
spring.datasource.password=your_password
```

### Running the Application

1. **Clone the repository**
```bash
git clone <repository-url>
cd finance-backend
```

2. **Build the project**
```bash
mvn clean install
```

3. **Run the application**
```bash
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

## 📚 API Documentation

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "john_doe",
  "password": "password123",
  "email": "john@example.com",
  "role": "VIEWER"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "john_doe",
  "email": "john@example.com",
  "role": "VIEWER"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "john_doe",
  "password": "password123"
}
```

### User Management Endpoints

#### Get All Users (ADMIN only)
```http
GET /api/users
Authorization: Bearer <token>
```

#### Update User Status (ADMIN only)
```http
PUT /api/users/{userId}/status?active=true
Authorization: Bearer <token>
```

### Financial Records Endpoints

#### Create Record (ADMIN, ANALYST)
```http
POST /api/records
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 1500.00,
  "type": "INCOME",
  "category": "Salary",
  "date": "2024-01-15",
  "notes": "Monthly salary"
}
```

#### Get Records with Filtering & Pagination (All roles)
```http
GET /api/records?type=INCOME&category=Salary&startDate=2024-01-01&endDate=2024-12-31&page=0&size=10&sortBy=date&sortDir=DESC
Authorization: Bearer <token>
```

**Query Parameters:**
- `type`: INCOME or EXPENSE (optional)
- `category`: Filter by category (optional)
- `startDate`: Start date (YYYY-MM-DD) (optional)
- `endDate`: End date (YYYY-MM-DD) (optional)
- `page`: Page number (default: 0)
- `size`: Page size (default: 10)
- `sortBy`: Sort field (default: date)
- `sortDir`: ASC or DESC (default: DESC)

#### Get Record by ID (All roles)
```http
GET /api/records/{id}
Authorization: Bearer <token>
```

#### Update Record (ADMIN, ANALYST)
```http
PUT /api/records/{id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 1600.00,
  "type": "INCOME",
  "category": "Salary",
  "date": "2024-01-15",
  "notes": "Updated salary"
}
```

#### Delete Record (ADMIN only)
```http
DELETE /api/records/{id}
Authorization: Bearer <token>
```

### Dashboard Endpoints

#### Get Dashboard Summary (All roles)
```http
GET /api/dashboard/summary
Authorization: Bearer <token>
```

**Response:**
```json
{
  "totalIncome": 5000.00,
  "totalExpenses": 2000.00,
  "netBalance": 3000.00,
  "categoryTotals": {
    "Salary": 5000.00,
    "Groceries": 500.00,
    "Rent": 1500.00
  },
  "recentActivity": [
    {
      "id": 1,
      "amount": 1500.00,
      "type": "INCOME",
      "category": "Salary",
      "date": "2024-01-15",
      "notes": "Monthly salary",
      "createdAt": "2024-01-15T10:00:00",
      "updatedAt": "2024-01-15T10:00:00"
    }
  ]
}
```

## 🔐 Role-Based Access Control

### Role Permissions

| Action | VIEWER | ANALYST | ADMIN |
|--------|--------|---------|-------|
| View Records | ✅ | ✅ | ✅ |
| View Dashboard | ✅ | ✅ | ✅ |
| Create Records | ❌ | ✅ | ✅ |
| Update Records | ❌ | ✅ | ✅ |
| Delete Records | ❌ | ❌ | ✅ |
| Manage Users | ❌ | ❌ | ✅ |

### Implementation Details
- **VIEWER**: Read-only access to records and dashboard
- **ANALYST**: Can view and manage (create/update) records, access insights
- **ADMIN**: Full access including user management and record deletion

Access control is enforced at multiple levels:
1. **Method-level**: Using `@PreAuthorize` annotations
2. **Service-level**: Ownership validation (users can only access their own records)
3. **Filter-level**: JWT authentication filter validates tokens

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP
);
```

### Financial Records Table
```sql
CREATE TABLE financial_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    amount DECIMAL(19,2) NOT NULL,
    type VARCHAR(50) NOT NULL,
    category VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    notes VARCHAR(500),
    user_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## ⚙️ Configuration

### Application Properties
Key configurations in `application.properties`:

```properties
# Database
spring.datasource.url=jdbc:mysql://localhost:3306/finance_db?createDatabaseIfNotExist=true
spring.jpa.hibernate.ddl-auto=update

# JWT
jwt.secret=<your-secret-key>
jwt.expiration=86400000  # 24 hours

# Server
server.port=8080
```

## 🧪 Testing the API

### Using cURL

1. **Register a user**
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123","email":"admin@example.com","role":"ADMIN"}'
```

2. **Login**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

3. **Create a record** (use token from login)
```bash
curl -X POST http://localhost:8080/api/records \
  -H "Authorization: Bearer <your-token>" \
  -H "Content-Type: application/json" \
  -d '{"amount":1500,"type":"INCOME","category":"Salary","date":"2024-01-15","notes":"Monthly salary"}'
```

### Using Postman
1. Import the API endpoints
2. Set up an environment variable for the JWT token
3. Use the token in the Authorization header for protected endpoints

## 🎨 Design Decisions & Assumptions

### Assumptions
1. **Single Currency**: All amounts are in a single currency (no multi-currency support)
2. **User Isolation**: Users can only access their own financial records
3. **Role Assignment**: Roles are assigned during registration (in production, this would be admin-controlled)
4. **Soft Delete**: Records are permanently deleted (no soft delete implemented)
5. **Time Zone**: All dates/times are stored in server timezone

### Design Decisions
1. **JWT over Sessions**: Stateless authentication for scalability
2. **Role Enum**: Simple enum-based roles instead of complex permission system
3. **BigDecimal for Money**: Precise decimal arithmetic for financial calculations
4. **Pagination by Default**: Prevents large data transfers
5. **Separate DTOs**: Clear separation between API contracts and domain models
6. **Global Exception Handler**: Centralized error handling for consistency

### Trade-offs
1. **Security vs Simplicity**: JWT secret in properties file (should use environment variables in production)
2. **Performance vs Simplicity**: No caching layer (acceptable for assessment scope)
3. **Flexibility vs Complexity**: Fixed role system (easier to understand and maintain)

## 🔒 Security Considerations

### Implemented
- Password encryption using BCrypt
- JWT token-based authentication
- Role-based authorization
- Input validation
- SQL injection prevention (JPA/Hibernate)
- CORS configuration

### Production Recommendations
- Use environment variables for sensitive data
- Implement rate limiting
- Add request logging and monitoring
- Use HTTPS only
- Implement refresh tokens
- Add account lockout after failed attempts
- Implement audit logging

## 🚧 Future Enhancements

- [ ] Unit and integration tests
- [ ] API documentation with Swagger/OpenAPI
- [ ] Soft delete functionality
- [ ] Export data to CSV/PDF
- [ ] Email notifications
- [ ] Multi-currency support
- [ ] Budget tracking and alerts
- [ ] Recurring transactions
- [ ] Data visualization endpoints
- [ ] Mobile app support

## 📝 Notes

This project was built as an assessment to demonstrate:
- Backend architecture and design patterns
- RESTful API design
- Security implementation
- Data modeling and persistence
- Business logic implementation
- Code organization and maintainability

The focus was on correctness, clarity, and demonstrating understanding of backend engineering principles rather than building a production-ready system.

## 📧 Contact

For questions or clarifications about this implementation, please reach out through the assessment platform.
