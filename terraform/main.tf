


##########################################################################################
######## Make a VPC with two subnets in different availability zone ######################
##########################################################################################
########### In this solution I show how to make a micro-service architechture ############
################## in aws (Amazon Web services) using Terraform v0.12 ####################
##########################################################################################


#An introduction - 
  #This example is a full solution for beginner and advanced users of the Amazon aws services. 
  #I tried to put as many notes and explanations as I can in order to make it easy to understand. 
  #In this example I will be using an application named "TED-app" which is a Java Spring application which queries the TED's website for lectures. It then shows the results of the lectures search. This application is web-based and working on port 9191 with HTTP protocol. The application source code is located in the TED-app directory. 


#I use Terraform version 0.12 . Please note that there are syntax differences between this version and older ones. 

#I also made another example on how to use load balancer (LB) in Amazon aws, which is based on this example. 



###################################
##### How to use Terraform? ######
###################################

#Instructions - How to use terraform - 
# 1. terraform init - initialize the terraform in the specific folder. ( Downloading all necessary plugins, if new lines of code which requires new plugins are introduced - do another initiation! )
# 2. terraform - validate - check that the files with .tf extension are syntax fine. 
# 3. terraform apply - start the terraform, create the instances. 
# 4. terraform destroy - stop the terraform, terminate the instances. 


#Good tutorials - 
# A basic tutorial for launching instances using Terraform - https://www.youtube.com/watch?v=rR8YNxHnNjw
# A tutorial about networks - https://medium.com/@mitesh_shamra/manage-aws-vpc-with-terraform-d477d0b5c9c5
# A great tutorial for Ansible - https://www.tutorialspoint.com/ansible/index.htm 
# A step by step guide to use terraform - GREAT - https://www.youtube.com/channel/UCYbBB8FLtf-N0ZW1EYmiw-Q/videos

#A great calculator for calculating ip range - 
  # http://jodies.de/ipcalc?host=10.1.0.0&mask1=16&mask2=



###############################################
###### Beggining of the Terraform script ######
###############################################



##################################################
############### Set the variables ################
##################################################


#Set my key-pairs. In order to connect for an EC2 instance you need to make a key-pair. Prior to running this script I have made a key-pair named "terra" , the private key is kept by amazon while I hold the public key locally. 
#Later on I will be defining the private key for the instances Which I am going to make. By attaching them the "terra" key I will be able to ssh them. 
variable "key_name" {
    default = "terra" #This will refer the created instances to the key-pair "terra" which is SET IN THE aws console! 
}

#Make two variables for 2 availability zones. (=AZ)
  #In this example I will be making two subnets, each one in a different avalability zone. (AZ) 
  #Availability zone is an internal area and infrastructure inside an amazon aws region. For my example I am using Ohio region (us-east-2) which has 3 availability zones (AZ) - a, b and c . 
variable "region" {
  default ="us-east-2"
}
variable "availability_zone1" {
    default = "us-east-2a"
}
variable "availability_zone2" {
    default = "us-east-2b"
}



######################################################################
############### Set the CIDRs for the VPC and subnets ################
############### Also a small lesson about networking! ################
######################################################################


#First of all I will expalain a few concepts about networking and cloud technologies - 

#VPC - 
  #The amazon cloud is a large servers infrastructure including many different costumers. In order to isolate my EC2 instances I will need to make a "small private" cloud inside the amazon cloud. And that is a VPC! 
  #VPC stand for - virtual private cloud, which is actually an enclosed isolated cloud inside a bigger cloud service. 

#Subnets - 
  #Each VPC contains subnets - which are internal networks. 
  #Each subnet is having a range of ip addresses which are available for EC2 instances. ( Each instance is given an ip address, and with these ip addresses they can connect to each other - AND HERE IS THE AMAZIN PART - all of that in my own virtual private cloud (VPC) which I have made! ) 
  #By making a subnet you can isolate groups of EC2 instances from other subnets in your own VPC . ( So for example I can have a small subnet of 4 EC2 instances - and to control and make a unique security policy for them. ) 
  #Each subnet can be in one availability zone (AZ) and all EC2 instances who are part of the subnet will be on that AZ. 

#CIDR - 
  #To define a subnet you need to define it's IP addresses range - and for that you need to define a classes inter-domain routing. (CIDR) 
  #CIDR is basically a way to defined a network size - you choose the fixed number in the IP address - and the end-stations numbers which are not fixed. 
  #* I won't explain about how to calculate CIDR , you can search for it on google. *

#How my defined network will look like? 
  #In my example I am using a CIDR of 10.1.0.0/24 for the VPC - which means that all IP addresses will start with 10.1.0 - and the last number will be differnt. That means that there will be 256 IP addresses in my VPC ranging from 10.0.1.0 to 10.0.1.255 . 
  #Later, I will be dividing the VPC to two subnets, each will include 128 ip adresses. ( subnet 1 will range from 10.0.1.0 to 10.0.1.127 and subnet 2 will range from 10.0.1.128 to 10.0.1.255 . ) 
  #Each subnet will also have a CIDR in order to define its ip addresses range. 

#
  #Important concept - for every EC2 instance an ip address needs to be assigned - whether automatically or manually when creating the EC2 instance. In this example I will be creating 2 instances adn will assign them ip addresses manually! 
  #A note - amazon is taking 4 ip addresses from every subnet, in order to use it for routing and networking - first number is the network name (that's globally not only in amazon) , second number is the router ip address which connect the subnet to other networks, the third number is save for future use of amazon - and the last number is for broadcasting. 
    #Example - for subnet 1 with a CIDR of 10.1.0.0/25 where the ip range is from 10.1.0.0 to 10.1.0.127 : 
      #10.1.0.0 is the network name and you can't use it. (That is general in all networking world - not only in amazon! ) 
      #10.1.0.1 is the network router, and the EC2 instances in the network will use this router to connect to each other and to other subnets. ( and the internet if you open the network for the web. ) 
      #10.1.0.2 is saved by amazon for future uses and therefore can't be assigned to an EC2 instance. 
      #10.1.0.127 - the last number on the netwrok (=the last number on the range) is used for broadcasting. 

  #A great calculator for calculating ip ranges which I used - 
    # http://jodies.de/ipcalc?host=10.1.0.0&mask1=16&mask2=

    

#Define a CIDR for the VPC. 
variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default = "10.1.0.0/24" # Note that some IP addresses are considered public and some private, the private ones are FREE - and this ip address of 10.1.0.0 is a free one. (This range is called "Class A" and is used for small private networks. ) 
}

#The CIDR for every subnet need to be different so no IP overlap will happen. (Amazon AWS will show error in case it happens - and will not make the subnets, meaning the "terraform apply" command will show errors. )
variable "cidr_subnet1" {
  description = "CIDR block for the subnet"
  default = "10.1.0.0/25"
  #Ip range 10.1.0.0 - 10.1.0.127 = total of 128 addresses. ( From them amazon will use first 4 and last 1 so it is neto 123 . )
}
variable "cidr_subnet2" {
  description = "CIDR block for the subnet"
  default = "10.1.0.128/25"
  #Ip range 10.1.0.128 - 10.1.0.255 = total of 128 addresses. ( From them amazon will use first 4 and last 1 so it is neto 123 . )
}


#Here I will be making a tag called production and I will add it to the resources (EC2 instances, VPN, subnets etc... ) in order to be able to categorize them for comftability. You don't have to do it - it's just to make things easier! 
variable "environment_tag" {
  description = "Environment tag"
  default = "Production"
}



###########################
#### Connect to amazon ####
###########################

#Provide a provider (AWS) and credentials for login. 
  #Here I pick region us-east-2 which is Ohio, and includes 3 availability zones. ( In short AZ. ) 
  #The credentials are saved in a file called accesKeys.csv which is located in my directory. Just put you credentials in order for Terraform to login to AWS . 
  #Remember to make sure not to share your credentials! 
provider "aws" {
 region = var.region 
 shared_credentials_file = "./accessKeys.csv"
  #More information here about how to login to AWS using terraform  - https://blog.gruntwork.io/authenticating-to-aws-with-the-credentials-file-d16c0fbcbf9e
}



#########################################################################################
######## Set the VPC and subnets and connect them together with a routing table #########
#########################################################################################

#Set the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_vpc #As defined in the variable section - the CIDR of the VPC is "10.1.0.0/24" - this is a private IP address range - class A - NOT COSTING CASH!!! 
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Environment = var.environment_tag 
    #Environment name in this case "PROD" = production. ( In this example it doesn't matter and is just for comfortability. ) 
  }
}

#Define 2 subnets for this exersice. 
resource "aws_subnet" "subnet_public1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.cidr_subnet1 #Defined in the variables section. 
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zone1 #us-east-2b, see variables section. 
  tags = {
    Environment = var.environment_tag
  }
}
resource "aws_subnet" "subnet_public2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.cidr_subnet2 #Defind in the variables section. 
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zone2 #us-east-2a, see variables section. 
  tags = {
    Environment = var.environment_tag
  }
}



#What is a routing table? 
  #Each VPC is having a routing table, which is basically a table (list) of it's routers. 
  #When a computer wants to contact another computer in the same network (subnet) it uses the networks route. 
  #When a computer wants to contact another computer in a different network - then it contact it's network router, which in turn contacts the router of the other network - which in turn contact the computer on that network. 
  #In order for the router of the two networks to know each other - they need to connect to a routing table - which tells them the ip addresses of the other routes. ( In amazon it is the second number on the network remember? 10.1.0.2 and 10.1.0.128 in my subnets! :D ) 


#What is an internet gateway? 
  #It is an amazon object which basically adding another "router" to the VPC's routing table - a router which is connected to the web. 
  #In simple words - if you add an internet gateway - then your VPC can be connected to the internet. ( And not isolated anymore. ) 
  #Why would I like to do it? Because I want to access the TED-app from my browser, and therefore the EC2 instances needs to be connected to the internet. 
resource "aws_internet_gateway" "igw" { # Allow access of the instances to the web, by opening an internet gateway and attaching it to the routing table. 
  vpc_id = aws_vpc.vpc.id
  tags = {
    Environment = var.environment_tag
  }
}

#Add a line for the routing table which opens the instances to all outside IPs (To the web) which is 0.0.0.0/0
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
      Environment = var.environment_tag
  }
}

#Add the two subnets to the routing table - so they can be connected between each other. ( Also because there is an internet gateway then they will be able to connect to the internet. ) 
resource "aws_route_table_association" "rta_subnet1_public" {
  subnet_id      = aws_subnet.subnet_public1.id
  route_table_id = aws_route_table.rtb_public.id #rtb_pubic is a routing table defined in teh above paragraph, which can connect between the subnets and the gateway. 
}
resource "aws_route_table_association" "rta_subnet2_public" {
  subnet_id      = aws_subnet.subnet_public2.id
  route_table_id = aws_route_table.rtb_public.id #rtb_pubic is a routing table defined in teh above paragraph, which can connect between the subnets and the gateway. 
}



#############################################################
####### Now launch the instances and open their ports #######
#############################################################

#Create security group which will allow to ssh the instances. 
  #I plan to use Ansible in order to configure the instances - and Ansible uses ssh connection! 
  #Also I intend to open port 80 for the nginx instance and port 9191 for the TED-app instance. 
resource "aws_security_group" "sg_22" {
  name = "sg_22"
  vpc_id = aws_vpc.vpc.id
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.environment_tag
  }
}
resource "aws_security_group" "open_80" {
  name = "open_80"
  vpc_id = aws_vpc.vpc.id
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.environment_tag
  }
}
resource "aws_security_group" "open_9191_internally" {
  #Open port 9191 internally in the security group - just for the server! 
  #This port will be accesable by the Nginx and Java servers - so they can connect! 
  #This will set a security group which will open port 9191 in the CIDR 10.1.0.0/16 in its inbound rules. ( 10.1.0.0/16 = all ip addresses in the range 10.1.any_numer.any_number )
  name = "open_9191_internally"
  vpc_id = aws_vpc.vpc.id
  ingress {
      from_port   = 9191
      to_port     = 9191
      protocol    = "tcp"
      cidr_blocks = ["10.1.0.0/16"]
  }
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.environment_tag
  }
}


#Define the instances: 
  #In this exersice I plan to use 2 EC2 instances - 
    #A JRE instance which can run the TED-app. ( It's and Ubuntu OS with JRE installed. ) 
    #An nginx instnace to proxy to the TED-app instnace. 


resource "aws_instance" "JRE" {
    ami = "ami-0078ca2a4267ee52d" # Java8 ami from amazon. 
    instance_type = "t2.micro" #This instance is free-tier eligible. ( and the only one... ) 
    key_name = var.key_name #Key name to use for ssh-ing the instances. ( The key name I chose is "terra" and I created it in the AWS console manually and downloaded the public key to my local machine. ) 
    
    
    availability_zone = var.availability_zone1 #Assign an AZ. 
    subnet_id = aws_subnet.subnet_public1.id #Assign the subnet to this instance. The subnet must be correlated with the AZ defined in the above line! 
    vpc_security_group_ids = [
                                "${aws_security_group.sg_22.id}", 
                                "${aws_security_group.open_9191_internally.id}"
                              ]

    tags = {
        Environment = var.environment_tag
    }

    #Set static IP address
    private_ip = "10.1.0.6" #This static ip addresses was chosen BY ME, you can choose other ip addresses -as long as they are in the defined ip ranges of that subnet! ( In this case 10.1.0.0 - 10.1.0.127, excluding the 4 reserved ip addresses. 10.1.0.0/1/2/255 . ) 
}

resource "aws_instance" "nginx" {
    ami = "ami-002438e556dd03e4c" # Bitnami nginx ami from amazon aws. 
    instance_type = "t2.micro" #This instance is free-tier eligible. ( and the only one... ) 
    key_name = var.key_name

    #Put it in the created Private network. 
    availability_zone = var.availability_zone2
    subnet_id = aws_subnet.subnet_public2.id #Again there must be a correlation between the AZ and the subnet... 
    vpc_security_group_ids = [
                                "${aws_security_group.sg_22.id}", 
                                "${aws_security_group.open_80.id}"
                              ]
    tags = {
        Environment = var.environment_tag
    }

    #Set static IP address
    private_ip = "10.1.0.135"

    #Set a static ip address - so I can refer to it in the nginx configurations file later. 
    #The private IP address is defined according to the CIDR . ( Which in this case is defined as 10.0.0.0/16 - see resource "aws_vpc" above for further explanation. ) 
    #Imporatnat note - the first 4 and 4 last IP addresses are used by Amazon services - so I had to start from 10.1.0.5 ! Full explanation - https://forums.aws.amazon.com/thread.jspa?threadID=178972
    #In order to make the IP address range calculation easier I used this website calculator - It showed the IP ranges that I can use for the defined Subnet - http://jodies.de/ipcalc?host=10.1.0.0&mask1=16&mask2= ( See resource "aws_vpc" for subnet information. ) 
    #The private_ip of the JRE instance is = "10.1.0.5"
}



###################################
### Test the created network! #####
###################################

#In order to test it run "terraform apply" and then you can see two EC2 instances. 
#In the aws console you can see their AZ and subnet. ALso you can see they are both in the same vpc and are having the static ip addresses which I assigned. 
#If you want to check their connectivity - and to asure that both subnets are connect - please do! Just connect to one of the instances through ssh and try to ssh to the instance. (You can also just ping port 22 which is opened in both instances. ) 




### And that's it! Now we have defined a vpc with 2 subnets, each one with an instance - and they can both contact each other! 

### Now for the Ansible part... 


#######################################################################
### Ansible part! How to configure both EC2 instances using Ansible ###
#######################################################################

#Some basic instructions - 
  #The Ansible script is located in a different file... 
  #The Ansible script needs to run locally from a computer - whether youre local machine or another third EC2 instance. 
  #Just make sure you can connect via ssh to the EC2 instances. ( In this example I opened them on port 22 for ssh-ing so it is possible. ) ###

#What do I need to from the Terraform? 
  #The Ansible script needs to have the ip address OR DNS addresses of the instances in order to connect to them via ssh and to cinfugre them. 
  #I chose to run Ansible from my local machine which is out of the VPC which I have created using this Terraform script. 
    #Therefore, I need to access the EC2 instances from outisde the VPC - which means that the internal ip addresses are useless to me. (they are unaccesable for computers outside the VPC. ) 
    #Instead, I will be using the DNS public addresses which are accesable from the internet. ( And that is thanks to the fact that I have opened the routing table of the VPC to the internet gateway! :D )

#So what do I need now? 
  #All I need is to get the instances DNS addresses fo the created instances. 
  #I do it by using a template file, and outputing the instances DNS addresses. 
  #The template file is named inv_file.tmp and can be found in this directory. 
  #The output inventory file(It's an Ansible's definition) will be saved in this directory too. 

  #For further expalnation about Ansible and the inventroy file - see the Ansible directory. 



#######################################
###### Make the inventory file! #######
#######################################

#Now make an inverntory file with the CURRENTLY CREATED instances' addresses - so it can be later used by Ansible. 
#The file is created at the end of this Terraform script, and based on a template file called inv_file.tmp

#Define the template file which will be used as the template, also define the varibales which should be replaced in the template file with the public DNS addresses of the EC2 instances. 
data "template_file" "create_inventory_file" {
  template = "${file("${path.module}/inv_file.tmp")}"
  depends_on = [ #This template_file.dev_hosts will be executed after the instances are in the air! 
                  aws_instance.nginx,
                  aws_instance.JRE
               ]
  vars = { #These variables are defined in the inv_file.tmp - and will be replaced with the instances' addresses! 
            nginx_servers_list = aws_instance.nginx.public_dns, 
            java8_servers_list = aws_instance.JRE.public_dns
         }
}

#Render the template = just put the DNS addresses in it... 
resource "null_resource" "create_inventory_file" { 
  triggers = {
    template_rendered = "data.template_file.create_inventory_file.rendered"
  }
  provisioner "local-exec" { #That will save the inventroy file created. 
    command = "echo '${data.template_file.create_inventory_file.rendered}' > inventory.txt" #Take the rendered template file content and write it in a file called inventroy.txt. 
  }
}


