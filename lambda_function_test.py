import lambda_function
import json
import os
import pytest

from lambda_local.main import call
from lambda_local.context import Context

import boto3
from moto import mock_s3


def execute(event):
    """Shorthand execute lambda call"""
    return call(lambda_function.lambda_handler, event, Context(2))


def check_user_error(result, error_type, msg):
    """Simple error message check with expected 400 status"""
    assert error_type is None
    assert result["statusCode"] == "400"
    body = json.loads(result["body"])
    assert body["error"] == msg


def new_event(filename, content):
    """Return a new event payload. Specify a key as 'None' to have it omitted"""
    b = {}
    if filename is not None:
        b["filename"] = filename
    if content is not None:
        b["fileContents"] = content
    return {"body": json.dumps(b)}


@pytest.fixture(scope='function')
def s3(aws_credentials):
    with mock_s3():
        yield boto3.client('s3', region_name='us-east-1')


@pytest.fixture(scope='function')
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ['AWS_ACCESS_KEY_ID'] = 'testing'
    os.environ['AWS_SECRET_ACCESS_KEY'] = 'testing'
    os.environ['AWS_SECURITY_TOKEN'] = 'testing'
    os.environ['AWS_SESSION_TOKEN'] = 'testing'


def good_event():
    """Returns a populated 'good' event"""
    return new_event("f.txt", "VGhpcyBpcyBzb21lIGNvbnRlbnQ=")


def test_badContent():
    (result, error_type) = execute({})
    check_user_error(result, error_type,
                     "JSON in request body missing or unparsable.")


def test_missingFilename():
    (result, error_type) = execute(new_event(None, "somecontent"))
    check_user_error(result, error_type,
                     "JSON missing filename or fileContents properties")


def test_missingFileContents():
    (result, error_type) = execute(new_event("f.txt", None))
    check_user_error(result, error_type,
                     "JSON missing filename or fileContents properties")


def test_badBase64Content():
    (result, error_type) = execute(new_event("f.txt", "notbase64"))
    check_user_error(result, error_type,
                     "fileContents fails base64 decode step")

    (result, error_type) = execute(new_event("f.txt", ""))
    check_user_error(result, error_type,
                     "fileContents empty after base64 decode step")


def test_noBucketConfigured():
    event = good_event()
    (result, error_type) = call(lambda_function.lambda_handler, event, Context(2))
    assert error_type is not None

    e = json.loads(result)
    assert e["errorMessage"] == "expected string or bytes-like object"
    assert e["errorType"] == "TypeError"


@mock_s3
def test_bucketDoesNotExist():
    os.environ["ATTACHMENT_BUCKET"] = "a.bucket.ons.digital"
    (result, error_type) = call(
        lambda_function.lambda_handler, good_event(), Context(2))
    assert error_type is not None

    e = json.loads(result)
    assert e["errorMessage"] == ('An error occurred (NoSuchBucket) when calling '
                                 'the GetBucketLocation operation: The specified '
                                 'bucket does not exist')
    assert e["errorType"] == "NoSuchBucket"


@mock_s3
def test_happy(s3):
    os.environ["ATTACHMENT_BUCKET"] = "a.bucket.ons.digital"
    s3.create_bucket(Bucket=os.environ['ATTACHMENT_BUCKET'])
    s3.create_bucket(Bucket='email')
    (result, error_type) = call(
        lambda_function.lambda_handler, good_event(), Context(2))
    assert error_type is None
    assert result['statusCode'] == '201'
