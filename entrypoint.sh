#!/bin/bash

# Run the server in background so this script can act as a sentinel asynchronously
java -Xmx1024M -Xms1024M -jar server.jar nogui &
# ie PID = server pid
PID=$!

# catch docker's interrupt signal and sends a terminate signal to java
trap "kill -SIGINT $PID" SIGTERM

# Keeping this script open keeps the container open, so we don't exit until the server
# has successfully shut down.
wait $PID