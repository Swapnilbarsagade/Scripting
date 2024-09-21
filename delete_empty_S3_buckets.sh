#!/bin/bash

REGION="us-east-1"  # Specify your AWS region
DAYS_THRESHOLD=30  # Number of days since the last modification

# List all S3 buckets
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

for bucket in $buckets; do
    # Get the last modified date of the most recently added or modified object
    last_modified=$(aws s3api list-objects --bucket $bucket \
        --query "Contents[?LastModified >= \`$(date -d "$DAYS_THRESHOLD days ago" +%Y-%m-%dT%H:%M:%SZ)\`]" \
        --output text --region $REGION)

    # If the bucket has no objects or no recent modifications, delete it
    if [ -z "$last_modified" ]; then
        echo "Deleting stale/empty bucket: $bucket"
        aws s3 rb s3://$bucket --force
    else
        echo "Bucket $bucket is in use."
    fi
done

