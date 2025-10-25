package com.dentalclinic.dentalclinic_api.model.enums;

/**
 * Enum for permission actions
 */
public enum ActionType {
    CREATE,     // Tạo mới
    READ,       // Xem/Đọc
    UPDATE,     // Cập nhật
    DELETE,     // Xóa
    APPROVE,    // Phê duyệt
    REJECT,     // Từ chối
    EXPORT,     // Xuất dữ liệu
    IMPORT,     // Nhập dữ liệu
    ASSIGN,     // Gán phân công
    CANCEL      // Hủy
}
