output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.backend_table.name
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.backend_bucket.bucket
}

output "glue_job_name" {
  description = "The name of the Glue job"
  value       = aws_glue_job.glue_job.name
}

output "lambda_function_dynamodb_arn" {
  description = "The ARN of the DynamoDB Lambda function"
  value       = aws_lambda_function.lambda_dynamodb.arn
}

output "lambda_function_s3_arn" {
  description = "The ARN of the S3 Lambda function"
  value       = aws_lambda_function.lambda_s3.arn
}

output "lambda_function_glue_arn" {
  description = "The ARN of the Glue Lambda function"
  value       = aws_lambda_function.lambda_glue.arn
}

output "api_gateway_id" {
  value       = aws_api_gateway_rest_api.api_gateway.id
  description = "The ID of the API Gateway"
}

output "api_gateway_resource_id" {
  value       = aws_api_gateway_resource.example_resource.id
  description = "The ID of the API Gateway resource"
}