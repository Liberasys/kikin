#!/bin/bash
NBTHREADS=0
for PROCESSPID in $(ls -1 /proc | grep -E "^[0-9][0-9]+$"); do
  NBTHREADS=$((( $NBTHREADS + $(2>/dev/null ls -1 /proc/$PROCESSPID/task/ | wc -l) )))
done
echo "$NBTHREADS"


