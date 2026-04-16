#!/bin/bash

# ============================================
# rhel-system-performance-monitor.sh
# RHEL Server Performance Monitor
# Merged: Basic stats + Health status with thresholds
# ============================================

# Configuration (can be overridden by config.conf)
CONFIG_FILE="${CONFIG_FILE:-/etc/rhel-monitor/config.conf}"
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90

# Load custom config if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Helper: Extract numeric values
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print 100 - $NF}' | cut -d. -f1
}

get_memory_percent() {
    free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}'
}

get_disk_usage() {
    df -h --total | awk 'END {gsub(/%/,"",$5); print $5}'
}

# ========== COLLECT DATA ==========
echo "============================================================================================="
echo "----------------------------SERVER PERFORMANCE STATISTICS------------------------------------"
echo "============================================================================================="

echo ""
echo " 1- CPU Usage: "
CPU_USAGE=$(get_cpu_usage)
echo "${CPU_USAGE}%"

echo ""
echo " 2- Memory Usage: "
TOTAL_MEM=$(free -m | awk '/Mem:/ {print $2}')
USED_MEM=$(free -m | awk '/Mem:/ {print $3}')
FREE_MEM=$(free -m | awk '/Mem:/ {print $4}')
MEM_PERCENT=$(get_memory_percent)

echo "Total Memory : ${TOTAL_MEM} MB"
echo "Used Memory  : ${USED_MEM} MB"
echo "Free Memory  : ${FREE_MEM} MB"
echo "Memory Usage : ${MEM_PERCENT}%"

echo ""
echo " 3- Disk Usage: "
df -h --total | tail -1 | awk '{print "Total Disk: "$2"\nUsed Disk: "$3"\nFree Disk: "$4"\nUsage: "$5}'
DISK_USAGE=$(get_disk_usage)

echo ""
echo " 4- Top 5 processes by CPU usage: "
ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -6

echo ""
echo " 5- Top 5 Processes by Memory Usage: "
ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -6

# ========== HEALTH ASSESSMENT ==========
echo ""
echo "============================================================================================="
echo "                                    SYSTEM HEALTH STATUS"
echo "============================================================================================="

# Determine health level
HEALTH="OK"
WARN_MSG=""
CRIT_MSG=""

if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
    HEALTH="Critical"
    CRIT_MSG="${CRIT_MSG} CPU at ${CPU_USAGE}% (>=${CPU_THRESHOLD}%)"
elif [ "$CPU_USAGE" -ge 70 ]; then
    HEALTH="Warning"
    WARN_MSG="${WARN_MSG} CPU at ${CPU_USAGE}% (>=70%)"
fi

if [ "$MEM_PERCENT" -ge "$MEM_THRESHOLD" ]; then
    HEALTH="Critical"
    CRIT_MSG="${CRIT_MSG} Memory at ${MEM_PERCENT}% (>=${MEM_THRESHOLD}%)"
elif [ "$MEM_PERCENT" -ge 70 ]; then
    HEALTH="Warning"
    WARN_MSG="${WARN_MSG} Memory at ${MEM_PERCENT}% (>=70%)"
fi

if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
    HEALTH="Critical"
    CRIT_MSG="${CRIT_MSG} Disk at ${DISK_USAGE}% (>=${DISK_THRESHOLD}%)"
elif [ "$DISK_USAGE" -ge 80 ]; then
    HEALTH="Warning"
    WARN_MSG="${WARN_MSG} Disk at ${DISK_USAGE}% (>=80%)"
fi

# Output health
case $HEALTH in
    OK)
        echo -e "\033[32mHealth: OK - All resources within normal limits.\033[0m"
        ;;
    Warning)
        echo -e "\033[33mHealth: WARNING - $WARN_MSG\033[0m"
        ;;
    Critical)
        echo -e "\033[31mHealth: CRITICAL - $CRIT_MSG\033[0m"
        ;;
esac

# ========== ADDITIONAL SERVER INFO ==========
echo ""
echo "============================================================================================="
echo "        			    ADDITIONAL SERVER INFORMATION"
echo "============================================================================================="

echo ""
echo "OS Version:"
cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"'

echo ""
echo "System Uptime:"
uptime -p

echo ""
echo "Load Average:"
uptime | awk -F'load average:' '{print $2}'

echo ""
echo "Logged in Users:"
who

echo ""
echo "============================================================================================="
echo "Server stats collected successfully"