#!/bin/bash

# Stop on error
set -e

if [ -v AWS_LAMBDA_RUNTIME_API ]; then
    # Executing in Lambda, indicate the start of invocation and save the Lambda request ID
    # -s hides progress bar
    # -w '%header{Lambda-Runtime-Aws-Request-Id}' prints to stdout the value of the header that Lambda uses to pass request ID
    # -o /dev/null sends response contents to /dev/null
    LAMBDA_REQUEST_ID=$(curl -s -o /dev/null -w '%header{Lambda-Runtime-Aws-Request-Id}' "http://$AWS_LAMBDA_RUNTIME_API/2018-06-01/runtime/invocation/next")
    echo "Executing as Lambda, request ID: $LAMBDA_REQUEST_ID"
fi

# run passed commands
"$@"

if [ -v AWS_LAMBDA_RUNTIME_API ]; then
    # Executing in Lambda, indicate the execution was successful
    RESULT="\{\"result\": \"SUCCESS\", \"report_location\": \"$S3_DEST\"\}"
    curl -s -o /dev/null "http://$AWS_LAMBDA_RUNTIME_API/2018-06-01/runtime/invocation/$LAMBDA_REQUEST_ID/response"  -d "$RESULT"
fi