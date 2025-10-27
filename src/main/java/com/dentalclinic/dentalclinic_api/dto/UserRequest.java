package com.dentalclinic.dentalclinic_api.dto;

import java.time.LocalDateTime;
import java.util.Set;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for creating/updating user.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserRequest {

    @NotBlank(message = "Tên đăng nhập không được để trống")
    @Size(min = 3, max = 50, message = "Tên đăng nhập phải từ 3 đến 50 ký tự")
    private String username;

    @Size(min = 8, message = "Mật khẩu phải có ít nhất 8 ký tự")
    private String password; // Optional for update

    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không hợp lệ")
    private String email;

    private String fullName;

    private String phoneNumber;

    private LocalDateTime dateOfBirth;

    private String address;

    private Set<String> roleNames; // e.g., ["ROLE_DOCTOR", "ROLE_ADMIN"]

    private Boolean active = true;
}
