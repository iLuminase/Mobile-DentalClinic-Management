-- =====================================================
-- Script Setup Database cho Dental Clinic Management
-- Chạy script này trong SQL Server Management Studio
-- =====================================================

-- Bước 1: Tạo Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'DentalClinicDB')
BEGIN
    CREATE DATABASE DentalClinicDB;
    PRINT 'Database DentalClinicDB đã được tạo thành công.';
END
ELSE
BEGIN
    PRINT 'Database DentalClinicDB đã tồn tại.';
END
GO

-- Bước 2: Sử dụng database
USE DentalClinicDB;
GO

-- Bước 3: Tạo hoặc cập nhật SQL Login 'sa' (nếu cần)
-- Nếu bạn muốn dùng account khác, thay 'sa' bằng tên khác
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'sa')
BEGIN
    CREATE LOGIN sa 
    WITH PASSWORD = 'admin123',
    CHECK_POLICY = OFF,
    CHECK_EXPIRATION = OFF;
    PRINT 'Login sa đã được tạo với password: admin123';
END
ELSE
BEGIN
    -- Nếu đã có, reset password
    ALTER LOGIN sa WITH PASSWORD = 'admin123';
    ALTER LOGIN sa ENABLE;
    PRINT 'Password của login sa đã được reset thành: admin123';
END
GO

-- Bước 4: Tạo User trong database
USE DentalClinicDB;
GO

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'sa' AND type = 'S')
BEGIN
    CREATE USER sa FOR LOGIN sa;
    PRINT 'User sa đã được tạo trong database DentalClinicDB.';
END
ELSE
BEGIN
    PRINT 'User sa đã tồn tại trong database DentalClinicDB.';
END
GO

-- Bước 5: Gán quyền db_owner (full quyền)
ALTER ROLE db_owner ADD MEMBER sa;
GO

PRINT '===================================================';
PRINT 'Setup hoàn tất! Thông tin kết nối:';
PRINT 'Server: localhost (hoặc .)';
PRINT 'Database: DentalClinicDB';
PRINT 'Username: sa';
PRINT 'Password: admin123';
PRINT '===================================================';
PRINT '';
PRINT 'Bây giờ bạn có thể:';
PRINT '1. Cập nhật application.yml với thông tin kết nối';
PRINT '2. Chạy lệnh: mvn spring-boot:run';
PRINT '3. Application sẽ tự động tạo tables và import dữ liệu mẫu';
PRINT '===================================================';
GO

-- Kiểm tra database đã tạo thành công
SELECT 
    name AS DatabaseName,
    create_date AS CreatedDate,
    compatibility_level AS CompatibilityLevel
FROM sys.databases 
WHERE name = 'DentalClinicDB';
GO
