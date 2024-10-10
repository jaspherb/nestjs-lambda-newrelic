#!/bin/bash

# Variables
AWS_ENDPOINT="http://localhost:4566"
QUEUE_NAME="email-queue"
FUNCTION_NAME="emailProcessor"
LAMBDA_ROLE="arn:aws:iam::000000000000:role/lambda-ex"
EMAIL_ADDRESS="your-email@example.com"

# Function to delete existing resources
reset_localstack() {
  echo "Resetting LocalStack setup..."

  # Delete Lambda function if it exists
  if awslocal lambda list-functions | grep $FUNCTION_NAME; then
    echo "Deleting Lambda function..."
    awslocal lambda delete-function --function-name $FUNCTION_NAME
  fi

  # Delete SQS Queue if it exists
  QUEUE_URL=$(awslocal sqs list-queues | jq -r '.QueueUrls[]' | grep $QUEUE_NAME)
  if [ ! -z "$QUEUE_URL" ]; then
    echo "Purging SQS Queue..."
    awslocal sqs purge-queue --queue-url $QUEUE_URL

    echo "Deleting SQS Queue..."
    awslocal sqs delete-queue --queue-url $QUEUE_URL
  fi

  # Delete existing event source mapping if it exists
  EVENT_SOURCE_MAPPINGS=$(awslocal lambda list-event-source-mappings --function-name $FUNCTION_NAME --event-source-arn arn:aws:sqs:ap-northeast-1:000000000000:$QUEUE_NAME | jq -r '.EventSourceMappings[] | select(.EventSourceArn == "arn:aws:sqs:ap-northeast-1:000000000000:'$QUEUE_NAME'") | .UUID')
  for UUID in $EVENT_SOURCE_MAPPINGS; do
    echo "Deleting existing event source mapping with UUID $UUID..."
    awslocal lambda delete-event-source-mapping --uuid $UUID
  done

  # Verify email identity status
  VERIFIED_EMAIL=$(awslocal ses list-identities | jq -r '.Identities[]' | grep $EMAIL_ADDRESS)
  if [ ! -z "$VERIFIED_EMAIL" ]; then
    echo "Deleting SES email verification..."
    awslocal ses delete-identity --identity $EMAIL_ADDRESS
  fi

  echo "Reset complete."
}

# Reset LocalStack setup
reset_localstack

# Create SQS Queue
echo "Creating SQS Queue..."
awslocal sqs create-queue --queue-name $QUEUE_NAME

# Create Lambda Function
echo "Creating Lambda Function..."
zip function.zip lambda/index.js

awslocal lambda create-function \
  --function-name $FUNCTION_NAME \
  --zip-file fileb://function.zip \
  --handler index.handler \
  --runtime nodejs14.x \
  --role $LAMBDA_ROLE

# Set up SQS trigger for Lambda
echo "Setting up SQS trigger for Lambda..."
awslocal lambda create-event-source-mapping \
  --function-name $FUNCTION_NAME \
  --event-source-arn arn:aws:sqs:ap-northeast-1:000000000000:$QUEUE_NAME \
  --batch-size 10

# Verify email in SES
echo "Verifying email in SES..."
awslocal ses verify-email-identity --email-address $EMAIL_ADDRESS

# Check SES verification status
echo "Checking SES email verification status..."
STATUS=$(awslocal ses get-identity-verification-attributes --identities $EMAIL_ADDRESS | jq -r --arg email "$EMAIL_ADDRESS" '.VerificationAttributes[$email].VerificationStatus')

if [ "$STATUS" == "Pending" ]; then
  echo "Email verification is pending. Please check your email to complete the verification process."
elif [ "$STATUS" == "Success" ]; then
  echo "Email verification successful."
else
  echo "Email verification failed or not found."
fi

echo "Setup complete."
