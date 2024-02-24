# Liatrio EKS Cluster and Go Container

This repo is for a bootstrapped EKS environment using Terraform that deploys a go container and provides a loadbalancer for that container.

## Prerequisites

- [Git](https://git-scm.com/) version: `>=2.34.1`
- [Docker](https://www.docker.com/) version: `>=25.0.3`
- [Terraform](https://www.terraform.io/) version: `>=1.7.4`
- [AWS CLI](https://aws.amazon.com/cli/) version: `>=2.15.21`
- Active [AWS Account](https://aws.amazon.com/)

## Terraform Variables

| Variable Name | Required | Default | TF File |
|:--:|:--:|:--:|:--:|
| `aws_region` | no | us-east-1 | [varibles.tf](terraform/variables.tf) |
| `aws_access_key` | [yes](#deploying-eks-cluster) | nil | [varibles.tf](terraform/variables.tf) |
| `aws_secret_key` | [yes](#deploying-eks-cluster) | nil | [varibles.tf](terraform/variables.tf) |

## Deploying the EKS Cluster

1. Ensure you have the neccessary prerequisites. [See above](#prerequisites).

2. Clone the repo locally using `git`.
    
    ```bash
    git clone https://github.com/b1tsized/liatrio.git
    ```

3. `cd` into the directory for Terraform.

    ```bash
    cd ./liatrio/terraform
    ```

4. Configure AWS Credentials for Terraform. 

    - Ensure that you have either configured your AWS Credentials in [`~/.aws/config`](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) or you have run [`aws configure sso`](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html).

        > Note: If you do use this method, then you must remove the following blocks from [variables.tf](terraform/variables.tf) and remove the lines for `access_key` and `secret_key` [providers.tf](terraform/providers.tf)

        ```terraform
        variable "aws_access_key" {
            type        = string
            description = "AWS Access Key ID you'd like to use."
        }

        variable "aws_secret_key" {
            type        = string
            description = "AWS Secret Key you'd like to use."
            sensitive   = true
        }
        ```

        ```terraform
        provider "aws" {
            region     = var.aws_region
            access_key = var.aws_access_key
            secret_key = var.aws_secret_key
        }
        ```

    - If you're using a key pair, then you can either create a file in the terraform folder using the `.auto.tfvars` convention or you can export the variables to your terminal using the [`TF_VAR` convention](a9abfc70a0e3c46f38eea7ab35463fdf-1249693632.us-east-1.elb.amazonaws.com).
        
        `secrets.auto.tfvars` Example:

        ```terraform
        aws_access_key = "AKI..."
        aws_secret_key = "zt48..."
        ```

        Exporting `TF_VAR` Example:

        ```bash
        export TF_VAR_region=us-west-1
        export TF_VAR_aws_access_key=AKI...
        export TF_VAR_aws_secret_key=zt48...
        ```

5. Run `terraform init` in the `terraform` directory.

    ```bash
    terraform init
    ```

6. Run `terraform apply` in the terraform directory.

    ```bash
    terraform apply
    ```

7. A prompt will appear the confirm changes. Type `yes` to confirm changes and press `Enter`.
    
    > Note: If you want to run without confirming the changes terraform is making you can always run `terraform apply --auto-approve` instead

8. Allow `terraform` to run.

9. Once completed there will be a `terraform` output for `liatrio_go_url`. 

    This takes about two minutes to finish deploying the container. You can use this url to either navigate in your browser or run a `curl` using your terminal. Example below where you'll need to update the `${liatrio_go_url}` with the outputed URL.

    ```bash
    curl http://${liatrio_go_url}
    ```

## Cleaning up the EKS Cluster

Once you're done testing you can clean up all resources for the EKS cluster by running one command.

1. From the liatrio folder, `cd` into the `terraform/` folder.

    ```bash
    cd ./terraform
    ```
2. Run `terraform destroy` within the `terraform/` folder.

    ```bash
    terraform destroy
    ```
3. A prompt will appear the confirm changes. Type `yes` to confirm changes and press `Enter`.
    
    > Note: If you want to run without confirming the changes terraform is making you can always run `terraform destroy --auto-approve` instead

4. Allow `terraform` to run. Once done all resources should be deleted.