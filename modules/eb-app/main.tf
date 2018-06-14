resource "aws_elastic_beanstalk_application" "default" {
  name = "${var.name}"

  appversion_lifecycle {
    service_role          = "${var.eb_service_role}"
    max_count             = 128
    delete_source_from_s3 = true
  }
}
