#!/usr/bin/env sh

# remove leftover server pid file before startup
rm -f /app/tmp/pids/server.pid

exec $@
