#!/bin/bash
# Script to check what's listening on a specific port
# Usage: ./check_port.sh [port_number]

PORT=${1:-3000} # Default to port 3000 if no argument provided

echo "Checking what's listening on port $PORT..."
echo ""

# Method 1: Using lsof (most detailed)
if command -v lsof &>/dev/null; then
  echo "=== Using lsof ==="
  sudo lsof -i :$PORT -P -n
  echo ""
fi

# Method 2: Using netstat
if command -v netstat &>/dev/null; then
  echo "=== Using netstat ==="
  sudo netstat -tulpn | grep ":$PORT "
  echo ""
fi

# Method 3: Using ss (modern replacement for netstat)
if command -v ss &>/dev/null; then
  echo "=== Using ss ==="
  sudo ss -tulpn | grep ":$PORT "
  echo ""
fi

# Method 4: Using fuser
if command -v fuser &>/dev/null; then
  echo "=== Using fuser ==="
  sudo fuser $PORT/tcp 2>/dev/null
  if [ $? -eq 0 ]; then
    PID=$(sudo fuser $PORT/tcp 2>/dev/null | awk '{print $1}')
    echo "Process ID: $PID"
    ps -p $PID -o pid,ppid,cmd
  else
    echo "No process found on port $PORT"
  fi
  echo ""
fi

# Summary with kill option
echo "=== Quick Summary ==="
PIDS=$(sudo lsof -t -i:$PORT 2>/dev/null)
if [ -n "$PIDS" ]; then
  echo "Process(es) found on port $PORT:"
  for pid in $PIDS; do
    ps -p $pid -o pid,user,cmd --no-headers
  done
  echo ""
  echo "To kill these processes, run:"
  echo "  sudo kill $PIDS"
  echo "Or force kill:"
  echo "  sudo kill -9 $PIDS"
else
  echo "No process is listening on port $PORT"
fi
