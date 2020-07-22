#!/usr/bin/env bash

# Create temp apt sources for install clang and related utills
sudo cat <<< '
deb http://deb.debian.org/debian buster main
deb-src http://deb.debian.org/debian buster main ' > /etc/apt/sources.list.d/mysource.list

# Check that XDP is enabled in the kernel
# sudo cat /boot/config-4.19.131-amd64-vyos | grep -i xdp

sudo apt update
sudo apt install -y clang elfutils libelf-dev libmnl-dev bison flex pkg-config libc6-dev-i386
sudo rm -f /etc/apt/sources.list.d/mysource.list

export CPATH=/usr/include/x86_64-linux-gnu

# Compile C to eBPF object
clang -target bpf -O2 -c xdp-drop-ebpf.c -o xdp-drop-ebpf.o

# Force (replace old xdp) load XDP to net device
sudo ip -force link set dev eth0 xdpdrv obj xdp-drop-ebpf.o

# Check
sudo ip link show dev eth0

# Unset xdp
# ip link set dev eth0 xdp off

# Additional tools for monitoring
# wget https://raw.githubusercontent.com/Netronome/nfp-drv-kmods/master/tools/stat_watch.py
# ./stat_watch -c eth0

