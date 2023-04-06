#!/bin/bash

# Configuration
TOMCAT_NAME="tomcat"
MAX_CPU=75.0 # Maximum allowed CPU usage (as a percentage)
MAX_MEM=75.0 # Maximum allowed memory usage (as a percentage)
MAX_CONNECTIONS=500 # Maximum allowed number of connections

# Check if Tomcat is running
if ! pgrep -f "$TOMCAT_NAME" > /dev/null; then
  echo "Tomcat is not running. Starting Tomcat server..."
  sudo systemctl start $TOMCAT_NAME
fi

# Get the current CPU usage (in percentage)
CPU_USAGE=$(ps -o %cpu= -p $(pgrep -f "$TOMCAT_NAME") | awk '{ sum += $1 } END { print sum }')

# Check if the CPU usage is too high
if (( $(echo "$CPU_USAGE > $MAX_CPU" | bc -l) )); then
  echo "CPU usage is too high ($CPU_USAGE %). Restarting Tomcat server..."
  sudo systemctl restart $TOMCAT_NAME
fi

# Get the current memory usage (in percentage)
MEM_USAGE=$(free | awk '/Mem/{printf("%.2f"), $3/$2*100}')

# Check if the memory usage is too high
if (( $(echo "$MEM_USAGE > $MAX_MEM" | bc -l) )); then
  echo "Memory usage is too high ($MEM_USAGE %). Restarting Tomcat server..."
  sudo systemctl restart $TOMCAT_NAME
fi

# Get the current number of connections
CONNECTIONS=$(netstat -anp | grep $TOMCAT_NAME | grep ESTABLISHED | wc -l)

# Check if the number of connections is too high
if (( $CONNECTIONS > $MAX_CONNECTIONS )); then
  echo "Number of connections is too high ($CONNECTIONS). Restarting Tomcat server..."
  sudo systemctl restart $TOMCAT_NAME
fi
