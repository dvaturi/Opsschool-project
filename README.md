# START ENVIRONMENT

![Untitled Diagram (2)](https://user-images.githubusercontent.com/24654933/112310410-3a489c00-8cad-11eb-917e-e047d6cfab26.jpg)


## Prerequisites
- Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) on your workstation/server
- Install [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) on your workstation/server
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your workstation/server
- Install [helm](https://www.consul.io/docs/k8s/helm) on your workstation/server/Jenkins slave.
- jeknins server with plugins & credntials (will be automated soon)

## Run terrafrom
Run the following to bring environment up:
```bash
cd terrafrom
terraform init
terraform apply --auto-approve
```
## Run ansible
1. ansible/ansible-playbook all.yaml

## Kubernetes
1. After the environement is up (15 min~) run the following to update your kubeconfig file (you can get the `cluster_name` value from the cluster_name output in terraform)
```bash
aws eks --region=us-east-1 update-kubeconfig --name <cluster_name>
```
2. To connect k8s to consul and install node-exporter and filebeat. run jeknins job. 
    - jenkinsFiles/install_consul_k8s.groovy
    - jenkinsFiles/install_k8s_services.groovy
    - Go over jenkinsFiles/manual_steps.md

3. You can verify commands in /kubeFiles/helm.md

## Config Bastion ssh 
1. edit ~/.ssh/config on local machine as /general/ssh_config. (modify the template with your pramaters) 

## Connect Jenkins with eks
- Copy ~/.kube/config to the kuberenetes credintiael in jenkins. 
- Update /kubeFiles/aws-auth-cm.yaml.
- Run kubectl apply -f /kubeFiles/aws-auth-cm.yaml 
- Run build_kandula_project
- Run deploy_kandula_app

# STOP ENVIRONMENT
1. Run Jenknis job to destory all resources on Kube.
2. Make sure no pods or svc are up.
3. Run ```terrafrom/terraform destory --auto-approve
