# Resource for setting up role in a new AWS account.

When setting up a new infrastructure for the lambda, first run deploy.sh script to create a correct role with correctly assigned policies.

Replace ENVIRONMENT variable ` <accountname> ` with sandbox, cicd, uat, staging or prod


Run in the terminal
```

cd ci-bootstrap

ENVIRONMENT=<accountname> ./bin/deploy.sh
 
```
