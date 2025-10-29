# Kafka Development Environment

A streamlined Kafka development environment for GitHub Codespaces that runs Kafka natively (without Docker-in-Docker complexity).

## 🚀 Quick Start

1. **Open in GitHub Codespaces**
   - Click the green "Code" button on GitHub
   - Select "Codespaces" tab
   - Click "Create codespace on main"

2. **Wait for Setup** (3-5 minutes)
   - Codespace will automatically:
     - Install Java 17
     - Download and configure Kafka 4.1.0 (latest)
     - Start Kafka in KRaft mode (no Zookeeper)
     - Configure helpful aliases

3. **Verify Kafka is Running**
   ```bash
   kafka-service status
   ```

## 📋 Available Commands

### Service Management
```bash
kafka-service start    # Start Kafka
kafka-service stop     # Stop Kafka
kafka-service status   # Check if Kafka is running
kafka-service restart  # Restart Kafka
kafka-service logs     # View Kafka logs
```

### Kafka Operations (Shortcuts)
```bash
# Topic management
kafka-topics --list
kafka-topics --create --topic my-topic --partitions 3
kafka-topics --describe --topic my-topic
kafka-topics --delete --topic my-topic

# Producer (send messages)
kafka-console-producer --topic my-topic

# Consumer (read messages)
kafka-console-consumer --topic my-topic --from-beginning
```

### Quick Test
```bash
kafka-test  # Runs a quick test by creating a topic and sending/receiving a message
```

## 🏗️ Architecture

This setup runs Kafka **natively in the Codespace container** rather than using Docker-in-Docker:

- **Simpler**: No nested container complexity
- **Faster**: Direct execution without container overhead
- **More Reliable**: Avoids Docker networking issues
- **Resource Efficient**: Single container environment

### Technical Details

- **Kafka Version**: 4.1.0 (latest stable)
- **Mode**: KRaft (no Zookeeper required)
- **Java**: OpenJDK 17
- **Port**: 9092 (auto-forwarded)
- **Data Directory**: `/workspace/kafka-data`
- **Logs**: `/tmp/kafka.log`

## 📁 Project Structure

```
kafka-quickstart/
├── .devcontainer/
│   ├── devcontainer.json    # Codespace configuration
│   ├── setup-kafka.sh       # Installation script
│   └── start-kafka.sh       # Startup script
└── README.md
```

## 💡 Examples

### Create a Topic and Send Messages
```bash
# Create a topic
kafka-topics --create --topic events --partitions 3

# Send some messages
kafka-console-producer --topic events
> Hello Kafka!
> This is a test message
> ^C to exit

# Read messages
kafka-console-consumer --topic events --from-beginning
```

### Check Cluster Health
```bash
# List all topics
kafka-topics --list

# Check broker status
kafka-broker-api-versions.sh --bootstrap-server localhost:9092

# View logs
kafka-service logs
```

## 🔧 Troubleshooting

### Kafka Not Starting?
```bash
# Check the logs
cat /tmp/kafka.log

# Try manual start
/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
```

### Port 9092 Not Accessible?
- Check the "Ports" tab in VS Code
- Ensure port 9092 is listed and forwarded
- Try `localhost:9092` or use the Codespace URL

### Reset Kafka Data
```bash
# Stop Kafka
kafka-service stop

# Clear data
rm -rf /workspace/kafka-data/*

# Reinitialize and start
bash .devcontainer/setup-kafka.sh
kafka-service start
```

## 📚 Resources

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Kafka Quickstart Guide](https://kafka.apache.org/quickstart)
- [KRaft Mode Documentation](https://kafka.apache.org/documentation/#kraft)
- [GitHub Codespaces](https://docs.github.com/en/codespaces)

## 🎯 Why Native Kafka?

Traditional Docker-in-Docker setups in Codespaces can be problematic:
- DNS resolution issues
- Complex networking
- Resource overhead
- Build failures

This native approach:
- ✅ Starts faster
- ✅ Uses less resources  
- ✅ More reliable
- ✅ Easier to debug
- ✅ Direct access to Kafka processes