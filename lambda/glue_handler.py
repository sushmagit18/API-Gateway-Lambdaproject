import boto3

def lambda_handler(event, context):
    glue = boto3.client('glue')
    job_name = "GlueJob"

    response = glue.start_job_run(JobName=job_name)
    return {
        "statusCode": 200,
        "body": f"Glue job {job_name} started successfully."
    }
