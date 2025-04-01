import boto3

def lambda_handler(event, context):
    dynamodb = boto3.client('dynamodb')
    table_name = "somanetflixdbtable"

    item = {
        "id": {"S": event["id"]},
        "data": {"S": event["data"]}
    }

    response = dynamodb.put_item(TableName=table_name, Item=item)
    return {
        "statusCode": 200,
        "body": f"Item {event['id']} saved successfully."
    }
