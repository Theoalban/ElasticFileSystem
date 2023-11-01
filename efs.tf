Create an EFS volume and mount it on EC2 instances

Introduction
In this tutorial, we will learn how to create a simple EFS volume and mount it to EC2 instances to see how it works. 

This is just a simple Demo and we will do everything in the Default VPC.  You might as well decide to create a VPC and create your instances as well as the volume in that same VPC.

Prerequisites:
Before starting, you must have a AWS account 

Part 1: Create the EFS volume from the console
Log in to the AWS Management Console, click on Services and search for the Storage domain. Choose EFS service. You will land on the EFS dashboard


 

On the EFS dashboard, click on Create file system.


Step 1: Set the details of your EFS volume

Name efs-ec2-volume;

Allow the Default VPC


You could just click on Create now and the volume will be created. But let’s look at the various options our volume will have by clicking on Customize


In the General parameters,  you can see the Storage class, and many other options you can read more about by clicking on the Learn more links

Note: EFS Standard is regional storage class that is designed to store data accross multiple AZs. This class is  generally used for frequently accessed files.

EFS One Zone class is designed to store data within a single Availability Zone in a specific AWS region. This is not very suitable for disaster recovery.

In the Performance settings, you also have Throughput mode options you can read more about


You can also add some tags to your EFS volume for identification purpose in AWS. For example, add a tag with the key Owner and put your name as value


Now, click on Next to continue the process

Step 2: Set network settings on your volume

Allow all the parameters as default (Default VPC and subnets) an click on Next


Step 3: EFS system file policy (Optional)

Allow the default values and click on Next

Step 4: Review and create

You can review all your parameters, then scroll down and click on Create

Your volume is successfully created


You can click on the volume name to get more informations about it


Part 2: Mount the EFS volume to EC2 instances
Mounting an Amazon Elastic File System (EFS) volume is crucial after its creation because it is the only way to access the file system and start using it.

How does it works?
In this part we will create 2 EC2 intances in the default VPC and mount our volume on them. The following image is the architecture that we will put in place.


Step 1: Create the EC2 instances
At this level, you know how to create an EC2 instance from the EC2 Dashboard. Go ahead and create 2 instances in the default VPC.

Instance details:

Instance names: ec2-test-efs1 and ec2-test-efs2

OS: Amazon Linux

Instance type: t2.micro

key pair name: select a keypair you already have (make sure you have it downloaded on your computer) if not, create a new key pair

Network settings: Leave everything as Default (Yes it will create a new security group)

Storage settings: Default

You can create the two instances at the same time just by modifying the number of instances to 2 in the Summary. You can then rename each instance with the given names ec2-test-efs1 and ec2-test-efs2

Step 2: Connect remotely to the instances
Now that your two instances are up and running, open your visual studio code and use the button showed on the image to split your terminal into 2.


In the first terminal, connect remotely to the first ec2 instance (ec2-test-efs1) then in the second terminal, connect remotely to the second ec2 instance (ec2-test-efs2)

You can notice, the port 22 is already open.

Make sure you are in the folder where your key pair is downloaded and run the ssh command: 

ssh -i key-pair-name.pem ec2-user@public-IP


Step 3: Install the Amazon EFS utilities 
On each server, run the following command to install the Amazon EFS utilities:



sudo yum install amazon-efs-utils -y
 

Step 4: Allow traffic from the the EC2 instances to the EFS volume
To be able to attach the volume to an EC2 instance, we must make sure the EFS volume accept the appropriate traffic by opening the right port.

We created the EFS volume with the default security group. By default this security group allows All traffic. But if this is not the case (the SG has been modified for some reasons), you won’t be able to mount the volume on your EC2 instance successfully. 

In this case, we need to open the NFS port to allow the traffic from the EC2 instances to the EFS volume.

Let’s verify the rules specified on the EFS volume security group. 

In your EFS dashboard, click on your volume then click on the Network tab to check the ID of the security group used. Copy that ID


Now, open your EC2 Dashbord, in the left colum, click on instances and check the security group name with wich your servers got created. 

You can click on the instance and go to the Security tab to check that. Here our security group name is launch-wizard-27


 

Now, still in your EC2 Dashbord, in the left colum, scroll down and click on Security groups under Network & Security and open it in a new tab

Then search for the security group ID of the EFS volume you copied earlier. Click on the security group and go to its inbound rules tab


Click on Edit inbound rules to add the NFS type of traffic. Search and select the EC2 security group name (for me here is launch-wizard-27) to define the traffic source .


If your instances were created with the same security group, you are good to go. If not, you also need to add a rule for NFS with the security group of your second EC2 instance.

Step 5: Attach the volume to the instances
In your EFS dashboard, click on the efs volume that we created earlier then click on the button Attach. 


Amazing! They give us the command to attach a volume. We will use the Mount via DNS option with the EFS mount helper

Copy the mount command as shown in the image below


On instance 1:

Now Create a folder called efs and mount the volume using the command you copied

You can give any name to the folder, just make sure you put the right name in the mount command before running it



mkdir efs
Paste the mount command in your terminal



sudo mount -t efs -o tls fs-0da033f5dff713797:/ efs
After few seconds, the prompt comes back. You can run the command df -h to see if the volume was successfuly mounted


 

If you encounter a connection timeout error, verify the inbound rules of your EFS security group to make sure it accept the traffic from the EC2 instances

You can now cd into your efs folder and create a file in there



ls
cd efs
sudo touch file1
ls
You need to have permission to create a file in there. That is why we use the sudo

On instance 2: 

Let create a folder on the second instance, it can have a different name



mkdir shared-efs
You can give any name to the folder, just make sure you put the right name in the mount command before running it

Paste the mount command in your terminal



sudo mount -t efs -o tls fs-0da033f5dff713797:/ shared-efs
After few seconds, the prompt come back as well. You can run df -h to check

You can now cd into your shared-efs folder to check its content



cd shared-efs
ls
You will realize that the file we created from the first instance (file1) is already present in the folder.


Let’s create other files from the second instance and see if it is also shared 



sudo touch file2 file3 file4
ls
Now check in the first instance with ls. You will see we have new content in there!


You can conclude the volume is really shared among instances where it is mounted.

You can download a huge file in that folder and see how the size of the volume changes in the EFS dashboard!

Clean up
When done working with AWS resources, always delete them to avoid further charges on AWS

1- Delete the EC2 instances

Exit the instances from your Terminal and delete them in the EC2 dashboard

2- Delete the EFS volume

In the EFS Dashboard, just click on the EFS volume name and then click on Delete


Now confirm the deletion by typing the ID of your volume. You can copy and paste the ID they provide then click on Confirm


Wait for few seconds until it is deleted.

You can also delete the security group that was created for your EC2 instances.

Never delete the default security group!!