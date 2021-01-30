**Flask APP with MongoDB**
***Requirements***
* aws_profile setup with permissions to create resources
* Terraform v0.12 or higher

**Provisioning**

In order to deploy the app in an AWS account just run:

`./deploy webserver testing [plan|apply]`

* Will create a VPC and all of its resources from the directory *network*
* Will deploy one EC2 with a MongoDB running in a Docker container
* Will deploy N EC2 instances with Flask app in Docker containers
