#!/usr/bin//env bash

set -e

export AGENT_VERSION="1.70.0"
export OPAMP_ENDPOINT="wss://app.bindplane.com/v1/opamp"

# ensure OPAMP_SECRET_KEY is set
if [ -z "$OPAMP_SECRET_KEY" ]; then
    echo "OPAMP_SECRET_KEY is not set"
    exit 1
fi

if grep -qs '/mnt/tmpfs ' /proc/mounts; then
    echo "/mnt/tmpfs is already a tmpfs mount"
else
    sudo mkdir -p /mnt/tmpfs
    sudo mount -t tmpfs -o size=2G tmpfs /mnt/tmpfs
fi

docker compose up -d
docker exec -it kafka-otel-stack-kafka-1 kafka-topics.sh \
    --alter \
    --topic logs \
    --partitions 8 \
    --bootstrap-server localhost:9092 || true
docker exec -it kafka-otel-stack-kafka-1 kafka-topics.sh \
    --describe \
    --topic logs \
    --bootstrap-server localhost:9092 || true
docker exec -it kafka-otel-stack-kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server localhost:9092 --group otel-collector --describe || true
