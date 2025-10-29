# Kafka Quickstart

A simple Apache Kafka 4.1.0 setup using Docker Compose with KRaft mode (no Zookeeper required).

## Prerequisites

- Docker and Docker Compose installed

## GitHub Codespaces Support

This repository includes a `.devcontainer` configuration for GitHub Codespaces. When you open this repo in Codespaces, it will automatically:
- Set up a development environment with Docker-in-Docker
- Start Kafka automatically
- Forward port 9092 for Kafka access

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new)

## Quick Start

1. **Start Kafka:**
   ```bash
   docker-compose up -d
   ```

2. **Check if Kafka is running:**
   ```bash
   docker-compose ps
   ```

3. **Create a topic:**
   ```bash
   docker exec -it kafka kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test-topic --partitions 3 --replication-factor 1
   ```

4. **List topics:**
   ```bash
   docker exec -it kafka kafka-topics.sh --bootstrap-server localhost:9092 --list
   ```

5. **Produce messages:**
   ```bash
   docker exec -it kafka kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test-topic
   ```

6. **Consume messages:**
   ```bash
   docker exec -it kafka kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-topic --from-beginning
   ```

## Client Usage

Kafka supports clients in many programming languages. You can connect to the Kafka broker at `localhost:9092` using any Kafka client library:

- **Java**: Apache Kafka official client
- **Python**: kafka-python, confluent-kafka-python
- **Node.js**: kafkajs, node-rdkafka
- **Go**: confluent-kafka-go, sarama
- **Rust**: rdkafka
- **.NET**: Confluent.Kafka

All clients connect to the same bootstrap server: `localhost:9092`

## Stop Kafka

```bash
docker-compose down
```

To also remove the volumes (data):
```bash
docker-compose down -v
```

## Configuration

The Kafka broker is configured in KRaft mode (no Zookeeper) with the following settings:
- Bootstrap server: `localhost:9092`
- Single broker setup with controller
- Auto topic creation enabled
- Data persisted in Docker volume

## Kafka 4.1.0 Features

This setup uses Apache Kafka 4.1.0, which includes:
- KRaft mode (no Zookeeper dependency)
- Improved performance and simplified operations
- New queuing capabilities through share groups
- Enhanced streams rebalance protocol

For production environments, consider:
- Multiple brokers for high availability
- Proper replication factors
- Security configurations (SSL/SASL)
- Resource limits and JVM tuning