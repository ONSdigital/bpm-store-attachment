#!/bin/bash
apt-get update
apt-get -y install zip

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