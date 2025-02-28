# kafka-otel-stack

## Prerequisites

- Linux host with Docker 27 or newer
- [Bindplane SaaS account](https://app.bindplane.com)
- [Bindplane CLI](https://bindplane.com/docs/advanced-setup/cli/installation)
- [Bindplane API key](https://bindplane.com/docs/advanced-setup/cli/api-keys)

This project assumes you are using Linux with Docker 27 or newer. It could be
adapted to support macOS with some changes around tmpfs volumes in [run.sh](run.sh).

Lastly, the collectors will be configured to connect to [Bindplane Cloud](https://app.bindplane.com).
If you are self hosting Bindplane, modify [run.sh](run.sh) to point to your instance.

Finally, [run.sh](run.sh) will use `sudo` for some commands. **Please review** the script before running.

## Usage

### 1. Bindplane

#### 1.1. CLI and Profile

Install the Bindplane CLI by following the documentation [here](https://bindplane.com/docs/advanced-setup/cli/installation).

Configure the CLI with an API key using the documentation [here](https://bindplane.com/docs/advanced-setup/cli/api-keys).

If you are self hosting Bindplane, take care when running the `profile set` commands.
Ensure the `remote-url` option is set to your Bindplane instance.

#### 1.2. Resources

Use the CLI to create your destination and configuration resources.

```bash
bindplane apply -f resources/destinations.yaml
bindplane apply -f resources/configurations.yaml
```

Configurations depend on destinations, therefore, apply destinations first.

Once deployed, you will have three configurations
- `kafka-broker-local`: Kafka Broker metrics
- `kafka-producer-local`: Load generations configuration
- `kafka-consumer-local`: Consumer for the kafka topic `logs`

Rollout the configurations so they are active when the first collectors connect.

```bash
bindplane rollout start kafka-broker-local
bindplane rollout start kafka-producer-local
bindplane rollout start kafka-consumer-local
```

### 2. Deploy

To start the stack, set your `OPAMP_SECRET_KEY`. You can find your secret key
on the agent install page, as part of the install command.

```bash
export OPAMP_SECRET_KEY=redacted
```

```bash
./run.sh
```

The script will do the following:
- Mount a tmpfs volume at `/mnt/tmpfs` for storing load generation logs. This is useful for preventing unnecessary wear and tear on your workstation's SSD.
- Start the stack with `docker compose up -d`.
- Configures the topic `logs` to have 8 partitions.

Once started, the following containers will be running:
- `kafka-otel-stack-consumer-1`: Bindplane agent consuming messages from the Kafka topic
- `kafka-otel-stack-producer-1`: Bindplane agent producing messages
- `kafka-otel-stack-agent-1`: Bindplane agent monitoring the Kafka broker
- `kafka-otel-stack-grafana-1`: Grafana for visualizing metrics, if you wish to interact with agent metrics
- `kafka-otel-stack-prometheus-1`: Prometheus for storing metrics, if you wish to interact with agent metrics
- `kafka-otel-stack-kafka-1`: The kafka broker
- `kafka-otel-stack-flog-1`: Load generation container writing logs to `/mnt/tmpfs`

Once the deployment is running, you can navigate to the consumer configuration in the Bindplane web interface. Use
[Live Preview](https://bindplane.com/docs/feature-guides/live-preview) to view before and after effects of configuration changes.
