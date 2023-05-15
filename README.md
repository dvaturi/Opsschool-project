# START ENVIRONMENT
## infrastructure diagram
![Untitled drawio (10)](https://user-images.githubusercontent.com/57751780/233061445-ab1618db-3472-4f3c-af76-32df9ce588ba.png)


## Project Workflow diagram
![CI_CD flow diagram drawio](https://user-images.githubusercontent.com/57751780/232643071-8e1407cd-3d85-477b-85bf-ab9fc41648f5.png)

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
## Connect to vpn
Go directly into the s3 bucket that has been created with the arn: "arn:aws:s3:::opsschool-vpn-client" and download the openvpn client file called "ospschool.ovpn"

Download and install [Openvpn connect](https://openvpn.net/client/) client on your computer

use the openvpn official client in order to connect to the openvpn server that has been created as part of the process.

click on the icon of the "openvpn connect" app and then import profile.
wait for the client to connect to the server and then move on to the next section

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
After the environement is up run the following to update your kubeconfig file (you can get the `cluster_name` value from the cluster_name output in terraform)
```bash
aws eks --region=us-east-1 update-kubeconfig --name <cluster_name>
```
- Add the user/group/roles of the AWS account to be able to see information and run commands through Jenkins etc...
- Do it by running the following command **kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth.yaml**
- After running the command a file called **aws-auth.yaml** will be added to your path, edit it carefully and add the user/group/role with its permissions to provide permissions for the Kubernetes cluster as such
```
mapRoles: |
...

 - groups:
      - system:masters
      rolearn: arn:aws:iam::447072968892:user/opschooladmin
      username: opsschooladmin
 - groups:
      - system:masters
      rolearn: arn:aws:iam::<need to change>:role/Jenkins
      username: Jenkins
...
```
- Run the following command to update the Kubernetes config map **kubectl apply -f aws-auth.yaml**


## Run the app
- Run both Jenkins jobs build_app first to create the docker file and push it to the docker hub then deploy_app to deploy the app to the EKS cluster.

## App is running
- Go to AWS UI and look for the EKS loadbalancer that has been created, copy its external dns name and post it in your browser.
- ENJOY!

## Destroy env
- Run destroy_app Jenkins job to destroy the app inside of the EKS cluster.
- go to the s3 service in the AWS UI, and look for the following s3 bucket: "opsschool-vpn-client" Get in and delete opsschool.ovpn file.
- cd Opsschool-project/terraform/2.environment and "terraform destroy -auto-approve"
- go to the s3 service in the AWS UI, and look for the following s3 bucket: "opsschool-terraform-state-dean" Get in and delete all the state files **including the versioning**
- cd Opsschool-project/terraform/1.s3_creation and "terraform destroy -auto-approve"
- delete the file **Opsschool-project/terraform/2.environment/aws-auth.yaml** - its the old permissions file for the EKS cluster you just deleted.
- That's it, you are done and the project has been destroyed completely 

## Full Project Workflow videos.
- [1.s3 bucket creation](https://drive.google.com/file/d/1hTJXzo2EjZOdMbla9gXBNNsCqfVdA5iq/view?usp=share_link)
- [2.environment creation](https://drive.google.com/file/d/1TYrkyh5RcH_Zp9mEOhlDJ1DZlIaRpZtF/view?usp=share_link)
- [3.ansible playbook install](https://drive.google.com/file/d/1ZBCIEv_W3vqhVJnr9Qi-XF6dMBGIWWtF/view?usp=share_link)
- [4.consul and jenkins](https://drive.google.com/file/d/1dyvXf9tzAQx1Oq3DHeibXQpRZQdAZDYw/view?usp=share_link)
- [5.jenkins config](https://drive.google.com/file/d/1T2IbhbNCEMw11Do6ZTyJg-2hqFOnp1ER/view?usp=share_link)
- [6.eks cluster config and build job](https://drive.google.com/file/d/14s4fQ49VeZBOvvmYuhrbJvNyM2ejhHOw/view?usp=share_link)
- [7.deploy job](https://drive.google.com/file/d/1j4hOWDwtI0t57c-3p94JcZYcWIOBOSDQ/view?usp=share_link)
- [8.kandula app](https://drive.google.com/file/d/1oxFrSfpGPCmUMjIQxGEyW4D7FWYwGhQc/view?usp=share_link)

## Presentation
- [Opsschool-project](https://www.canva.com/design/DAFgeyxQBVo/WulIo7wy20_pV5dBShm8pA/view?utm_content=DAFgeyxQBVo&utm_campaign=designshare&utm_medium=link&utm_source=publishsharelink)
