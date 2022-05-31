#!/bin/sh
PIDFILE='/tmp/unicorn.pid'
if [ -f "$PIDFILE" ]; then
  rm "$PIDFILE"
fi
cupsd
bin/rake jobs:work &
bin/rake faxomat:scheduler &
exec "$@"
