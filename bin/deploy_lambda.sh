#!/bin/bash
aws lambda update-function-code  --function-name ac_control_lambda  --zip-file fileb://lambda_function_payload.zip --region eu-west-1