# Login into your jenkins
- Install

# Create the required credantials
- Creat Docker Hub creds - username and password (dockerhub account, in the id type "dockerhub")
- Create Github SSH creds - ssh (use "jenkins" user and "cloud9-github-integration.pem" ssh key, since its configured in github)
- Create jenkins slave SSH creds ssh (use "ubuntu" user and "opsschoolproject.pem" ssh key since its the keypair for the slaves)
- Create AWS creds
- Create K8 creds

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
- Press "**Save**"
