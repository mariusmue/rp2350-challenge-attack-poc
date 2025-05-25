FROM ubuntu:24.04 AS base

RUN apt update && apt install -y build-essential \
    autoconf \
    automake \
    cmake \
    gcc-arm-none-eabi \
    git \
    gdb-multiarch \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib \
    libtool \
    libusb-1.0-0-dev \
    openocd \
    picocom \
    pkg-config \
    python3 \
    texinfo \
    tmux