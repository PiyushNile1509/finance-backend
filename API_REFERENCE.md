# API Reference

Complete reference for all API endpoints in the Finance Backend application.

**Base URL**: `http://localhost:8080`

---

## 🔓 Authentication Endpoints

### Register User
Create a new user account.

**Endpoint**: `POST /api/auth/register`  
**Authentication**: Not required  
**Authorization**: Public

**Request Body**:
```json
{
  "username": "string (3-50 chars, required)",
  "password": "string (min 6 chars, required)",
  "email": "string (valid email, required)",
  "role": "VIEWER | ANALYST | ADMIN (required)"
}
```

**Response**: `200 OK`
```json
{
  "token": "string (JWT token)",
  "username": "string",
  "email": "string",
  "role": "string"
}
```

**Error Responses**:
- `400 Bad Request` - Validation errors
- `401 Unauthorized` - Username or email already exists

---

### Login
Authenticate and receive JWT token.

**Endpoint**: `POST /api/auth/login`  
**Authentication**: Not required  
**Authorization**: Public

**Request Body**:
```json
{
  "username": "string (required)",
  "password": "string (required)"
}
```

**Response**: `200 OK`
```json
{
  "token": "string (JWT token)",
  "username": "string",
  "email": "string",
  "role": "string"
}
```

**Error Responses**:
- `400 Bad Request` - Validation errors
- `401 Unauthorized` - Invalid credentials

---

## 👥 User Management Endpoints

### Get All Users
Retrieve list of all users.

**Endpoint**: `GET /api/users`  
**Authentication**: Required (JWT)  
**Authorization**: ADMIN only

**Headers**:
```
Authorization: Bearer <jwt_token>
```

**Response**: `200 OK`
```json
[
  {
    "id": 1,
    "username": "string",
    "email": "string",
    "role": "string",
    "active": true,
    "createdAt": "2024-01-15T10:00:00"
  }
]
```

**Error Responses**:
- `401 Unauthorized` - Missing or invalid token
- `403 Forbidden` - Insufficient permissions

---

### Update User Status
Activate or deactivate a user account.

**Endpoint**: `PUT /api/users/{userId}/status`  
**Authentication**: Required (JWT)  
**Authorization**: ADMIN only

**Headers**:
```
Authorization: Bearer <jwt_token>
```

**Path Parameters**:
- `userId` (Long) - User ID

**Query Parameters**:
- `active` (Boolean, required) - true to activate, false to deactivate

**Response**: `200 OK`
```json
{
  "id": 1,
  "username": "string",
  "email": "string",
  "role": "string",
  "active": false,
  "createdAt": "2024-01-15T10:00:00"
}
```

**Error Responses**:
- `401 Unauthorized` - Missing or invalid token / User not found
- `403 Forbidden` - Insufficient permissions

---

## 💰 Financial Records Endpoints

### Create Financial Record
Create a new financial record.

**Endpoint**: `POST /api/records`  
**Authentication**: Required (JWT)  
**Authorization**: ADMIN, ANALYST

**Headers**:
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request Body**:
```json
{
  "amount": 1000.00,
  "type": "INCOME | EXPENSE (required)",
  "category": "string (required)",
  "date": "2024-01-15 (YYYY-MM-DD, required)",
  "notes": "string (max 500 chars, optional)"
}
```

**Response**: `200 OK`
```json
{
  "id": 1,
  "amount": 1000.00,
  "type": "INCOME",
  "category": "Salary",
  "date": "2024-01-15",
  "notes": "Monthly salary",
  "createdAt": "2024-01-15T10:00:00",
  "updatedAt": "2024-01-15T10:00:00"
}
```

**Error Responses**:
- `400 Bad Request` - Validation errors
- `401 Unauthorized` - Missing or invalid token
- `403 Forbidden` - Insufficient permissions (VIEWER cannot create)

---

### Get Financial Records
Retrieve financial records with filtering, pagination, and sorting.

**Endpoint**: `GET /api/records`  
**Authentication**: Required (JWT)  
**Authorization**: All roles (VIEWER, ANALYST, ADMIN)

**Headers**:
```
Authorization: Bearer <jwt_token>
```

**Query Parameters** (all optional):
- `type` (String) - Filter by type: INCOME or EXPENSE
- `category` (String) - Filter by category
- `startDate` (Date) - Filter by start date (YYYY-MM-DD)
- `endDate` (Date) - Filter by end date (YYYY-MM-DD)
- `page` (Integer) - Page number (default: 0)
- `size` (Integer) - Page size (default: 10)
- `sortBy` (String) - Sort field (default: date)
- `sortDir` (String) - Sort direction: ASC or DESC (default: DESC)

**Example**:
```
GET /api/records?type=INCOME&category=Salary&startDate=2024-01-01&endDate=2024-12-31&page=0&size=10&sortBy=date&sortDir=DESC
```

**Response**: `200 OK`
```json
{
  "content": [
    {
      "id": 1,
      "amount": 1000.00,
      "type": "INCOME",
      "category": "Salary",
      "date": "2024-01-15",
      "notes": "Monthly salary",
      "createdAt": "2024-01-15T10:00:00",
      "updatedAt": "2024-01-15T10:00:00"
    }
  ],
  "pageable": {
    "sort": {
      "sorted": true,
      "unsorted": false,
      "empty": false
    },
    "pageNumber": 0,
    "pageSize": 10,
    "offset": 0,
    "paged": true,
    "unpaged": false
  },
  "totalElements": 100,
  "totalPages": 10,
  "last": false,
  "size": 10,
  "number": 0,
  "sort": {
    "sorted": true,
    "unsorted": false,
    "empty": false
  },
  "numberOfElements": 10,
  "first": true,
  "empty": false
}
```

**Error Responses**:
- `401 Unauthorized` - Missing or invalid token

---

### Get Financial Record by ID
Retrieve a specific financial record.

**Endpoint**: `GET /api/records/{id}`  
**Authentication**: Required (JWT)  
**Authorization**: All roles (VIEWER, ANALYST, ADMIN)

**Headers**:
```
Authorization: Bearer <jwt_token>
```

**Path Parameters**:
- `id` (Long) - Record ID

**Response**: `200 OK`
```json
{
  "id": 1,
  "amount": 1000.00,
  "type": "INCOME",
  "category": "Salary",
  "date": "2024-01-15",
  "notes": "Monthly salary",
  "createdAt": "2024-01-15T10:00:00",
  "updatedAt": "2024-01-15T10:00:00"
}
```

**Error Responses**:
- `401 Unauthorized` - Missing or invalid token / Access denied (not owner)
- `404 Not Found` - Record not found

---

### Update Financial Record
Update an existing financial record.

**Endpoint**: `PUT /api/records/{id}`  
**Authentication**: Required (JWT)  
**Authorization**: ADMIN, ANALYST

**Headers**:
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Path Parameters**:
- `id` (Long) - Record ID

**Request Body**:
```json
{
  "amount": 1500.00,
  "type": "INCOME | EXPENSE (required)",
  "category": "string (required)",
  "date": "2024-01-15 (YYYY-MM-DD, required)",
  "notes": "string (max 500 chars, optional)"
}
```

**Response**: `200 OK`
```json
{
  "id": 1,
  "amount": 1500.00,
  "type": "INCOME",
  "category": "Salary",
  "date": "2024-01-15",
  "notes": "Updated salary",
  "createdAt": "2024-01-15T10:00:00",
  "updatedAt": "2024-01-15T11:00:00"
}
```

**Error Responses**:
- `400 Bad Request` - Validation errors
- `401 Unauthorized` - Missing or invalid token / Access denied (not owner)
- `403 Forbidden` - Insufficient permissions (VIEWER cannot update)
- `404 Not Found` - Record not found

---

### Delete Financial Record
Delete a financial record.

**Endpoint**: `DELETE /api/records/{id}`  
**Authentication**: Required (JWT)  
**Authorization**: ADMIN only

**Headers**:
```
Authorization: Bearer <jwt_token>
```

**Path Parameters**:
- `id` (Long) - Record ID

**Response**: `204 No Content`

**Error Responses**:
- `401 Unauthorized` - Missing or invalid token / Access denied (not owner)
- `403 Forbidden` - Insufficient permissions (only ADMIN can delete)
- `404 Not Found` - Record not found

---

## 📊 Dashboard Endpoints

### Get Dashboard Summary
Retrieve aggregated financial analytics.

**Endpoint**: `GET /api/dashboard/summary`  
**Authentication**: Required (JWT)  
**Authorization**: All roles (VIEWER, ANALYST, ADMIN)

**Headers**:
```
Authorization: Bearer <jwt_token>
```

**Response**: `200 OK`
```json
{
  "totalIncome": 5000.00,
  "totalExpenses": 2000.00,
  "netBalance": 3000.00,
  "categoryTotals": {
    "Salary": 5000.00,
    "Rent": 1500.00,
    "Groceries": 300.00,
    "Utilities": 150.00,
    "Transportation": 50.00
  },
  "recentActivity": [
    {
      "id": 1,
      "amount": 1000.00,
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

**Fields**:
- `totalIncome` - Sum of all INCOME records
- `totalExpenses` - Sum of all EXPENSE records
- `netBalance` - totalIncome - totalExpenses
- `categoryTotals` - Sum of amounts grouped by category
- `recentActivity` - Last 10 records ordered by date (descending)

**Error Responses**:
- `401 Unauthorized` - Missing or invalid token

---

## 🔒 Authentication & Authorization

### JWT Token
All protected endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Token Expiration**: 24 hours (86400000 ms)

**How to get a token**:
1. Register: `POST /api/auth/register`
2. Login: `POST /api/auth/login`
3. Use the returned token in subsequent requests

### Role-Based Access

| Endpoint | VIEWER | ANALYST | ADMIN |
|----------|--------|---------|-------|
| POST /api/auth/register | ✓ | ✓ | ✓ |
| POST /api/auth/login | ✓ | ✓ | ✓ |
| GET /api/users | ✗ | ✗ | ✓ |
| PUT /api/users/{id}/status | ✗ | ✗ | ✓ |
| POST /api/records | ✗ | ✓ | ✓ |
| GET /api/records | ✓ | ✓ | ✓ |
| GET /api/records/{id} | ✓ | ✓ | ✓ |
| PUT /api/records/{id} | ✗ | ✓ | ✓ |
| DELETE /api/records/{id} | ✗ | ✗ | ✓ |
| GET /api/dashboard/summary | ✓ | ✓ | ✓ |

---

## 📋 Common Response Codes

### Success Codes
- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `204 No Content` - Request successful, no content to return

### Client Error Codes
- `400 Bad Request` - Invalid input or validation error
- `401 Unauthorized` - Missing, invalid, or expired token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found

### Server Error Codes
- `500 Internal Server Error` - Unexpected server error

---

## 🚨 Error Response Format

### Validation Error (400)
```json
{
  "status": 400,
  "errors": {
    "amount": "Amount must be greater than 0",
    "category": "Category is required",
    "date": "Date is required"
  },
  "timestamp": "2024-01-15T10:00:00"
}
```

### Standard Error (401, 403, 404, 500)
```json
{
  "status": 404,
  "message": "Record not found",
  "timestamp": "2024-01-15T10:00:00"
}
```

---

## 📝 Data Types & Enums

### Role Enum
```
VIEWER   - Read-only access
ANALYST  - Read and write access (except delete)
ADMIN    - Full access
```

### TransactionType Enum
```
INCOME   - Money received
EXPENSE  - Money spent
```

### Date Format
```
YYYY-MM-DD (ISO 8601)
Example: 2024-01-15
```

### DateTime Format
```
YYYY-MM-DDTHH:mm:ss (ISO 8601)
Example: 2024-01-15T10:30:00
```

### Amount Format
```
Decimal with 2 decimal places
Example: 1000.00
```

---

## 🧪 Testing Examples

### Complete Workflow Example

```bash
# 1. Register a new user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "password": "password123",
    "email": "john@example.com",
    "role": "ANALYST"
  }'

# Save the token from response

# 2. Create a financial record
curl -X POST http://localhost:8080/api/records \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5000.00,
    "type": "INCOME",
    "category": "Salary",
    "date": "2024-01-15",
    "notes": "Monthly salary"
  }'

# 3. Get all records
curl -X GET http://localhost:8080/api/records \
  -H "Authorization: Bearer YOUR_TOKEN"

# 4. Get dashboard summary
curl -X GET http://localhost:8080/api/dashboard/summary \
  -H "Authorization: Bearer YOUR_TOKEN"

# 5. Update a record
curl -X PUT http://localhost:8080/api/records/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5200.00,
    "type": "INCOME",
    "category": "Salary",
    "date": "2024-01-15",
    "notes": "Updated salary with bonus"
  }'
```

---

## 📚 Additional Resources

- **Setup Guide**: See `QUICKSTART.md`
- **Testing Guide**: See `API_TESTING_GUIDE.md`
- **Architecture**: See `ARCHITECTURE.md`
- **System Overview**: See `SYSTEM_OVERVIEW.md`

---

**API Version**: 1.0.0  
**Last Updated**: 2024  
**Base URL**: http://localhost:8080
