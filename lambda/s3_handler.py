import boto3

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket_name = "my-glue-scripts-bucketsoma"
    file_key = event["file_key"]
    file_content = event["file_content"]

    s3.put_object(Bucket=bucket_name, Key=file_key, Body=file_content)
    return {
        "statusCode": 200,
        "body": f"File {file_key} saved successfully."
    }
