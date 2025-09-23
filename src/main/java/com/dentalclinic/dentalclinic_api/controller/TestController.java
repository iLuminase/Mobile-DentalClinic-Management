package com.dentalclinic.dentalclinic_api.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.Map;

/**
 * Test controller to verify application is running correctly
 */
@RestController
@RequestMapping("/api/public")
@Tag(name = "Public APIs", description = "Public endpoints that don't require authentication")
public class TestController {

    @GetMapping("/health")
    @Operation(summary = "Health check", description = "Check if the API is running and get server status")
    @ApiResponse(responseCode = "200", description = "API is running successfully")
    public Map<String, Object> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("message", "Dental Clinic API is running successfully");
        response.put("timestamp", LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")));
        response.put("timezone", "UTC+7 (Vietnam)");
        return response;
    }

    @GetMapping("/info")
    @Operation(summary = "API information", description = "Get information about the API")
    @ApiResponse(responseCode = "200", description = "API information retrieved successfully")
    public Map<String, String> getApiInfo() {
        Map<String, String> info = new HashMap<>();
        info.put("name", "Dental Clinic Management API");
        info.put("version", "1.0.0");
        info.put("description", "API for managing dental clinic appointments and patient records");
        info.put("location", "Vietnam");
        info.put("swaggerUrl", "http://localhost:8080/swagger-ui.html");
        info.put("h2Console", "http://localhost:8080/h2-console");
        return info;
    }
}
