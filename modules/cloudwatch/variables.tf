variable "client" {
  description = "Client name"
}
variable "project" {
  description = "Project name"
}
variable "env" {
  description = "dev|qa|stg|prod"
}

variable "eb_env" {
  description = "Elastic Beanstalk environment to watch"
}
