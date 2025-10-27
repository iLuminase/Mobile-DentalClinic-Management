package com.dentalclinic.dentalclinic_api.dto;

import java.util.ArrayList;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// DTO Menu response cho frontend
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenuResponse {
    
    private Long id;
    private String name;
    private String title;
    private String path;
    private String icon;
    private Integer orderIndex;
    private Long parentId;
    
    @Builder.Default
    private List<MenuResponse> children = new ArrayList<>();
    
    private Boolean active;
}
