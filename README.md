# AWS Infrastructure Automation with Terraform, Jinja2 & Boto3

A comprehensive automation tool for provisioning and validating AWS infrastructure using Infrastructure as Code (IaC) principles.

## 🚀 Project Overview

This project demonstrates end-to-end AWS infrastructure automation by combining multiple technologies:

- **Terraform**: Infrastructure provisioning and management
- **Jinja2**: Dynamic template rendering for Terraform configurations
- **Boto3**: AWS resource validation and verification
- **Python**: Orchestration and workflow management

The tool streamlines the process of generating Terraform configurations, deploying AWS resources, and validating successful deployment through programmatic verification.

## 🏗️ Architecture

The project deploys:
- **EC2 instances** with custom user data scripts
- **Application Load Balancer (ALB)** for traffic distribution
- **VPC networking** components
- **Security groups** with appropriate rules

## ✨ Features

### Core Functionality
- **Dynamic Configuration Generation**: Jinja2 templates create customized Terraform files based on user input
- **Automated Terraform Execution**: Python wrapper for Terraform initialization, planning, and deployment
- **Resource Validation**: Boto3 integration verifies successful resource creation and status
- **Modular Architecture**: Clean separation of concerns with dedicated classes and modules

### Input Validation
- AMI ID format verification
- Instance type validation
- Availability zone constraints
- Load balancer naming conventions
- Region restrictions (currently limited to `us-east-1`)

### Error Handling
- Comprehensive try-catch blocks for all AWS operations
- Terraform execution error handling
- Input validation with user-friendly error messages
- Rollback capabilities through Terraform destroy

## 📋 Prerequisites

- Python 3.7+
- AWS CLI configured with appropriate credentials
- Terraform installed and in PATH
- Virtual environment (recommended)

### Required Python Packages
```bash
pip install boto3 jinja2 python-terraform
```

## 🚀 Quick Start

### 1. Environment Setup
```bash
# Clone the repository
git clone <repository-url>
cd aws-automation-project

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
source venv/Scripts/activate  # Windows Git Bash
```

### 2. Run the Automation
```bash
python main.py
```

Follow the interactive prompts to configure:
- AMI ID
- Instance type
- Availability zone
- Load balancer name
- AWS region

### 3. Deploy Infrastructure
```bash
terraform init
terraform apply
```

### 4. Save Outputs
```bash
terraform output -json > terraform_output.json
```

### 5. Validate Deployment
```bash
python validate_aws.py
```

Check `aws_validation.json` for deployment confirmation details.

### 6. Cleanup (Optional)
```bash
terraform destroy
```

## 📁 Project Structure

```
aws-automation-project/
├── main.py                    # Main entry point and user interface
├── input_handler.py           # User input validation and processing
├── template_renderer.py       # Jinja2 template rendering logic
├── terraform_executor.py      # Terraform command execution wrapper
├── validate_aws.py           # Boto3 resource validation
├── template.j2               # Jinja2 template for Terraform configuration
├── user_data.sh              # EC2 instance initialization script
├── screenshots/              # Documentation screenshots
├── main.tf                   # Generated Terraform configuration
├── terraform_output.json     # Terraform output data
├── aws_validation.json       # AWS resource validation results
└── README.md                 # This file
```

## 🔧 Configuration Options

### Supported Instance Types
- t2.micro, t2.small, t2.medium
- t3.micro, t3.small, t3.medium
- m5.large, m5.xlarge

### Supported Regions
- us-east-1 (N. Virginia)
- Additional regions can be added by modifying the validation logic

## 📊 Validation Output

The validation script generates `aws_validation.json` with:
- EC2 instance details (ID, state, public IP)
- Load balancer information (DNS name, state)
- Deployment timestamp
- Resource tags and metadata

## 🛠️ Development

### Code Structure
The project follows object-oriented principles with dedicated classes:
- `InputHandler`: Manages user input and validation
- `TemplateRenderer`: Handles Jinja2 template processing
- `TerraformExecutor`: Wraps Terraform CLI operations
- `AWSValidator`: Performs resource validation using Boto3

### Error Handling
Each module implements comprehensive error handling:
- AWS API exceptions
- Terraform execution errors
- Template rendering issues
- File I/O operations

## 📸 Screenshots

Screenshots of successful execution can be found in the `screenshots/` directory, demonstrating:
- Interactive user input
- Terraform planning and application
- Resource validation results

## 🔒 Security Considerations

- AWS credentials should be configured using IAM roles or AWS CLI
- Security groups follow principle of least privilege
- User data scripts are sanitized and validated
- Resource tags enable proper cost tracking and management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with appropriate tests
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Yuval Davidson**  
DevOps Automation Student

---

*This project demonstrates practical implementation of Infrastructure as Code principles using modern DevOps tools and practices.*