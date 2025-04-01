variable "bucket_name" {
  description = "Name of the S3 bucket"
  default     = "my-glue-scripts-bucketsoma"
}

variable "table_name" {
  description = "Name of the DynamoDB table"
  default     = "somanetflixdbtable"
}
