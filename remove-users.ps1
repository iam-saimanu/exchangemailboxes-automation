param (
    [string]$tenantId,
    [string]$clientId,
    [string]$clientSecret
)

# ==========================================
# Get Access Token
# ==========================================
$body = @{
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"
    client_id     = $clientId
    client_secret = $clientSecret
}

$tokenResponse = Invoke-RestMethod `
    -Method Post `
    -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
    -Body $body

$accessToken = $tokenResponse.access_token

$headers = @{
    Authorization = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

# ==========================================
# Read CSV
# ==========================================
$csvPath = "$PSScriptRoot/terminated-users.csv"

$users = Import-Csv -Path $csvPath

# ==========================================
# Loop Users
# ==========================================
foreach ($u in $users) {

    $userEmail = $u.UserPrincipalName

    Write-Host "----------------------------------"
    Write-Host "[INFO] Processing: $userEmail"

    try {

        # ==========================================
        # Get User ID
        # ==========================================
        $existingUser = Invoke-RestMethod `
            -Method Get `
            -Uri "https://graph.microsoft.com/v1.0/users?`$filter=userPrincipalName eq '$userEmail'" `
            -Headers $headers

        if ($existingUser.value.Count -eq 0) {

            Write-Host "[INFO] User not found: $userEmail"
            continue
        }

        $userId = $existingUser.value[0].id

        # ==========================================
        # Disable Account
        # ==========================================
        $disableBody = @{
            accountEnabled = $false
        } | ConvertTo-Json

        Invoke-RestMethod `
            -Method Patch `
            -Uri "https://graph.microsoft.com/v1.0/users/$userId" `
            -Headers $headers `
            -Body $disableBody

        Write-Host "[SUCCESS] Account disabled: $userEmail"

        # ==========================================
        # Revoke Sessions
        # ==========================================
        Invoke-RestMethod `
            -Method Post `
            -Uri "https://graph.microsoft.com/v1.0/users/$userId/revokeSignInSessions" `
            -Headers $headers

        Write-Host "[SUCCESS] Sessions revoked: $userEmail"

        # ==========================================
        # OPTIONAL DELETE USER
        # Uncomment if needed
        # ==========================================

        # Invoke-RestMethod `
        #     -Method Delete `
        #     -Uri "https://graph.microsoft.com/v1.0/users/$userId" `
        #     -Headers $headers

        # Write-Host "[SUCCESS] User deleted: $userEmail"
    }
    catch {

        Write-Host "[ERROR] Failed for: $userEmail"
        Write-Host $_.Exception.Message
    }
}
