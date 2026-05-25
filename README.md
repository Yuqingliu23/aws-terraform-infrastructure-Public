# AWS Load Balancer Infrastructure Project

## Project Overview

This project uses Terraform and GitHub Actions to automate the deployment of a highly available and scalable AWS load balancer infrastructure. The infrastructure is managed as Infrastructure as Code (IaC) and includes a Network Load Balancer (NLB), EC2 instances, security groups, Route53 DNS records, and CloudWatch monitoring.

## What This Project Does

This project provisions and manages an AWS-based application environment that routes external traffic through a Network Load Balancer to multiple web server instances, while also connecting the application layer to a MySQL server. It also integrates DNS routing and monitoring to support deployment, validation, and teardown of the infrastructure.

## Why This Project Exists

This project was created to practice and demonstrate cloud infrastructure automation on AWS using Terraform and CI/CD workflows. It focuses on reproducible infrastructure provisioning, load-balanced service deployment, and operational automation through GitHub Actions. It is especially useful for learning and showcasing:

- Infrastructure as Code (IaC)
- AWS networking and compute services
- Load balancing and service availability
- Automated deployment and destruction workflows
- Basic cloud monitoring and validation

## System Architecture

![Architecture Diagram](docs/architecture.png)

### Core Components

- **Network Load Balancer (NLB)**: Distributes incoming traffic to EC2 web instances
- **EC2 Instances**: Hosts the web application and MySQL server
- **CloudWatch Agent**: Collects logs and metrics from EC2 instances
- **Route53**: Provides DNS resolution for the API endpoint
- **Security Groups**: Control inbound and outbound traffic
- **Automation Workflows**: Use GitHub Actions to deploy and destroy infrastructure

## Directory Structure

```text
.
├── .github/workflows/               # GitHub Actions workflow definitions
│   ├── loadbalancer-deploy.yml      # Deployment workflow
│   └── loadbalancer-destroy.yml     # Destroy workflow
├── terraform/                       # Terraform configuration
│   ├── main.tf                      # Main infrastructure definition
│   ├── outputs.tf                   # Output values
│   ├── variables.tf                 # Variable definitions
│   └── modules/                     # Terraform modules
│       ├── loadbalancer/            # Load balancer and web tier resources
│       ├── mysql/                   # MySQL instance resources
│       ├── security/                # Security group definitions
│       └── web/                     # Web server module
└── README.md                        # Project documentation

## Requirements

- An AWS account with valid credentials
- Terraform `1.5.3` or later
- GitHub Actions, or `act` for local workflow testing
- Required AWS permissions for networking, EC2, Route53, IAM, and load balancer resources

## Environment Configuration

Set the following values as GitHub Secrets or local environment variables:

- `AWS_ACCESS_KEY_ID`: AWS access key ID
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key
- `AWS_REGION`: AWS region, default is `us-east-2`
- `AGENT_WEBAPP_AMI`: AMI ID for the web server
- `AGENT_MYSQL_AMI`: AMI ID for the MySQL server
- `DATABASE_USER_NAME`: Database username
- `DATABASE_PASSWORD`: Database password
- `WEBAPP_SECRET_KEY`: Application secret key
- `EC2_SSH_KEY_NAME`: EC2 SSH key pair name
- `ROUTE53_ZONE_ID`: Route53 hosted zone ID
- `DOMAIN_NAME`: Domain name

## Build and Deployment

### Automated Deployment with GitHub Actions

1. Push changes to the `main` branch, or manually trigger the workflow.
2. GitHub Actions will run the deployment process automatically.

### Local Workflow Testing with `act`

```bash
act --secret-file .env -W .github/workflows/loadbalancer-deploy.yml

### Manual Terraform Deployment

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd cloud-project-terraform-aws-infra-Yuqingliu23

### Initialize Terraform:

cd terraform
terraform init
Review the execution plan:

terraform plan -var-file=terraform.tfvars
Apply the infrastructure:

terraform apply -var-file=terraform.tfvars
How to Reproduce
To reproduce this project from scratch:

### Prepare an AWS account and configure the required credentials.
Create or obtain valid AMIs for the web application and MySQL server.
Configure all required secrets or environment variables.
Clone this repository.
Run the deployment using one of the following methods:
GitHub Actions
Manual Terraform commands
Local workflow testing with act
Wait for the infrastructure to initialize fully.
Verify the deployed API endpoint and load balancer behavior.
If Route53 is configured correctly, the deployment should expose an endpoint like:

api.<your-domain-name>
You can then test endpoints such as:

/v1/healthcheck
/v2/metadata
Infrastructure Destruction
Using GitHub Actions
Manually trigger the loadbalancer-destroy.yml workflow.

Local Destroy Test with act
act --secret-file .env -W .github/workflows/loadbalancer-destroy.yml
Manual Destruction
cd terraform
terraform destroy -var-file=terraform.tfvars
Validation and Testing
This project includes validation for the deployed load balancer and metadata API.

Example test script:

python3 test_lb_api_metadata.py -d api.<your-domain-name> -n 100
The test checks whether requests are correctly distributed across backend instances and whether the metadata endpoint returns valid instance and availability zone information.

CloudWatch Monitoring
The infrastructure configures CloudWatch Agent to collect:

EC2 CPU, memory, and disk utilization
Network traffic metrics
Application logs
Troubleshooting
Common Issues
Deployment failure during Terraform initialization

Check AWS credentials and permissions
For local testing, try offline initialization:
terraform init -backend=false
Resource deletion failure caused by VPC dependencies

The destroy workflow includes additional cleanup steps for dependent resources
For manual cleanup, delete child resources before parent resources
CloudWatch Agent configuration issues

Make sure IAM roles or credentials are configured correctly
Check EC2 metadata service settings if monitoring does not start as expected
Debugging Tools
Review GitHub Actions workflow logs
Inspect deployed resources in the AWS Console
Check CloudWatch logs and metrics for runtime details
## Security Considerations
Security groups restrict access to only required ports
Sensitive values such as database credentials are stored in GitHub Secrets
IAM roles are preferred over hard-coded credentials whenever possible