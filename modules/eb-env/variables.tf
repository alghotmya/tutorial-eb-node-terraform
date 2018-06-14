# EB Solution Stack
variable "solution_stack_name" {
  description = "Solution stack name"
}

# App
variable "eb_app" {
  description = "Elastic Beanstalk application name"
}
variable "env" {
  description = "dev|qa|stg|prod"
}
variable "node_version" {
  description = "Node version"
}
variable "node_command" {
  description = "Node command"
}

# Network
variable "vpc_id" {
  description = "Elastic Beanstalk VPC id"
}
variable "instance_subnets" {
  description = "Comma separated list of private instance subnets"
}
variable "lb_subnets" {
  description = "Comma separated list of public lb subnets"
}

# Security
variable "instance_security_groups" {
  description = "Comma separated list of instance security groups"
}

# IAM
variable "instance_profile" {
  description = "EC2 InstanceProfile"
}

# EC2
variable "ami" {
  description = "AMI id"
}
variable "instance_type" {
  description = "EC2 InstanceType"
}
variable "keypair_name" {
  description = "EC2 key pair name"
}

# Autoscaling group
variable "autoscale_min" {
  description = "Autoscaling min size"
}
variable "autoscale_max" {
  description = "Autoscaling max size"
}
variable "healthcheck_url" {
  description = "Healthcheck url"
}

# Load Balancer
variable "eb_service_role" {
  description = "Elastic Beanstalk service role"
}

# Monitoring
variable "access_log_bucket" {
  description = "S3 bucket for access logs"
}

# Database
variable "db_hostname" {
  description = "Database hostname"
}
variable "db_port" {
  description = "Database port"
} 
variable "db_name" {
  description = "Database name"
}
variable "db_username" {
  description = "Database username"
}
variable "db_password" {
  description = "Database password"
}
