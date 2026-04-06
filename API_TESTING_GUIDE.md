# API Testing Guide

This document provides sample API requests for testing the Finance Backend application.

## Setup

1. Start the application: `mvn spring-boot:run`
2. Base URL: `http://localhost:8080`

## Test Flow

### 1. Register Users

#### Register Admin User
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123",
    "email": "admin@finance.com",
    "role": "ADMIN"
  }'
```

#### Register Analyst User
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "analyst",
    "password": "analyst123",
    "email": "analyst@finance.com",
    "role": "ANALYST"
  }'
```

#### Register Viewer User
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "viewer",
    "password": "viewer123",
    "email": "viewer@finance.com",
    "role": "VIEWER"
  }'
```

**Expected Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "admin",
  "email": "admin@finance.com",
  "role": "ADMIN"
}
```

Save the token for subsequent requests.

### 2. Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'
```

### 3. Create Financial Records (ADMIN/ANALYST)

#### Create Income Record
```bash
curl -X POST http://localhost:8080/api/records \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5000.00,
    "type": "INCOME",
    "category": "Salary",
    "date": "2024-01-15",
    "notes": "Monthly salary payment"
  }'
```

#### Create Expense Records
```bash
# Rent
curl -X POST http://localhost:8080/api/records \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 1500.00,
    "type": "EXPENSE",
    "category": "Rent",
    "date": "2024-01-01",
    "notes": "Monthly rent"
  }'

# Groceries
curl -X POST http://localhost:8080/api/records \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 300.00,
    "type": "EXPENSE",
    "category": "Groceries",
    "date": "2024-01-10",
    "notes": "Weekly groceries"
  }'

# Utilities
curl -X POST http://localhost:8080/api/records \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 150.00,
    "type": "EXPENSE",
    "category": "Utilities",
    "date": "2024-01-05",
    "notes": "Electricity and water"
  }'
```

### 4. Get All Records (All Roles)

#### Basic Request
```bash
curl -X GET http://localhost:8080/api/records \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### With Pagination
```bash
curl -X GET "http://localhost:8080/api/records?page=0&size=5&sortBy=date&sortDir=DESC" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### Filter by Type
```bash
curl -X GET "http://localhost:8080/api/records?type=INCOME" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### Filter by Category
```bash
curl -X GET "http://localhost:8080/api/records?category=Salary" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### Filter by Date Range
```bash
curl -X GET "http://localhost:8080/api/records?startDate=2024-01-01&endDate=2024-01-31" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### Combined Filters
```bash
curl -X GET "http://localhost:8080/api/records?type=EXPENSE&startDate=2024-01-01&endDate=2024-01-31&page=0&size=10" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 5. Get Record by ID (All Roles)

```bash
curl -X GET http://localhost:8080/api/records/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 6. Update Record (ADMIN/ANALYST)

```bash
curl -X PUT http://localhost:8080/api/records/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5200.00,
    "type": "INCOME",
    "category": "Salary",
    "date": "2024-01-15",
    "notes": "Updated monthly salary with bonus"
  }'
```

### 7. Get Dashboard Summary (All Roles)

```bash
curl -X GET http://localhost:8080/api/dashboard/summary \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "totalIncome": 5000.00,
  "totalExpenses": 1950.00,
  "netBalance": 3050.00,
  "categoryTotals": {
    "Salary": 5000.00,
    "Rent": 1500.00,
    "Groceries": 300.00,
    "Utilities": 150.00
  },
  "recentActivity": [
    {
      "id": 1,
      "amount": 5000.00,
      "type": "INCOME",
      "category": "Salary",
      "date": "2024-01-15",
      "notes": "Monthly salary payment",
      "createdAt": "2024-01-15T10:00:00",
      "updatedAt": "2024-01-15T10:00:00"
    }
  ]
}
```

### 8. User Management (ADMIN Only)

#### Get All Users
```bash
curl -X GET http://localhost:8080/api/users \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN_HERE"
```

#### Update User Status
```bash
# Deactivate user
curl -X PUT "http://localhost:8080/api/users/2/status?active=false" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN_HERE"

# Activate user
curl -X PUT "http://localhost:8080/api/users/2/status?active=true" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN_HERE"
```

### 9. Delete Record (ADMIN Only)

```bash
curl -X DELETE http://localhost:8080/api/records/1 \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN_HERE"
```

## Testing Access Control

### Test VIEWER Restrictions

1. Login as viewer
2. Try to create a record (should fail with 403 Forbidden):
```bash
curl -X POST http://localhost:8080/api/records \
  -H "Authorization: Bearer VIEWER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100.00,
    "type": "INCOME",
    "category": "Test",
    "date": "2024-01-15",
    "notes": "Test"
  }'
```

### Test ANALYST Restrictions

1. Login as analyst
2. Try to delete a record (should fail with 403 Forbidden):
```bash
curl -X DELETE http://localhost:8080/api/records/1 \
  -H "Authorization: Bearer ANALYST_TOKEN"
```

## Error Scenarios

### Invalid Token
```bash
curl -X GET http://localhost:8080/api/records \
  -H "Authorization: Bearer INVALID_TOKEN"
```
**Expected:** 401 Unauthorized

### Missing Required Fields
```bash
curl -X POST http://localhost:8080/api/records \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100.00,
    "type": "INCOME"
  }'
```
**Expected:** 400 Bad Request with validation errors

### Invalid Amount
```bash
curl -X POST http://localhost:8080/api/records \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": -100.00,
    "type": "INCOME",
    "category": "Test",
    "date": "2024-01-15"
  }'
```
**Expected:** 400 Bad Request

### Record Not Found
```bash
curl -X GET http://localhost:8080/api/records/99999 \
  -H "Authorization: Bearer YOUR_TOKEN"
```
**Expected:** 404 Not Found

## Postman Collection

You can import these requests into Postman:

1. Create a new collection
2. Add an environment variable `token` for the JWT token
3. Set Authorization header as `Bearer {{token}}`
4. Import the requests above

## Notes

- Replace `YOUR_TOKEN_HERE` with actual JWT token from login/register
- Tokens expire after 24 hours (configurable in application.properties)
- All dates should be in ISO format (YYYY-MM-DD)
- Amounts should be positive decimal numbers
