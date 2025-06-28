#!/bin/bash

# run.sh - Quick run script

if [ ! -f out/simple_os.img ]; then
    echo "Image not found. Building first..."
    ./build.sh
fi

echo "Starting Simple OS in QEMU..."
qemu-system-x86_64 -drive format=raw,file=out/simple_os.img
echo "Exit SimpleOS..."
