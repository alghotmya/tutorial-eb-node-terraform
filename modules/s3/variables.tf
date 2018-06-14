variable "bucket" {
  description = "Bucket name"
}
variable "force_destroy" {
  description = "Force destroy all objects and bucket"
}
variable "tags" {
  description = "List of tags for bucket"
  type = "map"
}
variable "account_id" {
  description = "Account ID for bucket policy"
}
