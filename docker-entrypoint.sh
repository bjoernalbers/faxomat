#!/bin/sh
PIDFILE='/tmp/unicorn.pid'
if [ -f "$PIDFILE" ]; then
  rm "$PIDFILE"
fi
cupsd
exec "$@"
