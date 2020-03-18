# bpm-store-attachment

**bpm-store-attachment** is an AWS lambda function intended to store a single file it receives through HTTPS (via API Gateway) into an S3 bucket, and generating a secure URL (secured if not shared, at least).

## Building

After cloning the repo, you will need to create a virtualenv, as lambdas using any non-AWS, non-core modules, will need them vendorised.

```sh
git clone https://github.com/ONSdigital/bpm-store-attachment.git
cd bpm-store-attachment
python3 -m venv v-env
source v-env/bin/activate
pipenv install
deactivate
cd v-env/lib/python3.7/site-packages
zip -r9 $OLDPWD/function.zip .
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

You will need to set your lambda's trigger to be API Gateway. You may add restrictions to that, for example to only allow POST requests, or only from certain IP ranges (e.g. your VPN), or to require an API key or other auth (highly recommended).

### Environment variables

| Variable name     | Description |
| ------------------|-------------|
| ATTACHMENT_BUCKET | S3 bucket name to store attachments in |
