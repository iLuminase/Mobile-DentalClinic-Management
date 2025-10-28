package com.dentalclinic.dentalclinic_api.exception;

/**
 * Exception thrown when a user account is disabled.
 */
public class AccountDisabledException extends RuntimeException {
    
    public AccountDisabledException(String message) {
        super(message);
    }
    
    public AccountDisabledException(String username, String reason) {
        super(String.format("Tài khoản '%s' đã bị vô hiệu hóa. %s", username, reason));
    }
}
