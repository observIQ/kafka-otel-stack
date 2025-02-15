#!/usr/bin//env bash

set -e

export AGENT_VERSION="1.70.0"
export OPAMP_ENDPOINT="wss://app.bindplane.com/v1/opamp"

# ensure OPAMP_SECRET_KEY is set
if [ -z "$OPAMP_SECRET_KEY" ]; then
    echo "OPAMP_SECRET_KEY is not set"
    exit 1
fi

docker compose up -d
