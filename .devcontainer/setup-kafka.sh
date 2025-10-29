#!/bin/bash
set -e

echo "=========================================="
echo "Setting up Kafka (Native in Codespace)"
echo "=========================================="

# Configuration
KAFKA_VERSION="4.1.0"
KAFKA_SCALA_VERSION="2.13"
KAFKA_HOME="/opt/kafka"
KAFKA_DATA_DIR="/workspaces/kafka-quickstart/kafka-data"

# Download and install Kafka
echo "📥 Downloading Kafka ${KAFKA_VERSION} (latest stable)..."
cd /tmp
wget -q --show-progress --retry-connrefused --waitretry=1 -t 3 \
    "https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz"

echo "📦 Installing Kafka to ${KAFKA_HOME}..."
sudo tar -xzf "kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz" -C /opt/
sudo mv "/opt/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}" "${KAFKA_HOME}"
sudo chown -R vscode:vscode "${KAFKA_HOME}"
rm -f "kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz"

# Create symbolic links
echo "🔗 Creating command shortcuts..."
sudo ln -sf ${KAFKA_HOME}/bin/*.sh /usr/local/bin/

# Create data directory
echo "📁 Creating data directory..."
mkdir -p "${KAFKA_DATA_DIR}/kraft-combined-logs"

# Configure Kafka for KRaft mode
echo "⚙️ Configuring Kafka (KRaft mode)..."
# Kafka 4.1.0 comes with a KRaft-ready server.properties - we just need to modify it
if [ -f "${KAFKA_HOME}/config/server.properties" ]; then
    echo "Using existing server.properties template"
    # Backup original
    cp ${KAFKA_HOME}/config/server.properties ${KAFKA_HOME}/config/server.properties.original
    
    # Modify the config for our setup
    sed -i 's/^#node.id=/node.id=1/' ${KAFKA_HOME}/config/server.properties
    sed -i 's/^#controller.quorum.voters=/controller.quorum.voters=1@localhost:9093/' ${KAFKA_HOME}/config/server.properties
    sed -i "s|^log.dirs=.*|log.dirs=${KAFKA_DATA_DIR}|g" ${KAFKA_HOME}/config/server.properties
    
    # Uncomment and set listeners if needed
    sed -i 's/^#listeners=PLAINTEXT:\/\/:9092,CONTROLLER:\/\/:9093/listeners=PLAINTEXT:\/\/localhost:9092,CONTROLLER:\/\/localhost:9093/' ${KAFKA_HOME}/config/server.properties
    sed -i 's/^#advertised.listeners=PLAINTEXT:\/\/localhost:9092/advertised.listeners=PLAINTEXT:\/\/localhost:9092/' ${KAFKA_HOME}/config/server.properties
else
    echo "Creating new server.properties"
    cat > ${KAFKA_HOME}/config/server.properties << EOF
# KRaft Mode Configuration
process.roles=broker,controller
node.id=1
controller.quorum.voters=1@localhost:9093
listeners=PLAINTEXT://localhost:9092,CONTROLLER://localhost:9093
advertised.listeners=PLAINTEXT://localhost:9092
controller.listener.names=CONTROLLER
inter.broker.listener.name=PLAINTEXT
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
log.dirs=${KAFKA_DATA_DIR}
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
EOF
fi

# Generate Cluster ID and format storage
echo "🔑 Initializing Kafka storage..."
KAFKA_CLUSTER_ID="$(${KAFKA_HOME}/bin/kafka-storage.sh random-uuid)"
echo "Cluster ID: ${KAFKA_CLUSTER_ID}"
${KAFKA_HOME}/bin/kafka-storage.sh format -t ${KAFKA_CLUSTER_ID} -c ${KAFKA_HOME}/config/server.properties

# Create service management script
echo "📝 Creating service management script..."
cat > /tmp/kafka-service << 'EOF'
#!/bin/bash

KAFKA_HOME="/opt/kafka"
KAFKA_PID_FILE="/tmp/kafka.pid"
KAFKA_LOG_FILE="/tmp/kafka.log"

case "$1" in
  start)
    if [ -f "$KAFKA_PID_FILE" ] && kill -0 $(cat "$KAFKA_PID_FILE") 2>/dev/null; then
      echo "✅ Kafka is already running (PID: $(cat $KAFKA_PID_FILE))"
    else
      echo "Starting Kafka..."
      nohup ${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server.properties > ${KAFKA_LOG_FILE} 2>&1 &
      echo $! > "$KAFKA_PID_FILE"
      sleep 3
      if kill -0 $(cat "$KAFKA_PID_FILE") 2>/dev/null; then
        echo "✅ Kafka started (PID: $(cat $KAFKA_PID_FILE))"
      else
        echo "❌ Failed to start Kafka. Check ${KAFKA_LOG_FILE}"
        rm -f "$KAFKA_PID_FILE"
        exit 1
      fi
    fi
    ;;
  stop)
    if [ -f "$KAFKA_PID_FILE" ]; then
      echo "Stopping Kafka..."
      kill $(cat "$KAFKA_PID_FILE") 2>/dev/null
      rm -f "$KAFKA_PID_FILE"
      echo "✅ Kafka stopped"
    else
      echo "Kafka is not running"
    fi
    ;;
  status)
    if [ -f "$KAFKA_PID_FILE" ] && kill -0 $(cat "$KAFKA_PID_FILE") 2>/dev/null; then
      echo "✅ Kafka is running (PID: $(cat $KAFKA_PID_FILE))"
    else
      echo "❌ Kafka is not running"
    fi
    ;;
  restart)
    $0 stop
    sleep 2
    $0 start
    ;;
  logs)
    if [ -f "$KAFKA_LOG_FILE" ]; then
      tail -f "$KAFKA_LOG_FILE"
    else
      echo "No log file found"
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|logs}"
    exit 1
    ;;
esac
EOF

sudo mv /tmp/kafka-service /usr/local/bin/kafka-service
sudo chmod +x /usr/local/bin/kafka-service

# Setup aliases
echo "✏️ Configuring shell aliases..."
cat >> ~/.bashrc << 'EOF'

# Kafka Aliases
alias kafka-start='kafka-service start'
alias kafka-stop='kafka-service stop'
alias kafka-status='kafka-service status'
alias kafka-logs='kafka-service logs'
alias kafka-topics='kafka-topics.sh --bootstrap-server localhost:9092'
alias kafka-console-producer='kafka-console-producer.sh --bootstrap-server localhost:9092'
alias kafka-console-consumer='kafka-console-consumer.sh --bootstrap-server localhost:9092'

# Kafka test function
kafka-test() {
  echo "🧪 Running Kafka test..."
  kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test --partitions 1 2>/dev/null || true
  echo "Test message: $(date)" | kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test
  timeout 3 kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning --max-messages 1
  echo "✅ Test complete!"
}
EOF

echo "✅ Kafka installation complete!"