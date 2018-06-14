output "name" {
  value = "${aws_elastic_beanstalk_environment.default.name}"
}

output "cname" {
  value = "${aws_elastic_beanstalk_environment.default.cname}"
}
