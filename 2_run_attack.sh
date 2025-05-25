#!/bin/sh

readonly DIR="$(realpath $(dirname "$0"))"
readonly DOCKER_DIR=/rp2350-challenge

cd ${DIR} && docker run -it --privileged -v /dev:/dev -v .:/${DOCKER_DIR} rp2350-challenge-attack-poc:latest bash -c "${DOCKER_DIR}/res/run_attack.sh"