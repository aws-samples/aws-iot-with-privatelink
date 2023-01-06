#!/bin/bash
set -e
source  ./common-deploy-functions.bash

#-------------------------------------------------------------------------------
# Copyright (c) 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# 
# This source code is subject to the terms found in the AWS Enterprise Customer Agreement.
#-------------------------------------------------------------------------------

function help_message {
    cat << EOF

NAME
    deploy-cicd.bash    

DESCRIPTION
    Deploys the IOT Privatelink stack.

MANDATORY ARGUMENTS:
====================
    
    AWS options:
    ------------
    -R (string)   AWS region.
    -P (string)   AWS profile.
    
EOF
}

while getopts ":e:R:P:" opt; do
  case $opt in

    e  ) export ENVIRONMENT=$OPTARG;;
    R  ) export AWS_REGION=$OPTARG;;
    P  ) export AWS_PROFILE=$OPTARG;;

    \? ) echo "Unknown option: -$OPTARG" >&2; help_message; exit 1;;
    :  ) echo "Missing option argument for -$OPTARG" >&2; help_message; exit 1;;
    *  ) echo "Unimplemented option: -$OPTARG" >&2; help_message; exit 1;;
  esac
done

incorrect_args=0

incorrect_args=$((incorrect_args+$(verifyMandatoryArgument ENVIRONMENT e $ENVIRONMENT)))


if [[ "$incorrect_args" -gt 0 ]]; then
    help_message; exit 1;
fi

API_GATEWAY_DEFINITION_TEMPLATE="$(defaultIfNotSet 'API_GATEWAY_DEFINITION_TEMPLATE' z ${API_GATEWAY_DEFINITION_TEMPLATE} 'cfn-apiGateway-noAuth.yaml')"

AWS_ARGS=$(buildAwsArgs "$AWS_REGION" "$AWS_PROFILE" )
AWS_SCRIPT_ARGS=$(buildAwsScriptArgs "$AWS_REGION" "$AWS_PROFILE" )


echo "
Running with:
  ENVIRONMENT:                      $ENVIRONMENT
  AWS_REGION:                       $AWS_REGION
  AWS_PROFILE:                      $AWS_PROFILE
"

cwd=$(dirname "$0")

logTitle 'IOT Privatelink stack Identifying deployed endpoints'

stack_exports=$(aws cloudformation list-exports $AWS_ARGS)

logTitle 'Deploying the IOT Privatelink CloudFormation template'

aws cloudformation deploy \
  --template-file $cwd/build/IoTPrivatelink-output.yaml \
  --stack-name IOTPrivatelink-${ENVIRONMENT} \
  --parameter-overrides \
      Environment=$ENVIRONMENT \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset \
  $AWS_ARGS


logTitle 'IOT Privatelink deployment complete!'
