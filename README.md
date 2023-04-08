# START ENVIRONMENT

![Untitled drawio (5)](https://user-images.githubusercontent.com/57751780/230722852-b6c97871-f7e3-4dc2-b681-323a6c0aa5c3.png)




## Prerequisites
- Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) on your workstation/server
- Install [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) on your workstation/server
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your workstation/server
- Create a keypair for AWS (in the specific aws_region you are working in, with the specific name ```opsschoolproject``` and store the pem key under ~/.ssh/ then run the following command ```chmod 400 ~/.ssh/opsschoolproject.pem```)
- **make sure to modify var.source_pem_file_path at the terraform/2.environment/variables.tf var file if needed.

## Variables
- Change the ```aws_region``` to your requested region (default: ```us-east-2```)
- Change the ```key_name``` to your requested region (default: ```opsschoolproject```)
- Change the ```instance_type``` to your requested region (default: ```t2.micro```)

## Run terrafrom
Run the following to bring the s3 bucket up (for env tfstate file):
```bash
cd terraform/1.s3_creation/
terraform init
terraform apply --auto-approve
```

Run the following to bring environment up:
```bash
cd terraform/2.environment/
terraform init
terraform apply --auto-approve
```
