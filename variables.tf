##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "client" {
  default = "rangle"
}

variable "project" {
  default = "nodecd"
}

variable "env" {
  default = "dev"
}
