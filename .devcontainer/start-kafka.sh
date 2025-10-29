#!/bin/bash

echo "🚀 Starting Kafka..."

# Start Kafka if not already running
if [ -f "/tmp/kafka.pid" ] && kill -0 $(cat "/tmp/kafka.pid") 2>/dev/null; then
    echo "✅ Kafka is already running (PID: $(cat /tmp/kafka.pid))"
else
    kafka-service start
fi

# Wait for Kafka to be ready
echo "⏳ Waiting for Kafka to be ready..."
MAX_ATTEMPTS=30
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    if kafka-broker-api-versions.sh --bootstrap-server localhost:9092 >/dev/null 2>&1; then
        echo "✅ Kafka is ready!"
        
        # Show helpful information
        echo ""
        echo "=========================================="
        echo "   Kafka Development Environment Ready"
        echo "=========================================="
        echo "  Bootstrap Server: localhost:9092"
        echo "  Mode: KRaft (no Zookeeper)"
        echo "  Logs: kafka-logs or tail -f /tmp/kafka.log"
        echo ""
        echo "  Quick commands:"
        echo "    kafka-topics --list"
        echo "    kafka-test"
        echo "=========================================="
        exit 0
    fi
    
    echo "  Attempt $ATTEMPT/$MAX_ATTEMPTS..."
    sleep 1
    ATTEMPT=$((ATTEMPT + 1))
done

echo "⚠️ Kafka failed to start. Check logs: kafka-logs"
exit 1