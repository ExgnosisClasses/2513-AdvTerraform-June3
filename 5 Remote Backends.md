# 5 Remote Backends

## Problem with Local Backends

Shared storage for state files
- Files need to be in common shared area so everyone on the team can access them
- Without file locking, race conditions when concurrent updates to the state files take place
- This can lead to conflicts, data loss, and state file corruption
- Using versioning, branches and workspaces does not solve this problem

Isolation
- It's difficult to isolate the code used in different environments
- Lack of isolation makes it easy to accidentally overwrite environments
  - _"Oops, I deleted the directory with the Terraform state file._
- The problem that we cannot address locally is that the state file is a shared resource
- Even if the *tf source files are isolated from each other

Secrets
- Confidential information is stored in the clear (i.e. Credentials)

## Remote Backends

Each Terraform configuration has a location where the state files are kept
- This is called the "backend"
- The default is to use files in the local directory
- Not a good option for production or team environments

Terraform support "remote" backends
- For example, we can keep state files in blob storage in Azure
- With a few exceptions, almost all the major cloud providers support remote backends

## Reasons for using Remote Backends

Using blob storage as a backend resolves many of these issues
- it manages the updating and access independently, and supports versions
- it supports encryption
- it supports locking schemes for multiple access
- it allows a common repository we can control access to

The blog storage is also managed (PaaS) so that we don't have to manage it
- It as high levels of availability and durability
- This means we have reduced the risk of "loosing" configurations

From a management perspective:
- The remote backend can be under the exclusive control of a configuration manager
- This prevents accidental corruption or deletion of the state files for various deployments.
- The contents of the state files are secure from browsing
- We can easily switch between local and remote backends
- We have a full audit trail of all updates to the files

## The Backend for the Remote Backend

When we set up the remote backend, we create a state file that describes the configuration of the remote backend

**The remote backend state file is not kept in the remote backend**
- We keep the remote backend state file separate and secure
- Locked down and accessible only to the configuration manager

We can have multiple blob back ends for different projects
- The state files for each project blob backend are kept in a master blob backend
- But the state of the master blob backend is stored securely 

## Setting Up the Backend

We have to tell Terraform the backend in now remotely located
- We do this in the `terraform` directive in our project directory
- The key creates a unique folder called `proj1` in the blob for this project's state file
- Each time we create a new project, we use a different key to uniquely identify its state file in the remote backend

```terraform
terraform {
  backend "azurerm" {
      resource_group_name  = "backend8839387"
       storage_account_name = "zippy998938"
       container_name       = "zippyblob9987"
       key                  = "proj1"
  }
}


```

## Moving State File Locations

To move local state to a remote backend
- Create the remote backend resources and define the backend configuration
- Run `terraform init` and the local config is copied to the remote backend

To move from remote backend to a local backend
- Remove the backend configuration
- Run `terraform init` and the remote config is copied to the local backend



## Remote Backend Advantage

Shared State for Team Collaboration
- Enables multiple team members to work safely on the same infrastructure by storing and locking the Terraform state remotely.
- Prevents state file drift between users.

State Locking and Concurrency Control
- Many remote backends (like S3 with DynamoDB or Azure Blob with leases) support state locking, preventing race conditions from concurrent operations (e.g., terraform apply).

Centralized and Secure State Storage
- State is not stored locally, reducing the risk of:
  - Accidental deletion or corruption 
  - Local machine compromise
  - Remote storage can be secured with encryption, access control, and audit logs.

Automation-Friendly
- Suitable for CI/CD pipelines
- Infrastructure as Code workflows in Jenkins, GitHub Actions, GitLab CI, etc., can all access the same state without extra manual syncing.

Enhanced Reliability
- State is stored in highly available cloud services (e.g., S3, Azure Blob, GCS), often with redundancy and backup capabilities.

Versioning and Recovery
- Some backends (like S3 and Azure Blob) support versioning, allowing you to:
  - Recover old state if needed
  - Audit infrastructure changes

Separation of Concerns
- Keeps state management decoupled from the user's local environment, making the setup more maintainable and easier to understand.

Consistent Workspace Management
- Many backends support named workspaces, enabling isolation between environments (e.g., dev, staging, prod) using the same configuration.
- This is preferred over maintaining workspace state files locally

Auditing and Access Control
- Remote storage can be integrated with IAM, RBAC, and access policies, helping enforce security and auditability.

## Backend Limitation

Added Complexity in Setup
- Remote backends require additional setup (e.g. Azure storage account + container).
- More moving parts mean more to configure and maintain, especially across environments.

Dependency on Cloud Provider Services
- Your Terraform operations become dependent on cloud services being available
- If your backend is down, so is your Terraform workflow.
- Access control and authentication need to be managed correctly (IAM, RBAC, service principals).

Less Flexibility in State File Access
- In some backends, it’s difficult or discouraged to download or manually inspect the raw state (for safety reasons).

Potential for Locking Failures
- Remote backends use mechanisms for state locking, but:
  - They may fail or hang if not properly released.
  - Manual intervention might be needed to break stale locks.

Increased Latency
- Reading and writing state remotely is slower than using a local file, especially in high-latency regions or for large state files.

Error Visibility and Debugging Challenges
- Errors related to backend configuration (permissions, missing containers, expired credentials) are sometimes opaque or low-level, making troubleshooting harder.

No Built-in Secrets Management
- The backend stores state remotely, but Terraform state files may contain sensitive data in plaintext.
- You must manually handle encryption, access control, and avoid storing secrets in variables.

Requires Consistent Configuration
- All team members and CI/CD systems must use the exact same backend configuration, or Terraform will fail to initialize.

## End

