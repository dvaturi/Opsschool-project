# Login into your Jenkins
- log into the jenkins using the **loadbalancer IP we have craeted:8080**
- use the following user and password for the first time and change it after first login. username: admin password:Banana321!

# Create the required credentials
- Create Docker Hub creds - username and password (docker hub account, in the id type "dockerhub")
- Create GitHub SSH creds - ssh (use id: "github" use "jenkins" user and "cloud9-github-integration.pem" ssh key, since it's configured in github) *dont forget to go to **Manage Jenkins>Configure Global Security>git** and select approve first time of connection.
- Create Jenkins slave SSH creds ssh (use "ubuntu" user and "opsschoolproject.pem" ssh key since its the keypair for the slaves)
- Create slack secret txt - (secret: "KFLek94samnZvN6AlC0j9DYr" id:"slack.integration.token" )

# Configure your 2 slaves (Do it twice 1. slave1 2. Slave2)
- Go to "**Manage Jenkins**" then add "**+ New Node**"
- Under "**New node**" page, type the **Node name** and select "**Permanent Agent**"
- Type **Name** in the "**Name**" bracket
- Add Description
- Select the "**Number of executors**" - "**2**"
- Type **Remote root directory** in "**Number of executors**" bracket - "**Home/ubuntu/jenkins**"
- Type **Lable** in the "**Labels**" bracket - "**slaves**"
- Select **Use this node as much as possible** in the "**Usage**" bracket
- Select **Launch agents via SSH** in the "**Launch method**" bracket
- Type **IP** in the "**Host**" bracket
- Select **Ubuntu (Jenkins slaves ssh)**  in the "**Credentials**" bracket
- Select **Manually trusted key verification strategy** in the **Host Key Verification Strategy** bracket
- Press "**Save**"

# configure slack app integration
 - Go into **manage Jenkins>configure system* and search for Slack.
then configure as such "Workspace: *opsschool*, Credentials: *select the Jenkins creds you created earlier*, Default channel / member id: *#webhooks* and *save*

# Create 2 Jenkins pipeline jobs and make sure you pull the code through remote SCM with the GitHub creds
* make sure to create the deploy_app and destroy_app with "This project is parameterized" checked. create 1 parameter **CLUSTER_NAME** and leave the default blank.

- eks_consul_install - Opsschool-project/jenkinsFiles/install_consul_k8s.groovy
- eks_servoces_install - Opsschool-project/jenkinsFiles/install_k8s_services.groovy

- Run them by the following order:
1. eks_consul_install
2. eks_services_install


# Create 3 Jenkins pipeline jobs and make sure you pull the code through remote SCM with the GitHub creds
* make sure to create the deploy_app and destroy_app with "This project is parameterized" checked. create 1 parameter **CLUSTER_NAME** and leave the default blank.

- build_app - Opsschool-project/jenkinsFiles/build_app.groovy
- deploy_app - Opsschool-project/jenkinsFiles/deploy_app.groovy
- destroy_app - Opsschool-project/jenkinsFiles/destory_app.groovy

1. run build_app in order to build the app
2. run deploy_app in order to deploy the app to the EKS cluster
3. run destroy_app  in order to destroy the app and its servoce from the EKS cluster
