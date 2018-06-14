# Terraform Elastic Beanstalk Infrastructure Template

This project creates a highly available and fault tolerant architecture for deploying a Node.js application on Elastic Beanstalk.

# Requirements
1. An AWS user that has programmatic access to provision the Elastic Beanstalk environment through Terraform. The user should have access to configure resources in Elastic Beanstalk, RDS, S3, and CloudWatch.
2. aws-elasticbeanstalk-service-role with the following policies attached:
	- AWSElasticBeanstalkEnhancedHealth
 	- AWS Managed Policy AWSElasticBeanstalkService
3. aws-elasticbeanstalk-ec2-role with the following policies attached:
	- AWSElasticBeanstalkWebTier
	- AWSElasticBeanstalkMulticontainerDocker
	- AWSElasticBeanstalkWorkerTier

# Getting Started
1. Run `terraform init`
2. Run the following with keys from programmatic user and review the plan
```
terraform plan \
  -var "aws_access_key=$AWS_ACCESS_KEY" \
  -var "aws_secret_key=$AWS_SECRET_KEY" \
  -var "aws_region=$AWS_REGION" \
  -out terraform.tfplan
``` 
3. Run `terraform apply terraform.tfplan`
