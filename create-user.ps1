$tenantId = "<TENANT_ID>"
$clientId = "<CLIENT_ID>"
$clientSecret = "<CLIENT_SECRET>"

# Get Access Token
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

# User Data
$user = @{
    accountEnabled = $true
    displayName    = "DevOps User"
    mailNickname   = "devopsuser"
    userPrincipalName = "devopsuser@yourtenant.onmicrosoft.com"
    passwordProfile = @{
        forceChangePasswordNextSignIn = $true
        password = "Temp@123456"
    }
}

# Create User
Invoke-RestMethod -Method Post `
    -Uri "https://graph.microsoft.com/v1.0/users" `
    -Headers @{Authorization = "Bearer $accessToken"} `
    -Body ($user | ConvertTo-Json -Depth 10) `
    -ContentType "application/json"
