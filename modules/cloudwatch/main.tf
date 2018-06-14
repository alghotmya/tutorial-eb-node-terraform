resource "aws_sns_topic" "default" {
  name = "${var.client}-${var.project}-admin-notifications-${var.env}"
}

# Create a metric that looks for errors 
resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${var.client}-${var.project}-${var.env}-nodejs-error-filter"
  pattern        = "?error ?Error ?Exception ?exception ?failed ?Failed"
  log_group_name = "/aws/elasticbeanstalk/${var.eb_env}/var/log/nodejs/nodejs.log"

  metric_transformation {
    name      = "${var.client}-${var.project}-${var.env}-error-count"
    namespace = "${var.client}-${var.project}-${var.env}"
    value     = "1"
  }
}

# Create an alarm on errors showing on logs 
resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "${var.client}-${var.project}-${var.env}-nodejs-error-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "${var.client}-${var.project}-${var.env}-error-count"
  namespace           = "${var.client}-${var.project}-${var.env}"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"

  alarm_description = "This alarm goes off when the error messages appear in beanstalk logs"
  alarm_actions     = ["${aws_sns_topic.default.arn}"]
}
