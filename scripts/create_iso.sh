#!/bin/bash
set -eu
INPUT_ISO="$1"
OUTPUT_ISO="$2"
PRESEED="$3"
echo "INPUT_ISO: $INPUT_ISO"
echo "OUTPUT_ISO: $OUTPUT_ISO"
echo "PRESEED: $PRESEED"
docker rm -f debian_preseed || true
docker run -d --name debian_preseed debian_preseed sleep 3600
docker cp "$INPUT_ISO" debian_preseed:/input.iso
docker cp scripts/preseed.sh debian_preseed:/
docker cp cfg/auto.cfg debian_preseed:/auto.cfg
docker cp cfg/grub.cfg debian_preseed:/grub.cfg
docker cp "$PRESEED" debian_preseed:/preseed.cfg
docker exec -i debian_preseed bash preseed.sh
docker cp debian_preseed:/output.iso "$OUTPUT_ISO"
