package com.dentalclinic.dentalclinic_api.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dentalclinic.dentalclinic_api.model.User;
import com.dentalclinic.dentalclinic_api.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * Service to synchronize users between Keycloak and local database
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class KeycloakUserSyncService {

    private final UserRepository userRepository;

    /**
     * Sync user from Keycloak JWT token to local database
     * Called automatically when user logs in
     * 
     * @param jwt JWT token from Keycloak
     * @return User entity (existing or newly created)
     */
    @Transactional
    public User syncUserFromToken(Jwt jwt) {
        String keycloakId = jwt.getSubject();
        String username = jwt.getClaim("preferred_username");
        String email = jwt.getClaim("email");
        String firstName = jwt.getClaim("given_name");
        String lastName = jwt.getClaim("family_name");
        String fullName = jwt.getClaim("name");

        log.info("Syncing user from Keycloak: keycloakId={}, username={}", keycloakId, username);

        Optional<User> existingUser = userRepository.findByUsername(username);

        if (existingUser.isPresent()) {
            // Update existing user
            User user = existingUser.get();
            boolean updated = false;

            if (!keycloakId.equals(user.getKeycloakId())) {
                user.setKeycloakId(keycloakId);
                updated = true;
            }

            if (email != null && !email.equals(user.getEmail())) {
                user.setEmail(email);
                updated = true;
            }

            if (fullName != null && !fullName.equals(user.getFullName())) {
                user.setFullName(fullName);
                updated = true;
            }

            if (updated) {
                user.setUpdatedAt(LocalDateTime.now());
                userRepository.save(user);
                log.info("Updated existing user: {}", username);
            } else {
                log.debug("User already up-to-date: {}", username);
            }

            return user;
        } else {
            // Create new user
            User newUser = new User();
            newUser.setKeycloakId(keycloakId);
            newUser.setUsername(username);
            newUser.setEmail(email);
            newUser.setFullName(fullName != null ? fullName : (firstName + " " + lastName));
            newUser.setActive(true);
            newUser.setCreatedAt(LocalDateTime.now());
            newUser.setUpdatedAt(LocalDateTime.now());

            // Extract primary role from JWT
            String primaryRole = extractPrimaryRole(jwt);
            if (primaryRole != null) {
                setUserRole(newUser, primaryRole); // Set deprecated field for backward compatibility
            }

            User savedUser = userRepository.save(newUser);
            log.info("Created new user from Keycloak: {}", username);
            return savedUser;
        }
    }

    /**
     * Extract primary role from JWT token
     * 
     * @param jwt JWT token
     * @return Primary role name (ADMIN, DOCTOR, etc.)
     */
    private String extractPrimaryRole(Jwt jwt) {
        Map<String, Object> realmAccess = jwt.getClaim("realm_access");
        if (realmAccess != null && realmAccess.containsKey("roles")) {
            @SuppressWarnings("unchecked")
            List<String> roles = (List<String>) realmAccess.get("roles");
            
            // Priority order: ADMIN > DIRECTOR > DOCTOR > RECEPTIONIST > ACCOUNTANT > TECHNICIAN > PATIENT
            String[] rolePriority = {"ADMIN", "DIRECTOR", "DOCTOR", "RECEPTIONIST", "ACCOUNTANT", "TECHNICIAN", "PATIENT"};
            
            for (String role : rolePriority) {
                if (roles.contains(role)) {
                    return role;
                }
            }
            
            // Return first role if no priority match
            return roles.isEmpty() ? null : roles.get(0);
        }
        return null;
    }

    /**
     * Find user by Keycloak ID
     * 
     * @param keycloakId Keycloak user ID (subject claim)
     * @return User if found
     */
    public Optional<User> findByKeycloakId(String keycloakId) {
        return userRepository.findAll().stream()
                .filter(user -> keycloakId.equals(user.getKeycloakId()))
                .findFirst();
    }

    /**
     * Check if user exists in local database
     * 
     * @param username Username
     * @return true if user exists
     */
    public boolean userExists(String username) {
        return userRepository.findByUsername(username).isPresent();
    }

    /**
     * Get user from JWT token (sync if needed)
     * 
     * @param jwt JWT token
     * @return User entity
     */
    @Transactional
    public User getUserFromToken(Jwt jwt) {
        return syncUserFromToken(jwt);
    }

    /**
     * Verify user has specific role
     * 
     * @param jwt JWT token
     * @param requiredRole Required role
     * @return true if user has the role
     */
    public boolean hasRole(Jwt jwt, String requiredRole) {
        Map<String, Object> realmAccess = jwt.getClaim("realm_access");
        if (realmAccess != null && realmAccess.containsKey("roles")) {
            @SuppressWarnings("unchecked")
            List<String> roles = (List<String>) realmAccess.get("roles");
            return roles.contains(requiredRole);
        }
        return false;
    }

    /**
     * Get all roles from JWT token
     * 
     * @param jwt JWT token
     * @return List of role names
     */
    @SuppressWarnings("unchecked")
    public List<String> getRoles(Jwt jwt) {
        Map<String, Object> realmAccess = jwt.getClaim("realm_access");
        if (realmAccess != null && realmAccess.containsKey("roles")) {
            return (List<String>) realmAccess.get("roles");
        }
        return List.of();
    }

    /**
     * Helper method to set deprecated role field
     * Suppresses deprecation warning in one place
     * 
     * @param user User entity
     * @param role Role name
     */
    @SuppressWarnings("deprecation")
    private void setUserRole(User user, String role) {
        user.setRole(role);
    }
}
