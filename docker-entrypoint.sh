#!/bin/bash
set -e
socat UNIX-RECV:/dev/log,mode=666 STDOUT &
/usr/bin/goferd
exec "$@"
