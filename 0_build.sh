#!/bin/sh

readonly DIR="$(realpath $(dirname "$0"))"
readonly DOCKER_DIR=/rp2350-challenge
readonly PICO_SDK_PATH=${DOCKER_DIR}/deps/pico-sdk


setup_dependencies() { 
    git submodule update --init --recursive
    cd ${DIR}/deps/picotool && git apply ${DIR}/res/picotool.patch
    cd ${DIR}/deps/rp2350_hacking_challenge && git apply ${DIR}/res/rp2350_hacking_challenge.patch
    cd ${DIR}
}

setup_docker() {
    docker build -t rp2350-challenge-attack-poc:latest -f Dockerfile .
}

setup_openocd() {
    cd ${DIR} && docker run -v .:/${DOCKER_DIR} rp2350-challenge-attack-poc:latest \
        bash -c "cd ${DOCKER_DIR}/deps/openocd && git config --global --add safe.directory ${DOCKER_DIR}/deps/openocd  && ./bootstrap && ./configure && make -j8"
}

setup_picotool() {
    cd ${DIR} && docker run -v .:/${DOCKER_DIR} rp2350-challenge-attack-poc:latest \
        bash -c "cd ${DOCKER_DIR}/deps/picotool && \
            mkdir build && \
            cd build \
            && PICO_SDK_PATH=${PICO_SDK_PATH} cmake .. \
            && make -j8"
}

setup_target_fw(){
    cd ${DIR} && docker run -v .:/${DOCKER_DIR} rp2350-challenge-attack-poc:latest \
        bash -c "cd ${DOCKER_DIR}/firmware && \
            mkdir build && \
            cd build \
            && PICO_SDK_PATH=${PICO_SDK_PATH} cmake -DPICO_PLATFORM=rp2350 -DPICO_BOARD=pico2 .. \
            && make -j8"
}

setup_dependencies
setup_docker
setup_openocd
setup_picotool
setup_target_fw