package com.dentalclinic.dentalclinic_api.dto;

import java.util.Set;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// DTO tạo/cập nhật menu
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenuRequest {

    @NotBlank(message = "Tên menu không được để trống")
    private String name;

    @NotBlank(message = "Tiêu đề không được để trống")
    private String title;

    private String path;
    private String icon;

    @NotNull(message = "Thứ tự không được để trống")
    private Integer orderIndex;

    private Long parentId;
    private Set<String> roleNames; // Danh sách tên roles
    private Boolean active;
}
