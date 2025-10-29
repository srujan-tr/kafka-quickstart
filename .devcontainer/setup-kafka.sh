#!/bin/bash
set -e

echo "🚀 Minimal Kafka Setup"

# Configuration
KAFKA_VERSION="4.1.0"
KAFKA_HOME="/opt/kafka"

# Download and install Kafka
echo "📥 Downloading Kafka ${KAFKA_VERSION}..."
cd /tmp
wget -q --show-progress https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz
sudo tar -xzf kafka_2.13-${KAFKA_VERSION}.tgz -C /opt/
sudo mv /opt/kafka_2.13-${KAFKA_VERSION} ${KAFKA_HOME}
sudo ln -sf ${KAFKA_HOME}/bin/*.sh /usr/local/bin/
rm kafka_2.13-${KAFKA_VERSION}.tgz

# Fix permissions after sudo installation
echo "⚙️ Setting permissions..."
cd ${KAFKA_HOME}
sudo chown -R $(whoami):$(whoami) ${KAFKA_HOME}

# Initialize storage with --standalone (no config changes needed!)
echo "🔑 Initializing storage..."
CLUSTER_ID=$(bin/kafka-storage.sh random-uuid)
echo "Cluster ID: $CLUSTER_ID"
bin/kafka-storage.sh format -t $CLUSTER_ID -c config/server.properties --standalone

echo "✅ Setup complete!"

# Add Kafka to PATH and create aliases
echo "" >> ~/.zshrc
echo "# Kafka Configuration" >> ~/.zshrc
echo 'export KAFKA_HOME=/opt/kafka' >> ~/.zshrc
echo 'export PATH="$KAFKA_HOME/bin:$PATH"' >> ~/.zshrc
echo "" >> ~/.zshrc
echo "# Kafka Shortcuts" >> ~/.zshrc
echo "alias kt='kafka-topics.sh --bootstrap-server localhost:9092'" >> ~/.zshrc
echo "alias kp='kafka-console-producer.sh --bootstrap-server localhost:9092'" >> ~/.zshrc
echo "alias kc='kafka-console-consumer.sh --bootstrap-server localhost:9092'" >> ~/.zshrc
echo "alias kafka-start='nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > /tmp/kafka.log 2>&1 &'" >> ~/.zshrc
echo "alias kafka-log='tail -f /tmp/kafka.log'" >> ~/.zshrc

source ~/.zshrc

echo "📝 Kafka commands are now in PATH."
echo "🚀 Quick commands: kt (topics), kp (producer), kc (consumer), kafka-start, kafka-log"