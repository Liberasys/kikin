#!/bin/bash

SHMEMMAX=0
SHMEMMAXP=$(cat /proc/sys/kernel/shmall | cut -d " " -f 3)
if [ "$SHMEMMAXP" == 18446744073692774399 ]; then
  SHMEMMAX="18446744073692774399"
else
  MEMPAGESIZE=$(getconf PAGE_SIZE)
  SHMEMMAX=$(( $SHMEMMAXP * $MEMPAGESIZE ))
fi
echo "$SHMEMMAX"
