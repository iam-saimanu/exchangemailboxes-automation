# ==============================
# Azure Credentials
# ==============================
$tenantId = "<TENANT_ID>"
$clientId = "<CLIENT_ID>"
$clientSecret = "<CLIENT_SECRET>"

# ==============================
# Get Access Token
# ==============================
$body = @{
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"
    client_id     = $clientId
    client_secret = $clientSecret
}

$tokenResponse = Invoke-RestMethod -Method Post `
    -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
    -Body $body

$accessToken = $tokenResponse.access_token

# ==============================
# Read CSV File
# ==============================
$users = Import-Csv -Path "users.csv"

# ==============================
# Loop Through Users
# ==============================
foreach ($u in $users) {

    $user = @{
        accountEnabled = $true
        displayName    = $u.DisplayName
        mailNickname   = $u.MailNickname
        userPrincipalName = $u.UserPrincipalName
        passwordProfile = @{
            forceChangePasswordNextSignIn = $true
            password = $u.Password
        }
    }

    try {
        Invoke-RestMethod -Method Post `
            -Uri "https://graph.microsoft.com/v1.0/users" `
            -Headers @{Authorization = "Bearer $accessToken"} `
            -Body ($user | ConvertTo-Json -Depth 10) `
            -ContentType "application/json"

        Write-Host "✅ User created: $($u.UserPrincipalName)"
    }
    catch {
        Write-Host "❌ Failed: $($u.UserPrincipalName)"
        Write-Host $_
    }
}
