package com.dentalclinic.dentalclinic_api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO cho response đổi/reset mật khẩu
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PasswordResponse {
    
    private boolean success;
    private String message;
    private String username;
    private String newPassword; // Chỉ dùng khi admin reset (để thông báo password mới)
    
    public PasswordResponse(boolean success, String message) {
        this.success = success;
        this.message = message;
    }
    
    public PasswordResponse(boolean success, String message, String username) {
        this.success = success;
        this.message = message;
        this.username = username;
    }
}
