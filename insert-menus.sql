-- Script insert menu mẫu vào database
USE DentalClinicDB;
GO

-- Insert menus
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
GO

-- Insert menu_roles (phân quyền)
-- Giả sử: ROLE_ADMIN=1, ROLE_DOCTOR=2, ROLE_RECEPTIONIST=3

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

GO

PRINT 'Đã insert menus thành công!';
PRINT '';
PRINT 'Kiểm tra:';
SELECT COUNT(*) AS TotalMenus FROM menus;
SELECT COUNT(*) AS TotalMenuRoles FROM menu_roles;
GO
