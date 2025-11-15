# DigitalOcean Droplet Terraform Script

This is a simple Terraform script to create a DigitalOcean droplet using variables from a YAML file.

## Prerequisites

1. Terraform installed
2. DigitalOcean API token

## Usage

1. Clone this repository
2. Navigate to the terraform_scripts directory
3. Update the `secrets.yaml` file with your DigitalOcean token and desired droplet configuration
4. Initialize Terraform:
   ```
   terraform init
   ```

5. Plan the infrastructure:
   ```
   terraform plan
   ```

6. Apply the infrastructure:
   ```
   terraform apply
   ```

7. To destroy the infrastructure:
   ```
   terraform destroy
   ```

## Security

The `secrets.yaml` file contains sensitive information and is excluded from version control via `.gitignore`.