#!/bin/bash
SWAPIOS=0
for PARTITIONPATH in $(/sbin/swapon -s | tail -n +2 | cut -d ' ' -f 1 ); do
  PARTITION=$(basename $PARTITIONPATH)
  if [ -L /dev/mapper/$PARTITION ]; then
    PARTITION=$(readlink -sf /dev/mapper/$PARTITION)
    PARTITION=$(basename $PARTITION)
  fi
  IOREAD=$(cat /proc/diskstats | grep "$PARTITION" | head -1 | awk '{print $4}')
  IOWRITE=$(cat /proc/diskstats | grep "$PARTITION" | head -1 | awk '{print $8}')
  SWAPIOS=$((( $SWAPIOS + $IOREAD )))
  SWAPIOS=$((( $SWAPIOS + $IOWRITE )))
done
echo "$SWAPIOS"

