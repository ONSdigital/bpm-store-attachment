# bpm-store-attachment

**bpm-store-attachment** is an AWS lambda function intended to store a single file it receives through HTTPS (via API Gateway) into an S3 bucket, and generating a secure URL (secured if not shared, at least).

## Building

After cloning the repo, you will need to create a virtualenv, as lambdas using any non-AWS, non-core modules, will need them vendorised.

```sh
git clone https://github.com/ONSdigital/bpm-store-attachment.git

mkdir generated
​
pushd bpm-store-attachment
python3 -m venv v-env
source v-env/bin/activate
pip install pipenv
pipenv install
deactivate
popd

mkdir zipit
​
mv bpm-store-attachment/v-env/lib/python3.8/site-packages/* zipit/
mv bpm-store-attachment/lambda_function.py zipit/
​
pushd zipit
zip -r9 ../generated/function.zip .
popd
```

After editing the `lambda_function.py` file, you will need to add it to the zip file created earlier.

```sh
zip -g function.zip lambda_function.py
```

You will need to re-run this last step after every edit to the lambda that you wish to deploy. You can deploy this using the `aws` CLI tool, or the management console on the web.

## Configuration

### Runtime

This lambda uses the Python 3.8 runtime.

### Trigger

You will need to set your lambda's trigger to be API Gateway. The included terraform scripts will create this for you. You may add restrictions to that, for example to only allow from certain IP ranges (e.g. your VPN) or tweak the authorisation from API key to something fancier, such as Cognito.

You should POST JSON to the endpoint (again, using the terraform scripts will output both the endpoint address and a working API key) like the following example:

```json
{
    "filename": "THE_ORIGINAL_FILENAME",
    "fileContents": "BASE64 ENCODED FILE CONTENTS"
}
```

Sample `curl` invocation:

```sh
curl --request POST \
  --url https://SOMETHING.execute-api.REGION.amazonaws.com/sandbox/files \
  --header 'content-type: application/json' \
  --header 'x-api-key: YOUR_API_KEY' \
  --data '{"filename": "README.TXT", "fileContents":"SGVsbG8gZnJvbSB0aGUgT05TIQo="}'
```

Sample successful response (201 status code):

```json
{
  "url": "https://s3.REGION.amazonaws.com/S3_BUCKET_NAME/ddaabc92-25cc-481a-810d-639868f0f21-6dc786bf-e8ad-43d8-9db3-d2446ffef8b9"
}
```

### Environment variables

| Variable name     | Description |
| ------------------|-------------|
| ATTACHMENT_BUCKET | S3 bucket name to store attachments in |
