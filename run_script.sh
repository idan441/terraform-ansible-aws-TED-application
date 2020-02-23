#!/bin/bash


### This small script will run the terraform script and later the Ansible playbook. 
### The script assumes that the public key and access_key for amazon are all set. (I named my public key file as terra.pem, and the amazon access key file is in the terraform directory with the access key already typed in. )

### If you didn't define these files - then enter the directory and edit them. 
  #The AWS access key file has to be named - accessKeys.csv and located at the Terraform directory. 
  #Also make sure that the public key file is set chmod 400 . 
  #The terra.pem is located under the Ansible directory. 



#Run the terraform script
cd terraform
terraform init #This will download the needed Terraform plugins to the folder. All of these plugin will be at a hidden directory caleld ".terraform" . 
terraform apply -auto-approve #-auto-approve = makes the terraform work without asking the use to input "yes" in order to start creating the amazon resources. 

#Copy the inventory file created by Terraform to the Ansible directory. 
cd .. #Back to the main directory. 
cp ./terraform/inventory.txt ./ansible/inventory

#Run the Ansible playbook
cd ansible
ansible-playbook -i inventory playbook.yml -b --key-file terra.pem

echo " Everythings seems fine - go check it! Enter the DNS address of the nginx server and see the application running! "
echo " In order to delete all the created networks and instance cd to the terraform directory and use the command \" terraform destroy \" . REMEMBER THAT AS LONG AS THE INSTANCES ARE RUNNING - IT COSTS YOU CASH! " 


