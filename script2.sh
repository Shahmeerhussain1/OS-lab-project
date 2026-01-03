#!/usr/bin/env bash
# QUICKS - Quick Unified Information & Control Kit
# Version: 1.0.0

# ─────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─────────────────────────────────────────────
# Global Settings
# ─────────────────────────────────────────────
readonly SCRIPT_NAME="QUICKS"
readonly SCRIPT_VERSION="1.0.0"
readonly DIVIDER="════════════════════════════════════════════════════════════"

clear

# ─────────────────────────────────────────────
# Header
# ─────────────────────────────────────────────
show_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "   ██████╗ ██╗   ██╗██╗ ██████╗ ██╗  ██╗███████╗  "
    echo "  ██╔═══██╗██║   ██║██║██╔════╝ ██║ ██╔╝██╔════╝ "
    echo "  ██║   ██║██║   ██║██║██║      █████╔╝ ███████╗"
    echo "  ██║▄▄ ██║██║   ██║██║██║      ██╔═██╗ ╚════██║"
    echo "  ╚██████╔╝╚██████╔╝██║╚██████╗ ██║  ██╗███████║"
    echo "   ╚══▀▀═╝  ╚═════╝ ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝  v${SCRIPT_VERSION}"
    echo -e "${NC}"
    echo -e "${BLUE}${DIVIDER}${NC}"
    echo -e " Host   : ${YELLOW}$(hostname)${NC}"
    echo -e " Kernel : ${YELLOW}$(uname -r)${NC}"
    echo -e " Time   : ${YELLOW}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${BLUE}${DIVIDER}${NC}\n"
}

# ─────────────────────────────────────────────
# Menu
# ─────────────────────────────────────────────
show_menu() {
cat << EOF
1) Current date, time & timezone
2) Logged-in users
3) System uptime & load
4) CPU information & usage
5) Memory (RAM + Swap)
6) Disk usage
7) Top 10 processes by CPU
8) Top 10 processes by Memory
9) Network interfaces & IPs
10) System temperature
11) Recent critical logs
12) OS & kernel information
13) Hardware summary
0) Exit (q / quit)

EOF
}

press_enter() {
    echo
    read -n 1 -s -r -p "Press Enter to continue..."
}

invalid_choice() {
    echo -e "${RED}Invalid choice!${NC}"
    sleep 1
}

# ─────────────────────────────────────────────
# Options
# ─────────────────────────────────────────────

option_1() {
    date "+%A, %d %B %Y %H:%M:%S %Z (%z)"
    command -v timedatectl >/dev/null && timedatectl
}

option_2() {
    command -v w >/dev/null && w || who
}

option_3() {
    uptime
}

option_4() {
    echo -e "${YELLOW}CPU Model:${NC}"
    lscpu | grep "Model name" | cut -d: -f2 | sed 's/^ *//'

    echo -e "\n${YELLOW}CPU Usage:${NC}"
    top -bn1 | sed -n '3,7p'

    echo -e "\n${YELLOW}Per-core usage:${NC}"
    command -v mpstat >/dev/null && mpstat 1 1 || echo "mpstat not installed"
}

option_5() {
    free -h
}

option_6() {
    df -hT --exclude-type=tmpfs --exclude-type=devtmpfs
}

option_7() {
    ps -eo pid,ppid,%cpu,%mem,cmd --sort=-%cpu | head -n 11
}

option_8() {
    ps -eo pid,ppid,%cpu,%mem,cmd --sort=-%mem | head -n 11
}

option_9() {
    command -v ip >/dev/null && ip -brief addr || ifconfig
}

option_10() {
    if command -v sensors >/dev/null; then
        sensors
    else
        for t in /sys/class/thermal/thermal_zone*/temp; do
            [[ -f "$t" ]] && echo "Temperature: $(( $(cat "$t") / 1000 )) °C"
        done || echo "No temperature data available"
    fi
}

option_11() {
    if command -v journalctl >/dev/null; then
        journalctl -p 3 -n 10 --no-pager
    elif [[ -f /var/log/syslog ]]; then
        tail -n 10 /var/log/syslog
    elif [[ -f /var/log/messages ]]; then
        tail -n 10 /var/log/messages
    else
        echo "No logs found"
    fi
}

option_12() {
    cat /etc/os-release 2>/dev/null | grep PRETTY_NAME
    uname -a
}

option_13() {
    echo -e "${YELLOW}CPU:${NC}"
    lscpu | grep -E "Architecture|Model name|CPU\(s\)"

    echo -e "\n${YELLOW}Memory:${NC}"
    free -h
}

# ─────────────────────────────────────────────
# Main Loop
# ─────────────────────────────────────────────
while true; do
    show_header
    show_menu
    read -r -p "Enter your choice (0-13): " choice
    echo -e "${BLUE}${DIVIDER}${NC}"

    case "$choice" in
        1) option_1 ;;
        2) option_2 ;;
        3) option_3 ;;
        4) option_4 ;;
        5) option_5 ;;
        6) option_6 ;;
        7) option_7 ;;
        8) option_8 ;;
        9) option_9 ;;
        10) option_10 ;;
        11) option_11 ;;
        12) option_12 ;;
        13) option_13 ;;
        0|q|quit|exit)
            echo -e "${GREEN}Goodbye! QUICKS finished.${NC}"
            exit 0
            ;;
        *) invalid_choice ;;
    esac

    echo -e "${BLUE}${DIVIDER}${NC}"
    press_enter
done

