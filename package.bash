#!/bin/bash
set -e
source ./common-deploy-functions.bash

#-------------------------------------------------------------------------------
# Copyright (c) 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# 
# This source code is subject to the terms found in the AWS Enterprise Customer Agreement.
#-------------------------------------------------------------------------------

function help_message {
    cat << EOF

NAME
    package.bash    

DESCRIPTION
    Packages the IOT Privatelink service, ready for deployment.

MANDATORY ARGUMENTS:
    -b (string)   The name of the S3 bucket to deploy CloudFormation templates into.

OPTIONAL ARGUMENTS
    -R (string)   AWS region.
    -P (string)   AWS profile.
    
EOF
}

while getopts ":b:R:P:" opt; do
  case $opt in
    b  ) export DEPLOY_ARTIFACTS_STORE_BUCKET=$OPTARG;;
    R  ) export AWS_REGION=$OPTARG;;
    P  ) export AWS_PROFILE=$OPTARG;;
    \? ) echo "Unknown option: -$OPTARG" >&2; help_message; exit 1;;
    :  ) echo "Missing option argument for -$OPTARG" >&2; help_message; exit 1;;
    *  ) echo "Unimplemented option: -$OPTARG" >&2; help_message; exit 1;;
  esac
done

incorrect_args=$((incorrect_args+$(verifyMandatoryArgument DEPLOY_ARTIFACTS_STORE_BUCKET b $DEPLOY_ARTIFACTS_STORE_BUCKET)))

if [[ "$incorrect_args" -gt 0 ]]; then
    help_message; exit 1;
fi

AWS_ARGS=$(buildAwsArgs "$AWS_REGION" "$AWS_PROFILE" )


cwd=$(dirname "$0")
mkdir -p $cwd/build

echo "ARGS"
echo $AWS_ARGS
logTitle 'Packaging the IOT Privatelink  CloudFormation template and uploading to S3'
aws cloudformation package \
  --template-file $cwd/IoTPrivatelink.yaml \
  --output-template-file $cwd/build/IoTPrivatelink-output.yaml \
  --s3-bucket $DEPLOY_ARTIFACTS_STORE_BUCKET \
  $AWS_ARGS

logTitle 'IOT Privatelink packaging complete!'
