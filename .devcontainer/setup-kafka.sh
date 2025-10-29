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

# Add Kafka to PATH and create aliases (for both bash and zsh)
for rcfile in ~/.bashrc ~/.zshrc; do
  if [ -f "$rcfile" ]; then
    echo "" >> $rcfile
    echo "# Kafka Configuration" >> $rcfile
    echo 'export KAFKA_HOME=/opt/kafka' >> $rcfile
    echo 'export PATH="$KAFKA_HOME/bin:$PATH"' >> $rcfile
    echo "" >> $rcfile
    echo "# Kafka Shortcuts" >> $rcfile
    echo "alias kt='kafka-topics.sh --bootstrap-server localhost:9092'" >> $rcfile
    echo "alias kp='kafka-console-producer.sh --bootstrap-server localhost:9092'" >> $rcfile
    echo "alias kc='kafka-console-consumer.sh --bootstrap-server localhost:9092'" >> $rcfile
    echo "alias kafka-start='nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > /tmp/kafka.log 2>&1 &'" >> $rcfile
    echo "alias kafka-log='tail -f /tmp/kafka.log'" >> $rcfile
  fi
done

echo "📝 Kafka commands are now in PATH."
echo "🚀 Quick commands: kt (topics), kp (producer), kc (consumer), kafka-start, kafka-log"