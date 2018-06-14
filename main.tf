# Create VPC, public and private subnets
module "vpc" {
  name    = "${var.client}-${var.project}-${var.env}-vpc"
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.31.0"

  cidr             = "${local.vpc_cidr_range}"
  azs              = "${slice(data.aws_availability_zones.available.names,0,local.vpc_subnet_count)}"
  private_subnets  = "${sort(data.template_file.private_cidrsubnet.*.rendered)}"
  public_subnets   = "${sort(data.template_file.public_cidrsubnet.*.rendered)}"
  database_subnets = "${sort(data.template_file.database_cidrsubnet.*.rendered)}"

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = "${local.common_tags}"
}

# Create vpc security groups
module "instance-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.25.0"

  name   = "${var.client}-${var.project}-${var.env}-instance-sg"
  vpc_id = "${module.vpc.vpc_id}"
}
module "database-sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/mysql"
  version = "2.0.0"

  name   = "${var.client}-${var.project}-${var.env}-database-sg"
  vpc_id = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = "${module.instance-sg.this_security_group_id}"
    }
  ]

  number_of_computed_ingress_with_source_security_group_id = 1
}

# Create s3 bucket for logging
module "s3" {
  source = "./modules/s3"

  bucket = "${var.client}-${var.project}-${var.env}-s3"
  force_destroy = "${local.s3_force_destroy}"
  tags = "${local.common_tags}"
  account_id = "${data.aws_caller_identity.current.account_id}"
}

# Create backend database
module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "1.16.0"

  identifier = "${local.db_identifier}"

  engine            = "${local.db_engine}"
  engine_version    = "${local.db_engine_version}"
  instance_class    = "${local.db_instance_type}"
  allocated_storage = "${local.db_allocated_storage}"

  name     = "${local.db_name}"
  username = "${local.db_username}"
  password = "${local.db_password}"
  port     = "${local.db_port}"

  maintenance_window = "${local.db_maintenance_window}"
  backup_window      = "${local.db_backup_window}"

  tags = "${local.common_tags}"

  # DB security group
  vpc_security_group_ids = ["${module.database-sg.this_security_group_id}"]

  # DB subnet group
  subnet_ids = ["${sort(module.vpc.database_subnets)}"]

  # DB parameter group
  family = "${local.db_param_group}"

  # Disable backups to create DB faster
  # DO NOT DISABLE BACKUPS IN PRODUCTION!!!
  backup_retention_period = "${local.db_backup_retention_period}"

  # DO NOT SKIP FINAL SNAPSHOT IN PRODUCTION!!!
  skip_final_snapshot = "${local.db_skip_final_snapshot}"
}

# Create elastic beanstalk application
module "eb-app" {
  source = "./modules/eb-app"

  name = "${var.client}-${var.project}-app"
  eb_service_role = "${data.aws_iam_role.beanstalk_service.arn}"
}

# Create elastic beanstalk environment
module "eb-env" {
  source = "./modules/eb-env"

  solution_stack_name  = "${local.solution_stack_name}"

  # App
  eb_app        = "${module.eb-app.name}"
  env           = "${var.env}"
  node_version  = "${local.node_version}"
  node_command  = "${local.node_command}"

  # Network
  vpc_id          = "${module.vpc.vpc_id}"
  instance_subnets = "${join(",",sort(module.vpc.private_subnets))}"
  lb_subnets = "${join(",",sort(module.vpc.public_subnets))}"
  instance_security_groups = "${module.instance-sg.this_security_group_id}"

  # IAM
  instance_profile = "${data.aws_iam_role.beanstalk_ec2.name}"

  # EC2
  ami = "${local.ami}"
  instance_type = "${local.instance_type}"
  keypair_name  = "${local.keypair_name}"

  # ASG
  autoscale_min = "${local.autoscale_min}"
  autoscale_max = "${local.autoscale_max}"
  healthcheck_url = "${local.healthcheck_url}"

  # LB
  eb_service_role = "${data.aws_iam_role.beanstalk_service.name}"

  # Monitoring
  access_log_bucket = "${module.s3.id}"

  # DB
  db_hostname = "${replace(module.db.this_db_instance_endpoint,"/:[0-9]+/","")}"
  db_port = "${module.db.this_db_instance_port}"
  db_name = "${module.db.this_db_instance_name}"
  db_username = "${module.db.this_db_instance_username}"
  db_password = "${module.db.this_db_instance_password}"
}

# Create cloudwatch metrics for alerts
module "cloudwatch" {
  source = "./modules/cloudwatch"

  client  = "${var.client}"
  project = "${var.project}"
  env     = "${var.env}"
  eb_env  = "${module.eb-env.name}"
}

output "Elastic Beanstalk cname" {
  value = "${module.eb-env.cname}"
}

output "Elastic Beanstalk environment name" {
  value = "${module.eb-env.name}"
}

output "Database Hostname" {
  value = "${replace(module.db.this_db_instance_endpoint,"/:[0-9]+/","")}"
}
