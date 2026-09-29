# ECS Health App — AWS, Terraform & GitHub Actions

A containerised Node.js health-check application deployed to **AWS ECS Fargate** using **Terraform** and automated through **GitHub Actions**.

This project was built as a practical DevOps project to demonstrate infrastructure as code, containerisation, AWS networking, load balancing, HTTPS, DNS, IAM, and CI/CD.

---

## Architecture

```text
                         Internet
                            │
                            ▼
                    ┌─────────────────┐
                    │    Route 53     │
                    │ tm.shoshin.org.uk│
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Application   │
                    │   Load Balancer │
                    │     HTTPS :443  │
                    └────────┬────────┘
                             │
                       HTTP :3000
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
        ┌───────────────┐         ┌───────────────┐
        │  ECS Fargate  │         │  ECS Fargate  │
        │     Task 1    │         │     Task 2    │
        │    :3000      │         │    :3000      │
        └───────┬───────┘         └───────┬───────┘
                │                         │
                └────────────┬────────────┘
                             ▼
                       Node.js App
                       GET /health
```

### Request flow

```text
Browser
   ↓
Route 53
   ↓
ALB HTTPS :443
   ↓
Target Group HTTP :3000
   ↓
ECS Fargate Task :3000
   ↓
Node.js /health
```

---

## Technologies Used

### Application

* Node.js
* Express
* Docker
* Docker multi-stage build

### AWS

* Amazon VPC
* Amazon ECS
* AWS Fargate
* Amazon ECR
* Application Load Balancer
* Target Groups
* AWS Certificate Manager
* Amazon Route 53
* AWS IAM
* Amazon S3

### Infrastructure & CI/CD

* Terraform
* GitHub Actions
* GitHub OIDC
* Terraform remote state in Amazon S3

---

## Project Structure

```text
project/
│
├── app/
│   ├── index.js
│   ├── package.json
│   └── Dockerfile
│
├── bootstrap/
│   ├── provider.tf
│   └── main.tf
│
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   │
│   └── modules/
│       ├── vpc/
│       ├── ecr/
│       ├── iam/
│       ├── alb/
│       ├── ecs/
│       ├── acm/
│       └── route53/
│
├── .github/
│   └── workflows/
│       ├── ci.yaml
│       ├── deploy.yaml
│       └── destroy.yaml
│
├── .gitignore
└── README.md
```

---

# Application

The application is a small Node.js service with a health-check endpoint.

### Endpoint

```text
GET /health
```

Response:

```json
{
  "status": "ok"
}
```

The application listens on:

```text
Port 3000
```

Port 3000 is exposed inside the container and used by the ECS task and ALB target group.

---

# Docker

The application is containerised using Docker.

The Dockerfile uses a **multi-stage build**:

```text
Builder stage
    ↓
Install dependencies
    ↓
Copy application
    ↓
Runtime stage
    ↓
Run application as non-root user
```

The runtime container runs using a dedicated non-root user rather than the root user.

This reduces the privileges available to the application if the container is compromised.

The image is based on:

```text
node:22-alpine
```

---

# Amazon ECR

Terraform creates an Amazon ECR repository:

```text
getsugatensho
```

GitHub Actions builds the Docker image and pushes it to ECR using the Git commit SHA as the image tag.

Example:

```text
getsugatensho:<commit-sha>
```

Using the commit SHA makes each image identifiable and avoids relying exclusively on the mutable `latest` tag.

---

# AWS Networking

Terraform creates a VPC with two public subnets.

The VPC contains:

```text
VPC
├── Public Subnet A
├── Public Subnet B
├── Internet Gateway
└── Public Route Table
```

The public subnets allow the infrastructure to communicate with the internet.

The ALB is deployed across both subnets.

The ECS tasks are also deployed into the VPC and communicate with the ALB over port 3000.

---

# Security Groups

The application uses separate security groups for the ALB and ECS tasks.

### ALB Security Group

Allows:

```text
HTTP  :80  → Internet
HTTPS :443 → Internet
```

### ECS Security Group

Allows:

```text
TCP :3000 → ALB Security Group
```

This means the ECS tasks don't need to accept traffic from the entire internet on port 3000.

Traffic is intended to flow:

```text
Internet
   ↓
ALB
   ↓
ECS tasks
```

---

# Application Load Balancer

The Application Load Balancer provides a public entry point for the application.

It listens on:

```text
HTTP  :80
HTTPS :443
```

HTTP traffic is redirected to HTTPS.

HTTPS traffic is terminated at the ALB and then forwarded to the ECS tasks over HTTP on port 3000.

The target group uses:

```text
Target type: IP
Port: 3000
Health check: /health
```

Two ECS tasks are deployed so the ALB can distribute traffic between them.

---

# HTTPS

AWS Certificate Manager provides the TLS certificate for:

```text
tm.shoshin.org.uk
```

The certificate is validated using Route 53 DNS validation.

The ALB uses the certificate for HTTPS traffic.

---

# Route 53

Route 53 provides DNS for:

```text
tm.shoshin.org.uk
```

The DNS record points traffic toward the Application Load Balancer.

The complete flow is:

```text
tm.shoshin.org.uk
        ↓
     Route 53
        ↓
       ALB
        ↓
   ECS Fargate
```

---

# Terraform

Terraform is used to provision and manage the AWS infrastructure.

The infrastructure is split into reusable modules.

### VPC module

Responsible for:

* VPC
* Subnets
* Internet Gateway
* Route table
* Routes

### ECR module

Responsible for:

* ECR repository
* Image scanning configuration

### IAM module

Responsible for:

* ECS task execution role
* IAM permissions required by ECS

### ALB module

Responsible for:

* Application Load Balancer
* ALB security group
* Target group
* HTTP listener
* HTTPS listener

### ECS module

Responsible for:

* ECS cluster
* Task definition
* ECS service
* Fargate tasks
* ECS security group

### ACM module

Responsible for:

* ACM certificate
* DNS validation

### Route 53 module

Responsible for:

* DNS record
* Route 53 integration with the ALB

---

# Terraform Remote State

Terraform state is stored remotely in Amazon S3.

The backend uses:

```text
Amazon S3
```

with:

```text
use_lockfile = true
```

Remote state allows Terraform state to be stored outside the local machine and provides state locking when Terraform is being used.

The bootstrap configuration is separated from the main infrastructure because the S3 backend must exist before Terraform can use it as a backend.

---

# CI/CD

GitHub Actions is used for the CI/CD pipeline.

There are three workflows:

```text
CI
Deploy
Destroy
```

---

## CI Workflow

The CI workflow runs when code is pushed to the `master` branch.

It:

1. Checks out the repository.
2. Builds the Docker image.
3. Authenticates with AWS.
4. Logs into ECR.
5. Tags the Docker image with the Git commit SHA.
6. Pushes the image to ECR.

Example image tag:

```text
<commit-sha>
```

---

## Deploy Workflow

The deployment workflow runs after changes are pushed to `master`.

Terraform performs:

```text
terraform init
        ↓
terraform plan
        ↓
terraform apply
        ↓
health check
```

After deployment, GitHub Actions performs a health check against:

```text
https://tm.shoshin.org.uk/health
```

The workflow fails if the health check does not return a successful response.

---

# GitHub OIDC

GitHub Actions authenticates with AWS using **OpenID Connect (OIDC)** rather than storing a long-lived AWS access key and secret inside GitHub.

The flow is:

```text
GitHub Actions
      ↓
GitHub OIDC
      ↓
AWS IAM Role
      ↓
Temporary AWS credentials
      ↓
AWS resources
```

The IAM role trusts the specific GitHub repository and branch.

This avoids storing permanent AWS credentials as GitHub secrets.

---

# Destroy Workflow

The infrastructure can be destroyed using the manually triggered GitHub Actions workflow.

The workflow runs:

```text
terraform init
        ↓
terraform destroy -auto-approve
```

This allows the complete Terraform-managed environment to be removed when it is no longer required.

The Terraform S3 backend is kept separately so that Terraform state remains available.

---

# Deployment Lifecycle

The complete project lifecycle is:

```text
Developer
    │
    ▼
Git push
    │
    ▼
GitHub Actions
    │
    ├───────────────┐
    ▼               ▼
   CI             Deploy
    │               │
    ▼               ▼
Docker build    Terraform
    │               │
    ▼               ▼
    ECR          AWS Infrastructure
                    │
                    ▼
              ECS Fargate
                    │
                    ▼
                   ALB
                    │
                    ▼
              Route 53 + HTTPS
```

---

# Useful Commands

### Build the Docker image locally

```bash
docker build -t ecs-health-app ./app
```

### Run the container locally

```bash
docker run -p 3000:3000 ecs-health-app
```

### Test locally

```bash
curl http://localhost:3000/health
```

Expected response:

```json
{
  "status": "ok"
}
```

---

## Terraform

From the `infra` directory:

```bash
terraform init
```

Create a plan:

```bash
terraform plan
```

Apply infrastructure:

```bash
terraform apply
```

Destroy infrastructure:

```bash
terraform destroy
```

---

# Lessons Learned

This project provided practical experience with several important DevOps concepts:

* Containerising applications with Docker
* Multi-stage Docker builds
* Running containers as non-root users
* Amazon ECR
* ECS Fargate
* Application Load Balancers
* Target groups and health checks
* AWS security groups
* VPC networking
* HTTPS and TLS certificates
* Route 53 DNS
* Terraform modules
* Terraform remote state
* Terraform state locking
* GitHub Actions
* GitHub OIDC authentication
* CI/CD pipelines
* Automated infrastructure deployment
* Infrastructure cleanup and dependency management

One particularly important lesson was understanding that AWS resources can have hidden dependencies. For example, an Application Load Balancer creates AWS-managed network interfaces, which can prevent its subnets or security groups from being deleted until the ALB has been removed.

---

# Future Improvements

Potential improvements for a future version include:

* Move ECS tasks into private subnets.
* Keep the ALB in public subnets.
* Add NAT Gateway connectivity for private ECS tasks.
* Add CloudWatch logging and monitoring.
* Add container image vulnerability scanning.
* Add Terraform formatting and validation to CI.
* Add automated Terraform plan output for pull requests.
* Add separate development and production environments.
* Improve IAM permissions using least privilege.
* Add automated rollback strategies for failed deployments.

---

# Project Status

This project demonstrates a complete infrastructure-as-code deployment of a containerised application to AWS ECS Fargate with automated CI/CD.

```text
Docker
   +
ECR
   +
Terraform
   +
AWS ECS Fargate
   +
Application Load Balancer
   +
ACM
   +
Route 53
   +
GitHub Actions
   +
GitHub OIDC
```

The application is accessible through HTTPS and can be deployed or destroyed through the GitHub Actions workflows.
