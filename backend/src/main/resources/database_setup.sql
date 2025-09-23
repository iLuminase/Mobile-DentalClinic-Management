# Database setup SQL script for MySQL
# Run this script to create the dental clinic database and initial admin user

CREATE DATABASE IF NOT EXISTS dental_clinic_db;
USE dental_clinic_db;

# Tables will be auto-created by JPA/Hibernate
# But we can create an initial admin user

# After running the Spring Boot application once to create tables, run this:
# INSERT INTO employees (first_name, last_name, email, password, phone_number, role, status, created_at, updated_at)
# VALUES ('Admin', 'User', 'admin@dentalclinic.com', '$2a$12$LQv3c1yqBwWFxgUh/zQNDu/bxdkHgN89JWV.7VeF7V0w6nPuHnq.a', '1234567890', 'ADMIN', 'ACTIVE', NOW(), NOW());

# Password for the admin user is 'password' (hashed with BCrypt)