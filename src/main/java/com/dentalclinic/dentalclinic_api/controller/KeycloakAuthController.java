package com.dentalclinic.dentalclinic_api.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Authentication controller for Keycloak integration
 */
@RestController
@RequestMapping("/api/auth")
public class KeycloakAuthController {

    @Value("${spring.security.oauth2.resourceserver.jwt.issuer-uri}")
    private String keycloakIssuerUri;

    /**
     * Get Keycloak authentication URLs
     * Frontend will use these URLs to redirect users for authentication
     */
    @GetMapping("/info")
    public ResponseEntity<?> getAuthInfo() {
        Map<String, String> authInfo = new HashMap<>();
        authInfo.put("issuerUri", keycloakIssuerUri);
        authInfo.put("loginUrl", keycloakIssuerUri + "/protocol/openid-connect/auth");
        authInfo.put("tokenUrl", keycloakIssuerUri + "/protocol/openid-connect/token");
        authInfo.put("logoutUrl", keycloakIssuerUri + "/protocol/openid-connect/logout");
        authInfo.put("userInfoUrl", keycloakIssuerUri + "/protocol/openid-connect/userinfo");
        
        return ResponseEntity.ok(authInfo);
    }

    /**
     * Get current user information from JWT token
     */
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(@AuthenticationPrincipal Jwt jwt) {
        if (jwt == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Not authenticated"));
        }

        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("sub", jwt.getSubject());
        userInfo.put("username", jwt.getClaim("preferred_username"));
        userInfo.put("email", jwt.getClaim("email"));
        userInfo.put("name", jwt.getClaim("name"));
        userInfo.put("givenName", jwt.getClaim("given_name"));
        userInfo.put("familyName", jwt.getClaim("family_name"));
        userInfo.put("roles", jwt.getClaim("realm_access"));
        
        return ResponseEntity.ok(userInfo);
    }

    /**
     * Validate token endpoint
     */
    @GetMapping("/validate")
    public ResponseEntity<?> validateToken(@AuthenticationPrincipal Jwt jwt) {
        if (jwt == null) {
            return ResponseEntity.status(401).body(Map.of("valid", false));
        }

        Map<String, Object> response = new HashMap<>();
        response.put("valid", true);
        response.put("username", jwt.getClaim("preferred_username"));
        response.put("expiresAt", jwt.getExpiresAt());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get user roles
     */
    @GetMapping("/roles")
    public ResponseEntity<?> getUserRoles(@AuthenticationPrincipal Jwt jwt) {
        if (jwt == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Not authenticated"));
        }

        Map<String, Object> realmAccess = jwt.getClaim("realm_access");
        return ResponseEntity.ok(Map.of("roles", realmAccess != null ? realmAccess.get("roles") : new String[]{}));
    }

    /**
     * Health check endpoint (no authentication required)
     */
    @GetMapping("/health")
    public ResponseEntity<?> health() {
        return ResponseEntity.ok(Map.of(
            "status", "UP",
            "keycloakConfigured", keycloakIssuerUri != null
        ));
    }
}
