# 🚀 Azure Entra ID User Provisioning Automation (DevOps Project)

## 📌 Project Overview

This project automates user creation in **Microsoft Entra ID (Azure AD)** using a CI/CD pipeline. It demonstrates real-world DevOps practices by integrating cloud identity management with automation tools like Jenkins and GitHub.

---

## 🛠️ Tech Stack

* Microsoft Azure (Entra ID)
* Microsoft Graph API
* PowerShell
* Jenkins (CI/CD)
* GitHub (Version Control)

---

## 🔄 Workflow Architecture

1. Code is pushed to GitHub repository
2. Jenkins pipeline is triggered
3. PowerShell script executes
4. Microsoft Graph API creates a new user in Azure Entra ID

---

## 🔐 Authentication Method

This project uses **Azure App Registration** with:

* Tenant ID
* Client ID
* Client Secret

Authentication is done via **OAuth 2.0 Client Credentials Flow** to securely access Microsoft Graph API.

---

## 📁 Project Structure

```
azure-user-automation/
│
├── create-user.ps1     # PowerShell script to create user
└── Jenkinsfile         # CI/CD pipeline definition
```

---

## ⚙️ Setup Instructions

### 🔹 Step 1: Azure Configuration

* Go to Azure Portal → Microsoft Entra ID
* Create **App Registration**
* Generate **Client Secret**
* Add API Permission:

  * `User.ReadWrite.All` (Application Permission)
* Click **Grant Admin Consent**

---

### 🔹 Step 2: Script Configuration

Update the following values inside `create-user.ps1`:

```powershell
$tenantId = "<TENANT_ID>"
$clientId = "<CLIENT_ID>"
$clientSecret = "<CLIENT_SECRET>"
```

Also update:

```
userPrincipalName = "devopsuser@yourtenant.onmicrosoft.com"
```

---

### 🔹 Step 3: GitHub Setup

* Create a new repository
* Name: `azure-user-automation`
* Upload:

  * `create-user.ps1`
  * `Jenkinsfile`

---

### 🔹 Step 4: Jenkins Setup

* Install Jenkins locally or on server
* Create a **Pipeline Job**
* Add your GitHub repository URL

---

### 🔹 Step 5: Add Jenkins Pipeline

```groovy
pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/<your-username>/azure-user-automation.git'
            }
        }

        stage('Create Azure User') {
            steps {
                bat 'powershell -ExecutionPolicy Bypass -File create-user.ps1'
            }
        }
    }
}
```

---

## ▶️ Execution Steps

* Trigger Jenkins build manually OR via webhook
* Pipeline runs PowerShell script
* Script calls Microsoft Graph API
* User is created in Azure Entra ID

---

## ✅ Output

* Automated creation of users in Azure directory
* Reduced manual effort for identity provisioning

---

## 📈 Use Cases

* Employee onboarding automation
* Identity lifecycle management
* DevOps-driven cloud automation

---

## 🔮 Future Enhancements

* Dynamic user input via Jenkins parameters
* Bulk user creation using CSV
* Email notifications after user creation
* Integration with ITSM tools (e.g., ServiceNow)
* Logging and error handling improvements

---

## 🧠 Key Learnings

* CI/CD pipeline integration with cloud services
* Secure API authentication using OAuth 2.0
* Infrastructure automation using PowerShell
* Real-world DevOps project implementation

---

## 📢 Author
Sai Manogna TL

---

## 🎯 Resume Highlights

* Automated Azure user provisioning using Microsoft Graph API
* Built CI/CD pipeline using Jenkins
* Integrated GitHub with automation workflows
* Implemented secure authentication using App Registration

---

## ⭐ How to Use

1. Clone the repository
2. Update credentials in script
3. Run Jenkins pipeline
4. Verify user creation in Azure Entra ID

