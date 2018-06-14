##################################################################################
# DATA
##################################################################################

locals {
  # Common tags to attach to resources
  common_tags = {
    client      = "${var.client}"
    project     = "${var.project}"
    environment = "${var.env}"
  }

  # TODO: Read config from external source
  solution_stack_name = "64bit Amazon Linux 2018.03 v4.5.0 running Node.js"

  node_version = "8.11.1"
  node_command = "npm start"

  vpc_cidr_range      = "172.31.0.0/16"
  vpc_subnet_count    = 2

  ami             = "ami-922914f7"
  instance_type   = "t2.micro"
  # Manually create key through AWS console or manage own keys and provide pub key through automation
  # Key needs to exist before environment can be provisioned
  keypair_name    = "${var.client}-${var.project}-ec2-key"

  autoscale_min   = "1"
  autoscale_max   = "2"
  healthcheck_url = "/"

  # S3 Bucket for Elastic Beanstalk application logs
  # DO NOT FORCE DELETE IN PRODUCTION!!! 
  s3_force_destroy = true

  db_engine            = "mysql"
  db_engine_version    = "5.6.39"
  db_param_group       = "mysql5.6"
  db_instance_type     = "db.t2.micro"
  db_allocated_storage = 5 # Size in GB

  db_maintenance_window = "Mon:00:00-Mon:03:00"
  db_backup_window      = "03:00-06:00"

  db_identifier = "${var.client}-${var.project}-${var.env}-db"
  db_name     = "mydb"
  db_username = "mydbuser"
  db_password = "u53St0ngPa55w0rd"
  db_port     = "3306"

  # Disable backups to create DB faster
  # DO NOT DISABLE BACKUPS IN PRODUCTION!!!
  db_backup_retention_period = 0

  # DO NOT SKIP FINAL SNAPSHOT IN PRODUCTION!!!
  db_skip_final_snapshot = true
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "template_file" "public_cidrsubnet" {
  count = "${local.vpc_subnet_count}"

  template = "$${cidrsubnet(vpc_cidr,8,current_count)}"

  vars {
    vpc_cidr      = "${local.vpc_cidr_range}"
    # Odd numbers for public subnet
    current_count = "${count.index*2+1}"
  }
}

data "template_file" "private_cidrsubnet" {
  count = "${local.vpc_subnet_count}"

  template = "$${cidrsubnet(vpc_cidr,8,current_count)}"

  vars {
    vpc_cidr      = "${local.vpc_cidr_range}"
    # Even numbers for private subnet
    current_count = "${count.index*2}"
  }
}

data "template_file" "database_cidrsubnet" {
  count = "${local.vpc_subnet_count}"

  template = "$${cidrsubnet(vpc_cidr,8,current_count)}"

  vars {
    vpc_cidr      = "${local.vpc_cidr_range}"
    # Offset for db subnet
    current_count = "${count.index+50}"
  }
}

# Beanstalk service role for managing services
data "aws_iam_role" "beanstalk_service" {
  name = "aws-elasticbeanstalk-service-role"
}

# Beanstalk instance profile for managing ec2
data "aws_iam_role" "beanstalk_ec2" {
  name = "aws-elasticbeanstalk-ec2-role"
}
