#!/usr/bin/env sh

if [ -z "$LOG_LEVEL" ]; then
  LOG_ARG=""
else
  LOG_ARG="--log $LOG_LEVEL"
fi

./Run $@ $LOG_ARG
