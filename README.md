# running TED application on Amazon cloud - using Terraform and Ansible 

This example, will show how to use two new brand technologies - Terraform and Ansible. Both technologies are new and well-adapted in the Hi-Tech industry, mainly by DevOps roles. This example will teach you the fundemental basics of both these technologies. Also, I will be explaining some interesting concepts of networking and using Amazon Web Services (AWS) which is an important cloud provider at the industry. 

** I have been adding many explanations along the Terraform and Ansible script in order to make it as easy to understand as possible. In this example I explain step by step how to use both Terraform and Ansible, assuming you have no prior knowledge or experience with these two technologies. **

** The main explanations and knowledge is written in the files ```main.tf``` and ```playbook.yml``` , near the commands themselves. ** 


# The example will create a full cloud solution using Terraform and Ansible - 
This example will show how to set a running application behind an nginx server on Amazon web service (aws) , also known as Amazon Cloud. 

The architecture created at this exmaple is a small micro-service architecture, ressembling one micro-service which is the TED application. The TED application will be accessed from an nginx server, which will have a physical copy of the application static file. This copy will allow the server to serve the user much faster! 





## TED application - 
The running apllication for this example is TED application. This is JAVA spring application which queries the TED lectures' database and shows the results in a stylish-way. 

The sources for this application are located at the TED-app directory. 

The application was packaged as a JAR file and is saved under the directory "java app" . Also, there is a ocnfiguration file used by the application on that same folder. For this example, both these files will be copied to the JAVA instance and will be run on it. The copy and running command both will be "played" by the Ansible script. 

to run the application locally in your computer just type the following command - 

***This command will run the application in the background, and will be used by the Ansible script. ***
```bash
nohup java -jar embedash-1.1-SNAPSHOT.jar --spring.config.location=./application.properties &
```

To run the application while attached to the terminal type - 
```bash
java -jar embedash-1.1-SNAPSHOT.jar --spring.config.location=./application.properties #With the propeties file
java -jar embedash-1.1-SNAPSHOT.jar #Without the properties file
```



## Fast Run Instructions - 
In order to run this example, run the bash script ```run_script.sh``` located at this directory. 
```bash
shell run_script.sh
```

Before running the script make sure to update two files - 
* ./terraform/accessKeys.csv - enter the access key which will be used to acces Amazon Web Services (aws) . 
* ./ansible/terra.pem - replace this file with your public key file which will be used to access the EC2 instances which will be create by the Terraform script running in this example. 

**Also note - ** For this example I used a key-pair called "terra" . I created the key manually in the Amazon Web services. When creating this key-pair I downloaded the public key "terra.pem" which will be later used by Ansible to access the virutal machines which will be created in this example. When running the Terraform and Ansible script it is assumed that the key-pair is named "terra" . If you choose a different name - you have to update the ```./terraform/main.tf``` and the ```run_script.sh``` file. 

If you are new to Terraform and Ansible I recommend starting by making the key-pair under the name "terra" and to run the script. Later on, after understaing the concepts - you can chnage the key name. 



## Terraform - 
Terraform is an open-source infrastructure as code software tool created by HashiCorp. It enables users to define and provision a datacenter infrastructure using a high-level configuration language known as Hashicorp Configuration Language, or optionally JSON.
!(terraform logo)[./images-for-readme/terraform.png]


In this example, Terraform will be used in order to make a Virtual Private Cloud (VPC) in Amazon Web Services (aws) . 
* The Terraform script will create a virtual private cloud (VPC) with two subnets - each in a different Availability Zone (AZ) . Avilability zone is a seperate data center at amazon, which has an independet infrastructure and internet connection. Thus it raises the stability of the application as if one AZ is having a problem, the other one still works. 
* Each subnet will have it's own IP addresses range. Both subnets will be open to each other on an internal port number 9191 . 
    * One subnet will be private and will be accssed only from within the cloud. 
    * One subnet will be public - and will be open on port 80 for traffic from the web. 
    * In order to configure the ports, security groups will be created by the Terraform script. 
* Aftewards, two EC2 instances will be created. EC2 is a service of Amazon AWS which is basically a virtual machine (VM) which can be used freely for any use. 
    * One EC2 instance will run Ubuntu OS with JRE installed on it. This instance will run the TED application. 
    * ANother EC2 instance will run NGINX server. This instance will link the web to the JRE instance. Also, for this example I will upload all static files of the application to the nginx server in order to make the load of the application faster. 

### The Amazon Machine Instances - 
For this example I will be using two EC2 instances, one with JRE pre-installed and another one with nginx server pre-installed. 
AMI stands for Amazon machine instances, which is an image that will be the based OS for the EC2 instance. The image includes an opearting system and other configuration files and definitions. 
At the day of writing this file, both AMIs used are free and available in the aws marketplace - 
* ami-0078ca2a4267ee52d - A fedora host with Java8 already installed. This is an official Amazon AMI. 
* ami-002438e556dd03e4c - An nginx server image. This image is supplied by Bitnami. 


### The Terraform Version - 
The version of Terraform used in this example is v0.12 , which is the new version at Jan-2020 . 

Due to the fact that Terraform is a new technology, its version and syntax are changing often. Therefore, using a different version will might result a wrong syntax error. To check if the syntax of the Terraform script files (with .tf extension) use the command ```terraform validate``` on terminal while "cd" in the directory. 


### The terraform directory - 
All files used for the terraform script are located at the directory "terraform" . 
The main.tf file is the only file used by Terraform in order to run the script. 

To run the script - 
* You need to install the necessary plugin by typing - ```terraform init``` so all needed plugins will be donwloaded and placed in a hidden directory called ".plugins" . 
* To check the validity of the Terraform script type - ```terraform validate```
* To see a "plan" which will show what Terraform will do by running the script run, type the command - ```terraform plan```
* To run the Terraform script by typing ```terraform apply``` . This will create all needed resources on the aws. 
* To destroy all created resources, e.g. to destroy the architecture, type - ```terraform destroy``` 

**REMEMBER** - The created resources cost cash! You will be paying for the running resources!!! So make sure to destroy the work, and check in the aws console itself that there are no more resources. 


As said above, the Terraform script will create the networking architecture (VPC adn subnets) two EC2 instances will be created. Afterwards, it will create a file called ***"inventory.txt"*** which will list the DNS addresses of the newly created instances. This file will be later used by the Ansible script in order to configure the instances to run the TED application. 

### The inventory file - 
This file is created when running the Terraform script. The code which creates this file is located at the bottom of the Terraform script. 
This file will be used by the Ansible script in order to connect and configure the created EC2 instances. Also, note the structure of the file - this file is built in a structure of "inventory" file used by Ansible. 

For this example I put in the inventory.txt file an example text. When running the Terraform script, the file will be overwritten with the current information of the newly created EC2 instances. 

The template file used to make the inventory file is called inv_file.tmp and is located in the ***terraform*** directory. The file is approched by the Terraform script, whil it is running. 

The inventory file includes two groups of servers - java8 and nginx. Each group will have one instance under it. Each group is a line listing the user which will be accessed by Ansible via a SSH connection, and the DNS address of that server. The usernames are specific for the used AMIs - and are set in the Terraform script itself. 

In order for the server to be accessed by the Ansible script from you local machine, which will run the Ansible script, port 22 need to be open the EC2 instances. The terraform script will configure a security group which will open port 22 on the EC2 instances. 



## Ansible - 
Ansible is an open-source software provisioning, configuration management, and application-deployment tool. It runs on many Unix-like systems, and can configure both Unix-like systems as well as Microsoft Windows. It includes its own declarative language to describe system configuration. 
!(ansible logo)[./images-for-readme/ansible.png]

In this example Ansible will configure the two EC2 instances created by the Terraform script - 
* It will configure the JRE EC2 instance to run the TED application. 
* It will configure the nginx EC2 instance to proxy-forward the users to the JRE EC2 instances, so they can access the TED application. Also it will put the static files of the TED application on the nginx server itself, in order to make the load of the application faster. 


### Ansible terminology - 
Ansible is built in a structure as follows - 
  * All information is saved in yml files. 
  * You write the commands for every group of machines that need to be configured by the commands. 
    * If you want to do a command for one remote-machine - then put that machine in a different group! 
    * Ansible will execute all the commands for all the machines in a group with no difference! 

  * Each command is called "task" . 
    * There are many types of task which can be done - copying, editing, rinnig bash scripts etc... 
    * Ansible is open source and uses module - each module is actually a task template made a developer. 
    * If you want to look for a specific test - then searhc in google for "Ansible module X" (X=Copy etc... ) and see the list of arguments you need to put for that command to happen. 

  * Each group of tasks that should run is called a "play" 
    * All plays for all groups are called a "playbook" . 
    * In simple words - 
      * All commands (="tasks") that need to be done for a group of remote-machines 
      * All plays (tasks lists for differetn groups. ) are together in one file which is called a "playbook" . 

  * Here is a nice explanation with examples from the official Ansible website - 
    * https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html

### The inventory file - 
An inventory file is a file which names the groups of machines ot be configured. Under every group there is a list with the machines. Ansible will run the same commands **ALL** machines on the list. ( If you want to run different commands then put the machine in different groups. ) 

In this example, the inventory file used by the Ansible playbook - is created by the Terraform script. In other words, it can be seen as an automatic process occurs - where Terraform creates the file which will be used by Ansible. 

I attached an example of an inventory file under ```./terraform/inventroy.txt``` which it's content is - 
```
#This is an example for a generated inventory.txt file. This file is generated after running the main.tf terraform script. 
#When running this script, the file will be overwritten with the current list of created instances. 
[nginx]
bitnami@ec2-18-189-6-135.us-east-2.compute.amazonaws.com


[java8]
ec2-user@ec2-18-221-15-149.us-east-2.compute.amazonaws.com
``` 

It can easily be seen that there are two groups here. Ansible will SSH connect to the machines under both these groups. Then, it will run the tasks in playbook in every machine. 

### The SSH public key - 
In order for Ansible to access the machines via SSH key - it needs a public key. When creating the EC2 instances at aws the user is promted to choose a key-pair for the machines, so that the machine will be set with the private key and the user will be supplied with the public key. 

In this example, I created a key called ```terra``` BY MYSELF IN THE AMAZON CONSOLE. When the Terraform script is running it will attach the key to the machines. ( The private key will automatically be set by AWS, so you don't have it's copy. ) **I also downloaded the public key file terra.epm and kept it.** Terraform doesn't know the key content - it just tells aws to link the key to the EC2 instances. The definition of the key itself is done **manually** in the aws console, under EC2 instances, in the security menu. 

In order to run the Ansible script you need to add the key to your ```.ssh``` and configure it. Another option is to set the Ansible script to go to a specific file which contains the key. For the simplicity of this example I placed the public key under the Ansible directory itself, and I refer to it when running the playbook. 

### Running the Ansible Playbook - 
While in the Ansible directoy itself, type the following command - 
```bash
ansible-playbook -i inventory playbook.yml -b --key-file terra.pem
```
Please note that I placed the public key file path manually, so it reffers to the file ```terra.pem``` in the current directory. 

Before running the playbook - place your own secret file! You can create it at the aws console, under the EC2 service and the security menu. Also, in Linxu system, in order to run SSH commands the file needs to have 400 premission. To change the mode of the file type the command ```chmod 400 terra.pem``` 


### The task used in the Ansible script - 
All tasks are in the playbook.yml file, including full explanation. The files used for the configuration are located under two directory - ***"java8"*** and ***"nginx"*** , both in the ```ansible``` directory. 



## An important note - 
Using AWS cloud services cost cash!!! Make sure to terminate the instances when finishing the use of them! Or else you will pay for it... 
Also note, that this example is using AMIs which, at the time of making this exmaple, are free - but the price of them can change. 
By running this script, you take full responsibility on any expanse and any cost done by this example. 

Make sure to destroy all resources by typing the command ```terraform destroy``` while in the terraform directory. Also connect physically to the aws console - and make sure no resource are left! 