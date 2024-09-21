#!/bin/bash

# Threshold: Terminate instances with < 5% CPU usage over the last hour
CPU_THRESHOLD=5
REGION="us-east-1"  # Specify your AWS region

# Get all running EC2 instances
instances=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text --region $REGION)

for instance in $instances; do
    # Get average CPU utilization for the last hour
    cpu_utilization=$(aws cloudwatch get-metric-statistics \
        --metric-name CPUUtilization \
        --start-time $(date -u -d '1 hour ago' +"%Y-%m-%dT%H:%M:%SZ") \
        --end-time $(date -u +"%Y-%m-%dT%H:%M:%SZ") \
        --period 3600 --namespace AWS/EC2 \
        --statistics Average --dimensions Name=InstanceId,Value=$instance \
        --query "Datapoints[0].Average" --output text --region $REGION)

    # If CPU utilization is below the threshold, terminate the instance
    if [[ -n "$cpu_utilization" && $(echo "$cpu_utilization < $CPU_THRESHOLD" | bc -l) == 1 ]]; then
        echo "Terminating instance $instance with CPU utilization: $cpu_utilization%"
        aws ec2 terminate-instances --instance-ids $instance --region $REGION
    else
        echo "Instance $instance is active with CPU utilization: $cpu_utilization%"
    fi
done

