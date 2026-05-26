# AWS Terraform Infrastructure Project

## Project Overview

This project uses Terraform and GitHub Actions to automate the deployment of a highly available and scalable AWS load balancer infrastructure on AWS.

The infrastructure is managed as Infrastructure as Code (IaC) and includes a Network Load Balancer (NLB), EC2 instances, security groups, Route 53 DNS records, and CloudWatch monitoring.

## What This Project Does

This project provisions and manages an AWS-based application environment that routes external traffic through a Network Load Balancer to multiple web server instances.

The application layer also connects to a MySQL server. DNS routing and monitoring are integrated to support infrastructure deployment, validation, and teardown.

## Why This Project Exists

This project was created to practice and demonstrate cloud infrastructure automation on AWS using Terraform and CI/CD workflows.

It focuses on reproducible infrastructure provisioning, load-balanced service deployment, and operational automation through GitHub Actions.

This project is useful for demonstrating:

- Infrastructure as Code (IaC)
- AWS networking and compute services
- Load balancing and service availability
- Automated deployment and destruction workflows
- Cloud monitoring and deployment validation

## Core Components

- **Network Load Balancer (NLB)**: Distributes incoming traffic to EC2 web instances.
- **EC2 Instances**: Host the web application and MySQL server.
- **CloudWatch Agent**: Collects logs and metrics from EC2 instances.
- **Route 53**: Provides DNS resolution for the API endpoint.
- **Security Groups**: Control inbound and outbound traffic.
- **GitHub Actions Workflows**: Automate infrastructure deployment and destruction.

## Directory Structure

```text
.
├── .github/
│   └── workflows/
│       ├── loadbalancer-deploy.yml
│       └── loadbalancer-destroy.yml
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── modules/
│       ├── loadbalancer/
│       ├── mysql/
│       ├── security/
│       └── web/
└── README.md
```

## Requirements

Before running this project, make sure you have the following:

- An AWS account with valid credentials
- Terraform `1.5.3` or later
- GitHub Actions, or `act` for local workflow testing
- Required AWS permissions for:
  - VPC and networking resources
  - EC2
  - Route 53
  - IAM
  - Elastic Load Balancing

## Environment Configuration

Set the following values as GitHub Secrets or local environment variables:

| Variable | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS access key ID |
| `AWS_SECRET_ACCESS_KEY` | AWS secret access key |
| `AWS_REGION` | AWS region. Default: `us-east-2` |
| `AGENT_WEBAPP_AMI` | AMI ID for the web server |
| `AGENT_MYSQL_AMI` | AMI ID for the MySQL server |
| `DATABASE_USER_NAME` | Database username |
| `DATABASE_PASSWORD` | Database password |
| `WEBAPP_SECRET_KEY` | Application secret key |
| `EC2_SSH_KEY_NAME` | EC2 SSH key pair name |
| `ROUTE53_ZONE_ID` | Route 53 hosted zone ID |
| `DOMAIN_NAME` | Domain name |

## Build and Deployment

### Automated Deployment with GitHub Actions

You can deploy the infrastructure through GitHub Actions.

1. Push changes to the `main` branch, or manually trigger the deployment workflow.
2. GitHub Actions will run the Terraform deployment process automatically.
3. After the workflow completes, verify the deployed load balancer and API endpoint.

Deployment workflow:

```text
.github/workflows/loadbalancer-deploy.yml
```

### Local Workflow Testing with act

To test the GitHub Actions workflow locally, run:

```bash
act --secret-file .env -W .github/workflows/loadbalancer-deploy.yml
```

### Manual Terraform Deployment

Clone the repository:

```bash
git clone <repository-url>
cd cloud-project-terraform-aws-infra-Yuqingliu23
```

Go to the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Review the execution plan:

```bash
terraform plan -var-file=terraform.tfvars
```

Apply the infrastructure:

```bash
terraform apply -var-file=terraform.tfvars
```

## How to Reproduce

To reproduce this project from scratch:

1. Prepare an AWS account and configure the required credentials.
2. Create or obtain valid AMIs for the web application and MySQL server.
3. Configure all required secrets or environment variables.
4. Clone this repository.
5. Run the deployment using one of the following methods:
   - GitHub Actions
   - Manual Terraform commands
   - Local workflow testing with `act`
6. Wait for the infrastructure to initialize fully.
7. Verify the deployed API endpoint and load balancer behavior.

If Route 53 is configured correctly, the deployment should expose an endpoint like:

```text
api.<your-domain-name>
```

You can then test endpoints such as:

```text
/v1/healthcheck
/v2/metadata
```

## Infrastructure Destruction

### Destroy with GitHub Actions

Manually trigger the destroy workflow:

```text
.github/workflows/loadbalancer-destroy.yml
```

### Local Destroy Test with act

```bash
act --secret-file .env -W .github/workflows/loadbalancer-destroy.yml
```

### Manual Terraform Destruction

```bash
cd terraform
terraform destroy -var-file=terraform.tfvars
```

## Validation and Testing

This project includes validation for the deployed load balancer and metadata API.

Example test command:

```bash
python3 test_lb_api_metadata.py -d api.<your-domain-name> -n 100
```

The test checks whether:

- Requests are distributed across backend instances.
- The metadata endpoint returns valid instance information.
- Availability zone information is returned correctly.

## CloudWatch Monitoring

The infrastructure configures the CloudWatch Agent to collect:

- EC2 CPU utilization
- Memory utilization
- Disk utilization
- Network traffic metrics
- Application logs

CloudWatch metrics and logs can be used to inspect runtime behavior, debug deployment issues, and monitor infrastructure health.

## Troubleshooting

### Deployment Failure During Terraform Initialization

Check whether AWS credentials and permissions are configured correctly.

For local testing, you can try offline initialization:

```bash
terraform init -backend=false
```

### Resource Deletion Failure Caused by VPC Dependencies

The destroy workflow includes additional cleanup steps for dependent resources.

For manual cleanup, delete child resources before parent resources. For example, check for dependencies such as:

- Load balancers
- Target groups
- Network interfaces
- Security groups
- Route 53 records
- EC2 instances

### CloudWatch Agent Configuration Issues

If CloudWatch metrics or logs are not available:

- Make sure IAM roles or credentials are configured correctly.
- Check whether the CloudWatch Agent is installed and running.
- Verify EC2 metadata service settings.
- Review CloudWatch Agent logs on the EC2 instance.

## Debugging Tools

Useful debugging methods include:

- Reviewing GitHub Actions workflow logs
- Inspecting deployed resources in the AWS Console
- Checking CloudWatch logs and metrics
- Running Terraform commands locally
- Testing API endpoints directly with `curl` or the provided test script

## Security Considerations

This project follows several basic infrastructure security practices:

- Security groups restrict access to only required ports.
- Sensitive values such as database credentials are stored in GitHub Secrets.
- IAM roles are preferred over hard-coded credentials whenever possible.
- Database access should be restricted to the application layer.
- Public access should be limited to the load balancer or required API endpoints only.
production-grade monitoring alerts.