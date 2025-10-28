package com.dentalclinic.dentalclinic_api.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO cho Role response.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoleResponse {
    private Long id;
    private String name;
    private String description;
    private Boolean active;
    private Long userCount; // Số lượng users có role này
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
