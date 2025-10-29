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

# Minimal configuration - just uncomment 2 required fields!
echo "⚙️ Configuring Kafka..."
cd ${KAFKA_HOME}
sed -i 's/^#node.id=/node.id=1/' config/server.properties
sed -i 's/^#controller.quorum.voters=/controller.quorum.voters=1@localhost:9093/' config/server.properties

# Initialize storage
echo "🔑 Initializing storage..."
CLUSTER_ID=$(bin/kafka-storage.sh random-uuid)
echo "Cluster ID: $CLUSTER_ID"
bin/kafka-storage.sh format -t $CLUSTER_ID -c config/server.properties

echo "✅ Setup complete! Use 'kafka-start' to start Kafka"

# Create simple helper script
cat > /usr/local/bin/kafka-start << 'EOF'
#!/bin/bash
echo "Starting Kafka..."
nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /tmp/kafka.log 2>&1 &
echo "Kafka started! PID: $!"
echo "Logs: tail -f /tmp/kafka.log"
EOF
chmod +x /usr/local/bin/kafka-start