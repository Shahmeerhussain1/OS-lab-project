#!/usr/bin/env bash
# Advanced System Information Menu
# Last updated: 2025/2026 style

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Global settings
readonly SCRIPT_VERSION="2.1"
readonly DIVIDER="════════════════════════════════════════════════════════════"

clear

show_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "  ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗ "
    echo "  ██╔════╝██║   ██║██╔════╝╚══██╔══╝██╔════╝████╗ ████║ "
    echo "  ███████╗██║   ██║███████╗   ██║   █████╗  ██╔████╔██║ "
    echo "  ╚════██║╚██╗ ██╔╝╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║ "
    echo "  ███████║ ╚████╔╝ ███████║   ██║   ███████╗██║ ╚═╝ ██║ "
    echo "  ╚══════╝  ╚═══╝  ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝ v${SCRIPT_VERSION}"
    echo -e "${NC}"
    echo -e "${BLUE}${DIVIDER}${NC}"
    echo -e "  Host: ${YELLOW}$(hostname -f 2>/dev/null || hostname)${NC}"
    echo -e "  Kernel: ${YELLOW}$(uname -r)${NC}    •    $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${BLUE}${DIVIDER}${NC}\n"
}

show_menu() {
    cat << 'EOF'
1)  Current date, time & timezone
2)  Logged-in users & who is doing what
3)  System uptime & load average
4)  CPU information & current usage
5)  Memory (RAM + Swap) detailed
6)  Disk usage & mount points (human readable)
7)  Top 10 processes by CPU usage
8)  Top 10 processes by memory usage
9)  Network interfaces & IP addresses
10) System temperature & fan sensors (if available)
11) Last 10 logged critical/auth events
12) Kernel & distribution information
13) Quick hardware overview (lscpu + dmidecode summary)
0)  Exit
EOF
}

press_enter() {
    echo
    read -n 1 -s -r -p "Press [Enter] to continue..."
    echo
}

invalid_choice() {
    echo -e "${RED}Invalid choice! Please select a valid option.${NC}"
    sleep 1.5
}

# ────────────────────────────────────────────────────────────────
# Main functions
# ────────────────────────────────────────────────────────────────

option_1() { date "+%A, %d %B %Y   %H:%M:%S %Z (%z)"; timedatectl 2>/dev/null || echo "timedatectl not available"; }
option_2() { who -aHs || w; }
option_3() { uptime; echo; w -u; }
option_4() {
    echo -e "${YELLOW}CPU Model:${NC}"
    lscpu | grep -E "Model name:" | awk -F: '{print $2}' | sed 's/^[ \t]*//'
    echo -e "\n${YELLOW}Current usage:${NC}"
    top -bn1 | head -15 | grep -A5 "%Cpu(s)"
    echo -e "\n${YELLOW}Per-core usage (mpstat if available):${NC}"
    mpstat 1 1 2>/dev/null | tail -n +4 || echo "mpstat not installed"
}
option_5() { free -h --si; echo; vmstat -s | grep -E "total|free|used|buff|cache|swap"; }
option_6() { df -hT --exclude-type=tmpfs --exclude-type=devtmpfs; echo; df -iH; }
option_7() { ps -eo pid,ppid,%cpu,%mem,cmd --sort=-%cpu | head -n 11; }
option_8() { ps -eo pid,ppid,%cpu,%mem,cmd --sort=-%mem | head -n 11; }
option_9() {
    ip -brief -color addr show
    echo -e "\n${YELLOW}Routing table snapshot:${NC}"
    ip route show | grep -v "linkdown\|unreachable"
}
option_10() {
    if command -v sensors >/dev/null 2>&1; then
        sensors
    else
        echo "sensors not found. Try installing lm-sensors package."
        echo "Fallback temperature info:"
        for file in /sys/class/hwmon/hwmon*/temp*_input; do
            [[ -f "$file" ]] && echo "${file##*/} : $(( $(cat "$file") / 1000 )) °C"
        done 2>/dev/null || echo "No temperature sensors found in /sys"
    fi
}
option_11() { journalctl -p 3 -xb -n 10 --no-pager || tail -n 15 /var/log/syslog /var/log/messages 2>/dev/null; }
option_12() {
    echo -e "${YELLOW}Distribution:${NC}"
    cat /etc/os-release 2>/dev/null | grep -E "PRETTY_NAME|VERSION_ID|ID="
    echo -e "\n${YELLOW}Kernel:${NC} $(uname -a)"
}
option_13() {
    echo -e "${YELLOW}CPU summary:${NC}"
    lscpu | grep -E "Architecture|Model name|Socket|Core|Thread|MHz"
    echo -e "\n${YELLOW}Memory (physical):${NC}"
    sudo dmidecode --type memory 2>/dev/null | grep -E "Size:|Type:|Speed:" || echo "Run as root for full dmidecode info"
}

# ────────────────────────────────────────────────────────────────
# Main loop
# ────────────────────────────────────────────────────────────────

while true; do
    show_header
    show_menu
    echo
    read -p "Enter your choice (0-13) → " choice

    echo
    echo -e "${BLUE}${DIVIDER}${NC}"

    case "$choice" in
        1)  option_1  ;;
        2)  option_2  ;;
        3)  option_3  ;;
        4)  option_4  ;;
        5)  option_5  ;;
        6)  option_6  ;;
        7)  option_7  ;;
        8)  option_8  ;;
        9)  option_9  ;;
        10) option_10 ;;
        11) option_11 ;;
        12) option_12 ;;
        13) option_13 ;;
        0|"q"|"quit"|"exit")
            echo -e "\n${GREEN}Goodbye! System monitoring finished.${NC}\n"
            exit 0
            ;;
        *)  invalid_choice ;;
    esac

    echo -e "${BLUE}${DIVIDER}${NC}"
    press_enter
done

