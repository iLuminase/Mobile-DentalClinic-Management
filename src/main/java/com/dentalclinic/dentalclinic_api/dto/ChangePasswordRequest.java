package com.dentalclinic.dentalclinic_api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO cho yêu cầu đổi mật khẩu (user tự đổi)
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChangePasswordRequest {
    
    @NotBlank(message = "Mat khau hien tai khong duoc de trong")
    private String currentPassword;
    
    @NotBlank(message = "Mat khau moi khong duoc de trong")
    @Size(min = 6, message = "Mat khau moi phai co it nhat 6 ky tu")
    private String newPassword;
    
    @NotBlank(message = "Xac nhan mat khau khong duoc de trong")
    private String confirmPassword;
}
