---
applyTo: '**'
description: '# Copilot Instructions for Dental Clinic Management Project

## Project Overview
- Xây dựng ứng dụng quản lý phòng khám nha khoa cho người Việt Nam (múi giờ Asia/Ho_Chi_Minh, UTC+7).
- Frontend: Dart + Flutter; Backend: Java Spring Boot; DB: MySQL (ban đầu local, sau có thể Azure).
- Chức năng: quản lý bệnh nhân, bác sĩ, dịch vụ, đặt lịch khám, hóa đơn, lịch sử khám.

## Coding Standards & Architecture
- Backend: tách rõ controller / service / repository / dto / entity / exception / mapper layers.
- Dùng Bean Validation ở DTO, sử dụng MapStruct (nếu được) để mapping entity <-> DTO.
- Tất cả datetime lưu trong DB theo UTC; UI hiển thị theo Asia/Ho_Chi_Minh; dùng ISO-8601 cho giao tiếp JSON.
- Sử dụng HTTP status codes chuẩn, lỗi trả về cấu trúc thống nhất: mã lỗi, thông báo, chi tiết các field nếu validate.
- Viết unit test cho service, integration test cho controller; logging & exception handling dùng `@ControllerAdvice`.

## Frontend Standards
- Mô hình state management: sử dụng Provider/Bloc (chọn một) và giữ consistency.
- Reusable widgets; form validation; input mask cho số điện thoại / ID; hiển thị ngày giờ theo locale vi_VN.
- API client rõ ràng, tách service + model.

## Other Rules
- Code cần có comment nếu logic không đơn giản.
- Functions/methods có tên rõ ràng, dùng tiếng Anh cho code (tên biến, class, methods), message lỗi có thể tiếng Việt khi hiển thị user.
- Tạo mẫu code skeleton cho một entity (ví dụ Patient) để mọi entity sau này theo pattern đó.
'
---

