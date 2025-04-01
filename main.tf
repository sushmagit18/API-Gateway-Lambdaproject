

# DynamoDB Table
resource "aws_dynamodb_table" "backend_table" {
  name           = var.table_name
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "backend_bucket" {
  bucket = var.bucket_name
}

# IAM Role for DynamoDB Lambda
resource "aws_iam_role" "dynamodb_role" {
  name = "DynamoDBRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}
# IAM Policy for DynamoDB Lambda
resource "aws_iam_policy" "dynamodb_policy" {
  name = "DynamoDBPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DescribeTable"],
        Resource = "arn:aws:dynamodb:*:*:table/${var.table_name}"
      }
    ]
  })
}
# Attach DynamoDB Policy to Role
resource "aws_iam_policy_attachment" "dynamodb_policy_attachment" {
  name       = "DynamoDBPolicyAttachment"
  roles      = [aws_iam_role.dynamodb_role.name]
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

# Lambda Function for DynamoDB
resource "aws_lambda_function" "lambda_dynamodb" {
  filename         = "dynamodb_handler.zip"
  function_name    = "DynamoDBHandler"
  role             = aws_iam_role.dynamodb_role.arn
  handler          = "dynamodb_handler.lambda_handler"
  runtime          = "python3.8" # Ensure Lambda runtime is supported
  source_code_hash = filebase64sha256("dynamodb_handler.zip")


}

# IAM Role for S3 Lambda
resource "aws_iam_role" "s3_role" {
  name = "S3Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}
# IAM Policy for S3 Lambda
resource "aws_iam_policy" "s3_policy" {
  name = "S3Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}
# Attach S3 Policy to Role
resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "S3PolicyAttachment"
  roles      = [aws_iam_role.s3_role.name]
  policy_arn = aws_iam_policy.s3_policy.arn
}

# Lambda Function for S3
resource "aws_lambda_function" "lambda_s3" {
  filename         = "s3_handler.zip"
  function_name    = "S3Handler"
  role             = aws_iam_role.s3_role.arn
  handler          = "s3_handler.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("s3_handler.zip")


}

# IAM Role for Glue Lambda
 resource "aws_iam_role" "glue_role" {
   name = "GlueRole"
   assume_role_policy = jsonencode({
     Version = "2012-10-17",
     Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Glue Lambda
resource "aws_iam_policy" "glue_policy" {
  name = "GluePolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::my-glue-scripts-bucketsoma",
          "arn:aws:s3:::my-glue-scripts-bucketsoma/scripts/*"
        ]
      }
    ]
  })
}
# Attach Glue Policy to Role
resource "aws_iam_policy_attachment" "glue_policy_attachment" {
  name       = "GluePolicyAttachment"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = aws_iam_policy.glue_policy.arn
}

# Glue Job
resource "aws_glue_job" "glue_job" {
  name     = "GlueJob"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://my-glue-scripts-bucketsoma/scripts/hello_world.py"
  }

  max_retries = 1
  timeout     = 20
}


# Lambda Function for Glue
resource "aws_lambda_function" "lambda_glue" {
  filename         = "glue_handler.zip" # Update this path if needed
  function_name    = "GlueHandler"
  role             = aws_iam_role.glue_role.arn
  handler          = "glue_handler.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("glue_handler.zip") # Ensure this path matches the filename
}


# API Gateway
resource "aws_api_gateway_rest_api" "api_gateway" {
  name = "NetflixBackendAPI"
}

# API Gateway Resource
resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "example"
}

# API Gateway Method
resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Integration
resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.example_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_s3.invoke_arn
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_s3.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  description = "Deployment for prod stage"

  depends_on = [
    aws_api_gateway_method.example_method,
    aws_api_gateway_integration.example_integration
  ]
}

# API Gateway Stage
resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}