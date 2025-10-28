package com.dentalclinic.dentalclinic_api.dto;

import java.util.List;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO cho request cập nhật roles của menu.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateMenuRolesRequest {
    
    @NotNull(message = "Danh sách roles không được null")
    @NotEmpty(message = "Danh sách roles không được rỗng")
    private List<String> roleNames;
}
