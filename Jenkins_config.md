# Login into your jenkins
- Install

# Create the required credantials
- Creat Docker Hub creds - username and password (dockerhub account, in the id type "dockerhub")
- Create Github SSH creds - ssh (use "jenkins" user and "cloud9-github-integration.pem" ssh key, since its configured in github)
- Create jenkins slave SSH creds ssh (use "ubuntu" user and "opsschoolproject.pem" ssh key since its the keypair for the slaves)
- Create slack secret txt - "KFLek94samnZvN6AlC0j9DYr"
- Create K8 creds - create secret text with the output of "cat home/ubuntu/.kube/config"

# Configure your 2 slaves (Do it twice 1. slave1 2. Slave2)
- Go to "**Manage Jenkins**" then add "**+ New Node**"
- Under "**New node**" page, type the **Node name** and select "**Permanent Agent**"
- Type **Name** in the "**Name**" bracket
- Add Descripion
- Select the "**Number of executors**" - "**2**"
- Type **Remote root directory** in "**Number of executors**" bracket - "**Home/ubuntu/jenkins**"
- Type **Lable** in the "**Labels**" bracket - "**slave1**" and "**slave2**" (a name per slave that is being created)
- Select **Use this node as much as possible** in the "**Usage**" bracket
- Select **Launch agents via SSH** in the "**Launch method**" bracket
- Type **IP** in the "**Host**" bracket
- Select **Ubuntu (jenkins slaves ssh)**  in the "**Credentials**" bracket
- Select **Manually trusted key verification strategy** in the **Host Key Verification Strategy** bracket
- Press "**Save**"

# Configure your 2 slaves to be able to work on kubernetes namespace.
- configure slack app integration, by going into manage jenkins>configure system and look for slack.
then configure as such "Workspace: *opsschool*, Credentials: *select the jenkins creds you created earlier*, Default channel / member id: *#webhooks* and *save*
# Configure the Kubernetes cluster
- make sure you are on a machine with owner permissions to the eks cluster
- Add the user / group / roles of the aws account to be able to see information and run commands through jenkins etc..
- Do it by running the following command **kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth.yaml**
- After running the command a file called **aws-auth.yaml** will be added to your path, edit it carfuly and add the user/group/role with its permissions in order to provide permissions for the kubernetes cluster as such
```
mapRoles: |
...
 - groups:
      - system:masters
      rolearn: arn:aws:iam::<need to change>:role/jenkins
      username: jenkins
...
```
- Run the following command in order to update the kubernetes config map **kubectl apply -f aws-auth.yaml**

# Create 3 jenkins pipeline jobs and make sure you pull the code through remote scm with the github creds
* make sure to create the deploy_app and destroy_app with "This project is parameterized" checked. create 1 parameter **CLUSTER_NAME** and leave the default blank.

- build_app - Opsschool-project/jenkinsFiles/build_app.groovy
- deploy_app - Opsschool-project/jenkinsFiles/deploy_app.groovy
- destroy_app - Opsschool-project/jenkinsFiles/destory_app.groovy
