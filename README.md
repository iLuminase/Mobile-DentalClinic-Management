# Dental Clinic Management System

A comprehensive mobile application for managing dental clinic operations, built with Flutter for the frontend and Spring Boot for the backend.

## Project Overview

This system provides a complete solution for dental clinic management, including:
- Employee management
- Customer/patient management
- Appointment booking and scheduling
- Treatment tracking
- Role-based access control

## Architecture

### Frontend (Flutter/Dart)
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **HTTP Client**: http package
- **Local Storage**: SharedPreferences
- **UI**: Material Design

### Backend (Java Spring Boot)
- **Framework**: Spring Boot 3.2.0
- **Database**: MySQL 8.0
- **ORM**: JPA/Hibernate
- **Security**: Spring Security with JWT
- **API**: RESTful web services

### Database
- **Primary**: MySQL
- **Test**: H2 (in-memory for testing)

## Features

### Core Functionality
1. **Employee Management**
   - Add, edit, delete employees
   - Role-based permissions (Admin, Dentist, Receptionist, Assistant)
   - Employee status tracking

2. **Customer Management**
   - Customer registration and profiles
   - Medical history and allergies tracking
   - Contact information management

3. **Appointment Management**
   - Book, edit, cancel appointments
   - Real-time scheduling
   - Conflict detection
   - Status tracking (Scheduled, Confirmed, In Progress, Completed, etc.)

4. **Authentication & Authorization**
   - Secure login system
   - Role-based access control
   - JWT token authentication

## Getting Started

### Prerequisites
- Java 17 or higher
- Maven 3.6+
- MySQL 8.0+
- Flutter 3.x
- Dart SDK
- Android Studio / VS Code (for mobile development)

### Backend Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Mobile-DentalClinic-Management/backend
   ```

2. **Configure Database**
   - Install MySQL 8.0
   - Create database: `dental_clinic_db`
   - Update `application.properties` with your database credentials:
     ```properties
     spring.datasource.url=jdbc:mysql://localhost:3306/dental_clinic_db
     spring.datasource.username=your_username
     spring.datasource.password=your_password
     ```

3. **Run the application**
   ```bash
   mvn spring-boot:run
   ```

   The backend will start on `http://localhost:8080`

4. **API Documentation**
   Access the REST API at `http://localhost:8080/api`

### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd ../frontend/dental_clinic_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   Update the `baseUrl` in `lib/services/api_service.dart` if needed:
   ```dart
   static const String baseUrl = 'http://localhost:8080/api';
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Database Setup

1. **Run the SQL script**
   ```bash
   mysql -u root -p < backend/src/main/resources/database_setup.sql
   ```

2. **Create initial admin user** (after first run)
   ```sql
   INSERT INTO employees (first_name, last_name, email, password, phone_number, role, status, created_at, updated_at)
   VALUES ('Admin', 'User', 'admin@dentalclinic.com', '$2a$12$LQv3c1yqBwWFxgUh/zQNDu/bxdkHgN89JWV.7VeF7V0w6nPuHnq.a', '1234567890', 'ADMIN', 'ACTIVE', NOW(), NOW());
   ```

## API Endpoints

### Employee Management
- `GET /api/employees` - Get all employees
- `POST /api/employees` - Create new employee
- `PUT /api/employees/{id}` - Update employee
- `DELETE /api/employees/{id}` - Delete employee
- `GET /api/employees/role/{role}` - Get employees by role

### Customer Management
- `GET /api/customers` - Get all customers
- `POST /api/customers` - Create new customer
- `PUT /api/customers/{id}` - Update customer
- `DELETE /api/customers/{id}` - Delete customer
- `GET /api/customers/search?name={name}` - Search customers

### Appointment Management
- `GET /api/appointments` - Get all appointments
- `POST /api/appointments` - Create new appointment
- `PUT /api/appointments/{id}` - Update appointment
- `DELETE /api/appointments/{id}` - Delete appointment
- `GET /api/appointments/employee/{id}` - Get appointments by employee
- `GET /api/appointments/customer/{id}` - Get appointments by customer

## Demo Credentials

For testing purposes, you can use these credentials:
- **Admin**: admin@dentalclinic.com / password
- **Staff**: staff@dentalclinic.com / password

## Project Structure

```
Mobile-DentalClinic-Management/
├── backend/                    # Spring Boot backend
│   ├── src/main/java/com/dentalclinic/
│   │   ├── entity/            # JPA entities
│   │   ├── repository/        # Data repositories
│   │   ├── service/           # Business logic
│   │   ├── controller/        # REST controllers
│   │   ├── dto/              # Data transfer objects
│   │   ├── config/           # Configuration classes
│   │   └── security/         # Security configuration
│   ├── src/main/resources/    # Configuration files
│   └── pom.xml               # Maven dependencies
├── frontend/dental_clinic_app/ # Flutter frontend
│   ├── lib/
│   │   ├── models/           # Data models
│   │   ├── services/         # API and auth services
│   │   ├── screens/          # UI screens
│   │   ├── widgets/          # Reusable widgets
│   │   └── main.dart         # App entry point
│   └── pubspec.yaml          # Flutter dependencies
└── README.md
```

## Technologies Used

### Backend
- Spring Boot 3.2.0
- Spring Data JPA
- Spring Security
- MySQL Connector
- JWT Authentication
- Maven

### Frontend
- Flutter 3.x
- Dart
- Provider (State Management)
- HTTP Client
- Material Design
- SharedPreferences

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the GitHub repository.