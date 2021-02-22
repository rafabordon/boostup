# Flask APP with MongoDB

### Requirements

* aws_profile setup with permissions to create resources
* Terraform v0.12 or higher
* Create a bucket named *tf-states-boostup* which will be used to store state files
* Use `ubuntu` as the user to connect to the Ec2 hosts via ssh

### Provisioning

In order to deploy the app in an AWS account just run:

`./deploy webserver testing [plan|apply]`

* Will create a VPC and all of its resources from the directory *network*
* Will deploy one EC2 with a MongoDB running in a Docker container
* Will deploy N EC2 instances with Flask app in Docker containers

### Validation

Once Terraform has created all resources the output will show the ELB DNS that you should be able to put in your browser and reach the app.
You will also get the WebServers and Mongo's public IPs to connect via ssh like this:

`ssh -i ./application/files/id_rsa ubuntu@[webserver_ip|mongo_ip]`
.

