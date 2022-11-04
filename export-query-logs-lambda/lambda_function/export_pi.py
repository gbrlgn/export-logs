import os
import boto3
from datetime import datetime

cw_client = boto3.client('logs')
rds_data = boto3.client('rds-data')

instance_id = "galaxpay-prod"
query = ''' 
    SELECT * FROM ba_dba.dba_processlist
    WHERE DT_LOG > NOW() - INTERVAL 2 HOUR
'''

def lambda_handler(event, context):
    query_result = run_query(query)
    
    if query_result:
        send_cloudwatch_data(query_result)

    return {
        'statusCode': 200,
        'body': 'ok'
    }


def run_query(query):
    if not query:
        return

    return rds_data.execute_statement(
        resourceArn = os.environ["DB_ARN"],
        secretArn = os.environ["DB_SECRET"],
        sql = query,
    )


def send_cloudwatch_data(result):
    if result:
        for row in (d for d in result["records"]):
            log = '''

            '''
            now = datetime.now().timestamp()

            cw_client.put_log_events(
                logGroupName='string',
                logStreamName='string',
                logEvents=[
                    {
                        'timestamp': int(round(now)),
                        'message': 'QUERY: ' + log
                    }
                ]
            )
    
    return