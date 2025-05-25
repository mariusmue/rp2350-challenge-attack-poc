#!/bin/bash

readonly DIR="$(realpath $(dirname "$0"))"
readonly DOCKER_DIR=/rp2350-challenge
readonly PICO_SDK_PATH=${DOCKER_DIR}/deps/pico-sdk

echo "[!] IMPORTANT: This script will setup the hardware for the RP2350 Hacking Challenge"
echo "[!] This includes irreversible changes to the hardware, such as writing to OTP and permamently enabling secure boot."
echo "[!] Please continue only if you are fine with this."
echo "[!] Also, please make sure that your target rp2350 is connected in BOOTSEL mode to the computer."
echo ""

read -p "[?] Continue? (y/n) " yn
if [[ "${yn}" != "y" ]]; then
    echo "[-] Exiting"
    exit 0
fi



cd ${DIR} && docker run -v .:/${DOCKER_DIR} rp2350-challenge-attack-poc:latest \
    bash -c "cd ${DOCKER_DIR}/deps/rp2350_hacking_challenge && \
        mkdir build && \
        cd build \
        && PICO_SDK_PATH=${PICO_SDK_PATH} cmake -DPICO_PLATFORM=rp2350 -DPICO_BOARD=pico2 .. \
        && make -j8"

cd ${DIR} && docker run --privileged -it -v .:/${DOCKER_DIR} rp2350-challenge-attack-poc:latest \
    bash -c "export PATH=$PATH:${DOCKER_DIR}/deps/picotool/build && \
    cd ${DOCKER_DIR}/deps/rp2350_hacking_challenge && \
    ./write_otp_secret.sh && \
    ./lock_chip.sh && \
    ./enable_secureboot.sh && \
    picotool load ./build/rp2350_hacking_challenge_secure_version.elf && \
    picotool reboot"