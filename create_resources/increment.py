import json
import boto3
from decimal import Decimal

# Initialize the DynamoDB resource
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    table = dynamodb.Table('WebsiteVisits')
   
    # Update the counter in DynamoDB
    response = table.update_item(
        Key={'CounterID': 'visit_counter'},
        UpdateExpression='SET #count = if_not_exists(#count, :start) + :inc',
        ExpressionAttributeNames={'#count': 'Count'},
        ExpressionAttributeValues={':inc': 1, ':start': 0},
        ReturnValues='UPDATED_NEW'
    )
   
    # Get the new counter value and convert Decimal to float
    new_count = float(response['Attributes']['Count'])
   
    # Return the response
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Counter incremented', 'new_count': new_count})
    }
