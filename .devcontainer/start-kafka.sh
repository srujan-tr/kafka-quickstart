#!/bin/bash

# Simple startup script
echo "🚀 Starting Kafka..."

# Check if already running
if pgrep -f "kafka.Kafka" > /dev/null; then
    echo "✅ Kafka is already running"
else
    # Start Kafka
    nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /tmp/kafka.log 2>&1 &
    echo "⏳ Waiting for Kafka to start..."
    
    # Wait for Kafka to be ready (max 30 seconds)
    for i in {1..30}; do
        if kafka-broker-api-versions.sh --bootstrap-server localhost:9092 >/dev/null 2>&1; then
            echo "✅ Kafka is ready on localhost:9092!"
            echo "📝 Quick test: kafka-topics.sh --list --bootstrap-server localhost:9092"
            exit 0
        fi
        sleep 1
    done
    
    echo "⚠️ Kafka may still be starting. Check logs: tail -f /tmp/kafka.log"
fi