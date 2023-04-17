# START ENVIRONMENT
![Untitled drawio (7)](https://user-images.githubusercontent.com/57751780/230970493-acc7a77a-a4a7-49c9-b2db-fbaef04dd323.png)



## Prerequisites
- Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) on your workstation/server
- Install [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) on your workstation/server
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your workstation/server
- Create a keypair for AWS (in the specific aws_region you are working in, with the specific name ```opsschoolproject``` and store the pem key under ~/.ssh/ then run the following command ```chmod 400 ~/.ssh/opsschoolproject.pem```)
- **make sure to modify var.source_pem_file_path at the terraform/2.environment/variables.tf var file if needed.

## Variables
- Change the ```aws_region``` to your requested region (default: ```us-east-1```)
- Change the ```key_name``` to your requested region (default: ```opsschoolproject```)
- Change the ```instance_type``` to your requested region (default: ```t2.micro```)

## Run Terraform
Run the following to bring the s3 bucket up (for the env tfstate file):
```bash
cd terraform/1.s3_creation/
terraform init
terraform apply --auto-approve
```

Run the following to bring the environment up:
```bash
cd terraform/2.environment/
terraform init
terraform apply --auto-approve
```

## Connect to one of the bastions
(Temp, will be automated) connect to one of the bastions with ssh (command will be prompted at the end of the terraform apply):
```bash
ssh -i "~/.ssh/opsschoolproject" ubuntu@ip.of.the.bastion
```

## Run Ansible
```bash
cd ansible
ansible-playbook all.yaml
```
## Configure Jenkins master and 2 slaves
- Follow the instructions to configure Jenkins [Jenkins_config](https://github.com/dvaturi/Opsschool-project/blob/main/Jenkins_config.md)

## Configure the Kubernetes cluster
- make sure you are on a machine with owner permissions to the EKS cluster
- Add the user/group/roles of the AWS account to be able to see information and run commands through Jenkins etc...
- Do it by running the following command **kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth.yaml**
- After running the command a file called **aws-auth.yaml** will be added to your path, edit it carefully and add the user/group/role with its permissions to provide permissions for the Kubernetes cluster as such
```
mapRoles: |
...
 - groups:
      - system:masters
      rolearn: arn:aws:iam::<need to change>:role/Jenkins
      username: Jenkins
...
```
- Run the following command to update the Kubernetes config map **kubectl apply -f aws-auth.yaml**


## Run the app
- Run both Jenkins jobs build_app first to create the docker file and push it to the docker hub then deploy_app to deploy the app to the EKS cluster.

## Destroy env
- Run destroy_app Jenkins job to destroy the app inside of the EKS cluster.
- cd Opsschool-project/terraform/2.environment and "terraform destroy -auto-approve"
- go to the s3 service in the AWS UI, and look for the following s3 bucket: "opsschool-terraform-state-dean" Get in and delete all the state files **including the versioning**
- cd Opsschool-project/terraform/1.s3_creation and "terraform destroy -auto-approve"
- delete the file **Opsschool-project/terraform/2.environment/aws-auth.yaml** - its the old permissions file for the EKS cluster you just deleted.
- That's it, you are done and the project has been destroyed completely 