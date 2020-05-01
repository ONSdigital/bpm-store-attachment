#!/bin/bash
apt-get update
apt-get -y install zip
cd bpm-store-attachment
python3 -m venv v-env
source v-env/bin/activate
pip install pipenv
pipenv install
deactivate
cd v-env/lib/python3.8/site-packages
zip -r9 $OLDPWD/function.zip .
cd $OLDPWD/lambdas
zip -g ../function.zip lambda_function.py