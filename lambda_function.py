import json
from uuid import uuid4
from os import getenv
from base64 import b64decode
import boto3
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.debug(event)

    try:
        request = json.loads(event.get("body"))
    except:
        return msg({
            "statusCode": "400",
            "body": '{"error": "JSON in request body missing or unparsable."}',
        })
    try:
        filename = request["filename"]
        file_b64 = request["fileContents"]
    except:
        return msg({
            "statusCode": "400",
            "body": '{"error": "JSON missing filename or fileContents properties"}',
        })

    try:
        file_contents = b64decode(file_b64, validate=True)
    except:
        return msg({
            "statusCode": "400",
            "body": '{"error": "fileContents fails base64 decode step"}',
        })

    if len(file_contents) == 0:
        return msg({
            "statusCode": "400",
            "body": '{"error": "fileContents empty after base64 decode step"}',
        })

    client = boto3.client("s3")

    bucket = getenv("ATTACHMENT_BUCKET")
    region = client.get_bucket_location(Bucket=bucket)["LocationConstraint"]

    key = str(uuid4()) + "-" + str(uuid4())
    filename = filename
    file_content = file_contents
    client.put_object(
        Body=file_content,
        Bucket=bucket,
        Key=key,
        ContentDisposition=f'attachment; filename="{filename}"',
    )
    # prefix = getenv("BUCKET_PREFIX", "/sent")
    return msg({
        "statusCode": "201",
        "body": f'{{"url": "https://s3.{region}.amazonaws.com/{bucket}/{key}"}}',
    })


def msg(error_obj):
    logger.info(error_obj)
    return error_obj
