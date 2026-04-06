# Quick Start Guide

Get the Finance Backend up and running in 5 minutes!

## Prerequisites Check

```bash
# Check Java version (need 17+)
java -version

# Check Maven version (need 3.6+)
mvn -version

# Check MySQL is running
mysql --version
```

## Step 1: Database Setup

### Option A: Auto-create (Recommended)
The application will automatically create the database. Just ensure MySQL is running:

```bash
# Windows
net start MySQL80

# Linux/Mac
sudo systemctl start mysql
# or
brew services start mysql
```

### Option B: Manual creation
```sql
mysql -u root -p
CREATE DATABASE finance_db;
EXIT;
```

## Step 2: Configure Database Credentials

Edit `src/main/resources/application.properties`:

```properties
spring.datasource.username=root
spring.datasource.password=your_password
```

## Step 3: Build and Run

```bash
# Build the project
mvn clean install

# Run the application
mvn spring-boot:run
```

Wait for: `Started FinanceBackendApplication in X seconds`

## Step 4: Test the API

### Quick Test with Sample Data

The application automatically creates 3 test users:

| Username | Password | Role |
|----------|----------|------|
| admin | admin123 | ADMIN |
| analyst | analyst123 | ANALYST |
| viewer | viewer123 | VIEWER |

### Login and Get Token

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Copy the token from the response.

### View Dashboard

```bash
curl -X GET http://localhost:8080/api/dashboard/summary \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

You should see sample financial data!

## Step 5: Explore the API

- **API Documentation**: See `API_TESTING_GUIDE.md`
- **Full Documentation**: See `README.md`

## Common Issues

### Issue: Port 8080 already in use
**Solution**: Change port in `application.properties`:
```properties
server.port=8081
```

### Issue: MySQL connection refused
**Solution**: 
1. Check MySQL is running
2. Verify credentials in `application.properties`
3. Check MySQL is on port 3306

### Issue: Access denied for user
**Solution**: Update username/password in `application.properties`

### Issue: Table doesn't exist
**Solution**: Ensure `spring.jpa.hibernate.ddl-auto=update` in properties

## Next Steps

1. ✅ Test all API endpoints (see `API_TESTING_GUIDE.md`)
2. ✅ Try different user roles to see access control
3. ✅ Create your own financial records
4. ✅ Explore filtering and pagination
5. ✅ Build a frontend (optional)

## Stopping the Application

Press `Ctrl + C` in the terminal where the application is running.

## Need Help?

- Check `README.md` for detailed documentation
- Review `API_TESTING_GUIDE.md` for API examples
- Verify MySQL is running and accessible
- Check application logs for error messages

## Sample API Workflow

```bash
# 1. Login
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' | jq -r '.token')

# 2. Create a record
curl -X POST http://localhost:8080/api/records \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 1000.00,
    "type": "INCOME",
    "category": "Bonus",
    "date": "2024-01-20",
    "notes": "Year-end bonus"
  }'

# 3. View all records
curl -X GET http://localhost:8080/api/records \
  -H "Authorization: Bearer $TOKEN"

# 4. View dashboard
curl -X GET http://localhost:8080/api/dashboard/summary \
  -H "Authorization: Bearer $TOKEN"
```

Happy coding! 🚀
