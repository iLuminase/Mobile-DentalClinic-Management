# Test API Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Dental Clinic API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$keycloakUrl = "http://localhost:8080"
$apiUrl = "http://localhost:8081"
$realm = "dental-clinic"
$clientId = "dental-clinic-api"
$clientSecret = "d7q6Yl6Avn2UlYCwPZ1h8LeL4cLZ6bWt"
$username = "testuser"
$password = "Test@123"

# Test 1: Health Check (no auth)
Write-Host "[TEST 1] Health Check (no auth required)" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$apiUrl/api/auth/health"
    Write-Host "✓ Health check passed" -ForegroundColor Green
    $health | ConvertTo-Json
} catch {
    Write-Host "✗ Health check failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 2: Auth Info (no auth)
Write-Host "[TEST 2] Get Auth Info (no auth required)" -ForegroundColor Yellow
try {
    $authInfo = Invoke-RestMethod -Uri "$apiUrl/api/auth/info"
    Write-Host "✓ Auth info retrieved" -ForegroundColor Green
    $authInfo | ConvertTo-Json
} catch {
    Write-Host "✗ Auth info failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 3: Get Access Token
Write-Host "[TEST 3] Getting Access Token from Keycloak" -ForegroundColor Yellow
try {
    $body = @{
        grant_type = "password"
        client_id = $clientId
        client_secret = $clientSecret
        username = $username
        password = $password
    }
    
    $tokenResponse = Invoke-RestMethod -Uri "$keycloakUrl/realms/$realm/protocol/openid-connect/token" `
        -Method Post `
        -ContentType "application/x-www-form-urlencoded" `
        -Body $body
    
    $token = $tokenResponse.access_token
    Write-Host "✓ Token obtained successfully" -ForegroundColor Green
    Write-Host "Token expires in: $($tokenResponse.expires_in) seconds" -ForegroundColor Gray
    Write-Host "Token (first 50 chars): $($token.Substring(0, 50))..." -ForegroundColor Gray
} catch {
    Write-Host "✗ Failed to get token: $_" -ForegroundColor Red
    Write-Host "Make sure:" -ForegroundColor Red
    Write-Host "  1. Keycloak is running at $keycloakUrl" -ForegroundColor Red
    Write-Host "  2. User '$username' exists with password '$password'" -ForegroundColor Red
    Write-Host "  3. Client secret is correct in .env file" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 4: Get Current User (with token)
Write-Host "[TEST 4] Get Current User Info (requires auth)" -ForegroundColor Yellow
try {
    $userInfo = Invoke-RestMethod -Uri "$apiUrl/api/auth/me" `
        -Headers @{ Authorization = "Bearer $token" }
    Write-Host "✓ User info retrieved" -ForegroundColor Green
    $userInfo | ConvertTo-Json
} catch {
    Write-Host "✗ Failed to get user info: $_" -ForegroundColor Red
}
Write-Host ""

# Test 5: Validate Token
Write-Host "[TEST 5] Validate Token (requires auth)" -ForegroundColor Yellow
try {
    $validation = Invoke-RestMethod -Uri "$apiUrl/api/auth/validate" `
        -Headers @{ Authorization = "Bearer $token" }
    Write-Host "✓ Token is valid" -ForegroundColor Green
    $validation | ConvertTo-Json
} catch {
    Write-Host "✗ Token validation failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 6: Get User Roles
Write-Host "[TEST 6] Get User Roles (requires auth)" -ForegroundColor Yellow
try {
    $roles = Invoke-RestMethod -Uri "$apiUrl/api/auth/roles" `
        -Headers @{ Authorization = "Bearer $token" }
    Write-Host "✓ Roles retrieved" -ForegroundColor Green
    $roles | ConvertTo-Json
} catch {
    Write-Host "✗ Failed to get roles: $_" -ForegroundColor Red
}
Write-Host ""

# Test 7: Test without token (should fail)
Write-Host "[TEST 7] Try to access protected endpoint without token (should fail)" -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$apiUrl/api/auth/me"
    Write-Host "✗ Unexpected: endpoint accessible without token!" -ForegroundColor Red
} catch {
    Write-Host "✓ Correctly rejected: $_" -ForegroundColor Green
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Keycloak URL: $keycloakUrl" -ForegroundColor Gray
Write-Host "API URL: $apiUrl" -ForegroundColor Gray
Write-Host "Test User: $username" -ForegroundColor Gray
Write-Host "Token obtained: $(if($token) { 'Yes' } else { 'No' })" -ForegroundColor Gray
Write-Host ""
Write-Host "All tests completed!" -ForegroundColor Green
