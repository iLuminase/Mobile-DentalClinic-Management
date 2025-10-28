-- =====================================================
-- DATABASE SETUP SCRIPT
-- Dental Clinic Management System
-- =====================================================
-- Hướng dẫn:
-- 1. Mở SQL Server Management Studio (SSMS)
-- 2. Connect vào SQL Server (localhost hoặc .)
-- 3. Mở file này và nhấn F5 để chạy
-- 4. Sau đó cấu hình application.yml và chạy Spring Boot
-- =====================================================

-- ============= PART 1: TẠO DATABASE =============

-- Tạo Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'DentalClinicDB')
BEGIN
    CREATE DATABASE DentalClinicDB;
    PRINT '✓ Database DentalClinicDB đã được tạo thành công.';
END
ELSE
BEGIN
    PRINT '✓ Database DentalClinicDB đã tồn tại.';
END
GO

-- Sử dụng database
USE DentalClinicDB;
GO

-- ============= PART 2: SETUP LOGIN & USER =============

-- Tạo/Reset SQL Login 'sa'
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'sa')
BEGIN
    CREATE LOGIN sa 
    WITH PASSWORD = 'admin123',
    CHECK_POLICY = OFF,
    CHECK_EXPIRATION = OFF;
    PRINT '✓ Login sa đã được tạo với password: admin123';
END
ELSE
BEGIN
    ALTER LOGIN sa WITH PASSWORD = 'admin123';
    ALTER LOGIN sa ENABLE;
    PRINT '✓ Password của login sa đã được reset thành: admin123';
END
GO

-- Tạo User trong database
USE DentalClinicDB;
GO

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'sa' AND type = 'S')
BEGIN
    CREATE USER sa FOR LOGIN sa;
    PRINT '✓ User sa đã được tạo trong database DentalClinicDB.';
END
ELSE
BEGIN
    PRINT '✓ User sa đã tồn tại trong database DentalClinicDB.';
END
GO

-- Gán quyền db_owner (full quyền)
ALTER ROLE db_owner ADD MEMBER sa;
PRINT '✓ User sa đã được gán quyền db_owner.';
GO

PRINT '';
PRINT '===================================================';
PRINT 'THÔNG TIN KẾT NỐI:';
PRINT '===================================================';
PRINT 'Server:   localhost (hoặc .)';
PRINT 'Database: DentalClinicDB';
PRINT 'Username: sa';
PRINT 'Password: admin123';
PRINT '===================================================';
PRINT '';
PRINT 'BƯỚC TIẾP THEO:';
PRINT '1. Cấu hình application.yml với thông tin trên';
PRINT '2. Chạy: mvn spring-boot:run';
PRINT '3. Spring Boot sẽ tự động:';
PRINT '   - Tạo tất cả tables (users, roles, menus, v.v.)';
PRINT '   - Insert default data (roles, admin user)';
PRINT '4. (Optional) Chạy PART 3 bên dưới để insert menu mẫu';
PRINT '===================================================';
PRINT '';
GO

-- Kiểm tra database
SELECT 
    name AS DatabaseName,
    create_date AS CreatedDate,
    compatibility_level AS CompatibilityLevel
FROM sys.databases 
WHERE name = 'DentalClinicDB';
GO

-- ============= PART 3: INSERT MENU MẪU (OPTIONAL) =============
-- Chạy phần này SAU KHI Spring Boot đã tạo tables
-- Hoặc để Spring Boot tự động tạo qua DataInitializer.java

/*
-- Uncomment phần này nếu muốn insert menu thủ công:

USE DentalClinicDB;
GO

-- Kiểm tra table menus đã tồn tại chưa
IF OBJECT_ID('menus', 'U') IS NOT NULL
BEGIN
    SET IDENTITY_INSERT menus ON;

    -- Menu chính
    INSERT INTO menus (id, name, title, path, icon, order_index, parent_id, active, created_at, updated_at)
    VALUES 
    (1, 'dashboard', N'Tổng quan', '/dashboard', 'dashboard', 1, NULL, 1, GETDATE(), GETDATE()),
    (2, 'users', N'Quản lý người dùng', '/users', 'people', 2, NULL, 1, GETDATE(), GETDATE()),
    (3, 'patients', N'Quản lý bệnh nhân', '/patients', 'person', 3, NULL, 1, GETDATE(), GETDATE()),
    (4, 'patients-list', N'Danh sách bệnh nhân', '/patients/list', 'list', 1, 3, 1, GETDATE(), GETDATE()),
    (5, 'patients-add', N'Thêm bệnh nhân', '/patients/add', 'add', 2, 3, 1, GETDATE(), GETDATE()),
    (6, 'appointments', N'Quản lý lịch hẹn', '/appointments', 'calendar_today', 4, NULL, 1, GETDATE(), GETDATE()),
    (7, 'appointments-list', N'Danh sách lịch hẹn', '/appointments/list', 'list', 1, 6, 1, GETDATE(), GETDATE()),
    (8, 'appointments-add', N'Đặt lịch mới', '/appointments/add', 'add', 2, 6, 1, GETDATE(), GETDATE()),
    (9, 'medical-records', N'Hồ sơ bệnh án', '/medical-records', 'description', 5, NULL, 1, GETDATE(), GETDATE()),
    (10, 'services', N'Dịch vụ nha khoa', '/services', 'medical_services', 6, NULL, 1, GETDATE(), GETDATE()),
    (11, 'invoices', N'Hóa đơn', '/invoices', 'receipt', 7, NULL, 1, GETDATE(), GETDATE()),
    (12, 'reports', N'Báo cáo', '/reports', 'assessment', 8, NULL, 1, GETDATE(), GETDATE()),
    (13, 'settings', N'Cài đặt', '/settings', 'settings', 9, NULL, 1, GETDATE(), GETDATE());

    SET IDENTITY_INSERT menus OFF;

    -- Phân quyền menu (menu_roles)
    -- ROLE_ADMIN=1, ROLE_DOCTOR=2, ROLE_RECEPTIONIST=3, ROLE_VIEWER=4

    -- Dashboard - Tất cả roles
    INSERT INTO menu_roles (menu_id, role_id) VALUES (1, 1), (1, 2), (1, 3);

    -- Users - Admin only
    INSERT INTO menu_roles (menu_id, role_id) VALUES (2, 1);

    -- Patients - Admin, Receptionist
    INSERT INTO menu_roles (menu_id, role_id) VALUES (3, 1), (3, 3);
    INSERT INTO menu_roles (menu_id, role_id) VALUES (4, 1), (4, 3);
    INSERT INTO menu_roles (menu_id, role_id) VALUES (5, 1), (5, 3);

    -- Appointments - Admin, Doctor, Receptionist
    INSERT INTO menu_roles (menu_id, role_id) VALUES (6, 1), (6, 2), (6, 3);
    INSERT INTO menu_roles (menu_id, role_id) VALUES (7, 1), (7, 2), (7, 3);
    INSERT INTO menu_roles (menu_id, role_id) VALUES (8, 1), (8, 3);

    -- Medical Records - Admin, Doctor
    INSERT INTO menu_roles (menu_id, role_id) VALUES (9, 1), (9, 2);

    -- Services - Admin, Receptionist
    INSERT INTO menu_roles (menu_id, role_id) VALUES (10, 1), (10, 3);

    -- Invoices - Admin, Receptionist
    INSERT INTO menu_roles (menu_id, role_id) VALUES (11, 1), (11, 3);

    -- Reports - Admin only
    INSERT INTO menu_roles (menu_id, role_id) VALUES (12, 1);

    -- Settings - Admin only
    INSERT INTO menu_roles (menu_id, role_id) VALUES (13, 1);

    PRINT '✓ Đã insert menu mẫu thành công!';
    PRINT '';
    SELECT COUNT(*) AS TotalMenus FROM menus;
    SELECT COUNT(*) AS TotalMenuRoles FROM menu_roles;
END
ELSE
BEGIN
    PRINT '⚠ Table menus chưa tồn tại. Vui lòng chạy Spring Boot trước.';
END
GO
*/

-- ============= KẾT THÚC =============
PRINT '';
PRINT '===================================================';
PRINT 'DATABASE SETUP HOÀN TẤT!';
PRINT '===================================================';
PRINT 'Giờ bạn có thể chạy Spring Boot application.';
PRINT '';
