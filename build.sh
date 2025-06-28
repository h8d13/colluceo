#!/bin/bash

# build.sh - Enhanced build script with proper organization

echo "Building Simple OS..."

# Create directories if they don't exist
mkdir -p out

# Clean previous builds
rm -f out/*.bin out/*.img

# Assemble bootloader
echo "Assembling bootloader..."
nasm -f bin src/boot.asm -o out/boot.bin
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to assemble bootloader"
    exit 1
fi

# Assemble kernel
echo "Assembling kernel..."
nasm -f bin src/kernel.asm -o out/kernel.bin
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to assemble kernel"
    exit 1
fi

# Check file sizes
boot_size=$(stat -c%s out/boot.bin 2>/dev/null || stat -f%z out/boot.bin)
kernel_size=$(stat -c%s out/kernel.bin 2>/dev/null || stat -f%z out/kernel.bin)

echo "Boot sector size: $boot_size bytes (should be 512)"
echo "Kernel size: $kernel_size bytes"

if [ $boot_size -ne 512 ]; then
    echo "WARNING: Boot sector is not exactly 512 bytes!"
fi

# Create disk image (1.44MB floppy)
echo "Creating disk image..."
dd if=/dev/zero of=out/simple_os.img bs=512 count=2880 2>/dev/null

# Write bootloader to first sector
echo "Writing bootloader to sector 1..."
dd if=out/boot.bin of=out/simple_os.img bs=512 count=1 conv=notrunc 2>/dev/null

# Write kernel to second sector
echo "Writing kernel to sector 2..."
dd if=out/kernel.bin of=out/simple_os.img bs=512 count=1 seek=1 conv=notrunc 2>/dev/null

# Verify the image
echo ""
echo "Verifying disk image..."
echo "Boot signature (should end with 55 AA):"
xxd -l 16 -s 510 out/simple_os.img

echo ""
echo "First 32 bytes of sector 2 (kernel):"
xxd -l 32 -s 512 out/simple_os.img

echo ""
echo "Build complete!"
echo "Files created:"
echo "  out/boot.bin     - Boot sector"
echo "  out/kernel.bin   - Kernel"
echo "  out/simple_os.img - Bootable disk image"
echo ""
echo "To run: qemu-system-x86_64 -drive format=raw,file=out/simple_os.img
"
