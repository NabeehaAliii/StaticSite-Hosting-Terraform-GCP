# Static Site Hosting on GCP via Terraform

This project provides a template for hosting a static website on **Google Cloud Platform (GCP)** using **Terraform**. The setup also includes optional AWS Route 53 configuration if you want to link a custom domain hosted on AWS.

---

## Prerequisites

Before starting, ensure you have the following:

1. **Google Cloud Platform (GCP) Account**
   - Required to create a project and manage resources.

2. **AWS Account (Optional)** 
   - Needed only if you have a domain hosted on Route 53. If not, you can adjust the resources accordingly in `resources.tf`.

3. **Installed Tools**
   - [Terraform](https://developer.hashicorp.com/terraform/downloads)
   - [Git](https://git-scm.com/downloads)

4. **Service Account Key (GCP)**
   - A service account key is needed to authenticate Terraform with your GCP project.

---

## Steps to Get Started

### 1. **Clone the Repository**
```bash
git clone https://github.com/NabeehaAliii/StaticSite-Hosting-Terraform-GCP.git
cd StaticSite-Hosting-Terraform-GCP
```

---

### 2. **Set Up GCP**

#### a. Create a Project
1. Log in to [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project or use an existing one.

#### b. Create a Service Account
1. Navigate to **IAM & Admin > Service Accounts**.
2. Create a new service account.
3. Assign the following roles:
   - **Storage Admin**
   - **Compute Network Admin**
   - **Compute Admin**
4. Generate a key for this service account (JSON format).
5. Save the key file in the root directory of the cloned repository.

---

### 3. **Configure the Project**
Edit the following variables in `terraform.tfvars`:

```hcl
gcp_project = "your-gcp-project-id"
gcp_region  = "your-region" # Example: "asia-south1"
gcp_svc_key = "path-to-your-service-account-key.json"
aws_domain  = "your-aws-domain" # Optional if using AWS Route 53
```

---

### 4. **Run Terraform**
Initialize the Terraform working directory:
```bash
terraform init
```

Generate a plan and save it in a file:
```bash
terraform plan -out=planfile
```

Apply the configuration:
```bash
terraform apply planfile
```

---

### 5. **Access Your Website**
Once the resources are provisioned:
1. Copy the **External IP** of the Load Balancer (or Route 53 domain if configured).
2. Visit the URL in your browser.

---

## Cleanup
To remove all resources created by Terraform:
```bash
terraform destroy
```

---

## Notes
- Ensure your `.gitignore` excludes sensitive files such as `terraform.tfvars` and `service-account-key.json`.
- Update the `provider.tf` file to match your setup if you modify regions or service account credentials.

Let me know if you want any additional instructions or modifications!
