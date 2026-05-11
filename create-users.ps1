param (
    [string]$tenantId,
    [string]$clientId,
    [string]$clientSecret
)

Write-Host "Tenant: $tenantId"
Write-Host "Client: $clientId"
Write-Host "Secret length: $($clientSecret.Length)"

# ==========================================
# Get Microsoft Graph Access Token
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

if (-not $accessToken) {
    Write-Host "[ERROR] Token NOT generated"
    exit 1
}

# ==========================================
# Headers
# ==========================================
$headers = @{
    Authorization = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

# ==========================================
# Read CSV
# ==========================================
$csvPath = "$PSScriptRoot/users.csv"

if (-not (Test-Path $csvPath)) {
    Write-Host "[ERROR] users.csv not found"
    exit 1
}

$users = Import-Csv -Path $csvPath

# ==========================================
# Loop Through Users
# ==========================================
foreach ($u in $users) {

    $userEmail = $u.UserPrincipalName

    Write-Host "----------------------------------"
    Write-Host "[INFO] Processing: $userEmail"

    try {

        # ==========================================
        # Check if User Exists
        # ==========================================
        $existingUser = Invoke-RestMethod `
            -Method Get `
            -Uri "https://graph.microsoft.com/v1.0/users?`$filter=userPrincipalName eq '$userEmail'" `
            -Headers $headers

        if ($existingUser.value.Count -gt 0) {

            Write-Host "[INFO] Already exists: $userEmail"
            continue
        }

        # ==========================================
        # Create User Body
        # ==========================================
        $newUser = @{
            accountEnabled = $true
            displayName = $u.DisplayName
            mailNickname = $u.MailNickname
            userPrincipalName = $u.UserPrincipalName

            passwordProfile = @{
                forceChangePasswordNextSignIn = $true
                password = $u.Password
            }
        }

        # ==========================================
        # Create User
        # ==========================================
        Invoke-RestMethod `
            -Method Post `
            -Uri "https://graph.microsoft.com/v1.0/users" `
            -Headers $headers `
            -Body ($newUser | ConvertTo-Json -Depth 10)

        Write-Host "[SUCCESS] User created: $userEmail"
    }
    catch {

        Write-Host "[ERROR] Failed for: $userEmail"
        Write-Host $_.Exception.Message

        if ($_.Exception.Response) {

            $reader = New-Object System.IO.StreamReader(
                $_.Exception.Response.GetResponseStream()
            )

            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()

            $responseBody = $reader.ReadToEnd()

            Write-Host "========== GRAPH API ERROR =========="
            Write-Host $responseBody
            Write-Host "====================================="
        }
    }
}
