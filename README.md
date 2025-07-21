# AWS-IAM-with-Terraform-RBAC-and-MFA

# The Ultimate Guide to AWS IAM with Terraform: Secure, Automated, and Scalable

A complete Terraform project to build a secure, role-based access control (RBAC) foundation in AWS. This repository demonstrates best practices for creating IAM users, groups, custom policies, and enforcing Multi-Factor Authentication (MFA).

##  Project Overview

This project implements a structured IAM environment for a fictional company, "EpicReads." It automates the creation of a secure and scalable access management system using Infrastructure as Code (IaC).

### Key Features:
- **Role-Based Access:** Creates distinct groups for Admins, Developers, and Testers.
- **Principle of Least Privilege:** Assigns fine-grained permissions tailored to each role.
- **MFA Enforcement:** Includes a custom policy to force MFA for all administrative users.
- **Scalable User Management:** Users are managed via Terraform variables, making it easy to add or remove them.
- **Fully Automated:** Deploy the entire IAM structure with a few simple Terraform commands.

---

##  Terraform Resources Created

This project will create the following AWS resources:
- **IAM Users:** For all personnel (`John_Admin`, `Alice_Dev`, etc.).
- **IAM Groups:**
  - `Admins`
  - `Developers`
  - `Test`
- **IAM Policies:**
  - Attachment of AWS Managed Policies (`AdministratorAccess`, `AmazonEC2FullAccess`, etc.).
  - A custom `ForceMFA` policy for the Admins group.
  - A custom inline policy for the Test group to allow limited actions on test resources.
- **Group Memberships:** Automatically assigns users to their correct groups, including cross-functional roles.

---

##  How to Use

### Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed.
- AWS Credentials configured for your terminal.

### Deployment Steps

1.  **Clone the repository:**
    ```sh
    git clone <your-repo-url>
    cd <your-repo-directory>
    ```

2.  **Initialize Terraform:**
    ```sh
    terraform init
    ```

3.  **Plan the deployment:**
    ```sh
    terraform plan
    ```
    *(Review the output to see what resources will be created.)*

4.  **Apply the configuration:**
    ```sh
    terraform apply
    ```
    *(Type `yes` when prompted to confirm.)*

### Cleanup
To remove all created resources, run the destroy command:
```sh
terraform destroy
```


---

## ❓ Frequently Asked Questions (FAQ)

**Q1: Why use Terraform for IAM instead of just using the AWS Management Console?**

Using Terraform (Infrastructure as Code) provides several critical advantages over manual configuration in the console:

-   **Automation & Repeatability:** You can deploy the exact same IAM configuration across multiple AWS accounts (e.g., dev, staging, prod) with a single command, ensuring consistency and eliminating human error.
-   **Version Control:** By storing your IAM configuration in Git, you get a full history of every change. You can see who changed what, when, and why.
-   **Peer Review:** Changes to your IAM structure can be reviewed and approved via Pull Requests, adding a crucial layer of security and oversight.
-   **Documentation:** The Terraform code itself serves as clear documentation for your access control policies.

**Q2: How does this project handle users who need permissions for multiple roles (like a DevOps engineer)?**

This is handled easily and elegantly. In the `variables.tf` file, you simply add the user's name to each list that corresponds to a role they need.

For example, `Alex_DevOps` is included in both the `developer_users` and `test_users` lists. Terraform and AWS IAM automatically merge the permissions from both groups, granting Alex the combined access of a Developer and a Tester.

**Q3: The Terraform code doesn't set any passwords or access keys. How are those managed?**

This is an intentional security design. Managing secrets like passwords and long-lived access keys in source control or Terraform state is a security risk. The recommended best practice is:

-   **Console Passwords:** After a user is created via Terraform, an administrator should set an initial temporary password in the AWS Console and select the "User must create a new password at next sign-in" option.
-   **Access Keys:** Programmatic access keys (`access_key_id` and `secret_access_key`) should only be generated when there is a specific, justified need. They should be created by the user themselves through the console (after logging in with MFA) or by an admin, and the secret key should be stored securely, never in code.

**Q4: What is the purpose of the `ForceMFA` policy, and how does it work?**

The `ForceMFA` policy is a critical security control that makes Multi-Factor Authentication mandatory for admin users. It works by combining two statements:

1.  **An explicit `Deny`:** It denies **all** actions (`"Action": "*"`) if the request is **not** authenticated with an MFA device (`"aws:MultiFactorAuthPresent": "false"`).
2.  **A conditional `Allow`:** It then allows all actions if the request **is** authenticated with MFA.

In AWS IAM, an explicit `Deny` always overrides an `Allow`. This means that even though the `AdministratorAccess` policy grants full access, the `ForceMFA` policy's `Deny` statement will block any action if the user hasn't logged in with their MFA device.

**Q5: What is the next step to make this IAM setup even more secure and modern?**

While this project establishes a strong foundation with IAM Users and Groups, the modern best practice is to move towards **temporary credentials** using **AWS IAM Identity Center (formerly AWS SSO)**.

The next evolution would be to:
1.  Integrate a central identity provider (like Google Workspace, Azure AD, or Okta) with IAM Identity Center.
2.  Create "Permission Sets" in Identity Center that mirror the roles (Admin, Developer, Tester).
3.  Assign users/groups from your identity provider to these permission sets.

This approach is more secure because users no longer have long-lived IAM user credentials. Instead, they log in via their company portal and are granted temporary, role-based credentials to access AWS accounts.
