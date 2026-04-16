# rhel-system-performance-monitorrhel-system-performance-monitor.sh

# Overview
rhel-system-performance-monitor.sh is a lightweight, all‑in‑one Bash script for monitoring the health and performance of RHEL (Red Hat Enterprise Linux) servers. It delivers a clear, colour‑coded report covering essential system metrics and alerts administrators when resource usage exceeds defined limits.

# Features
CPU Usage – Shows current CPU utilisation percentage.

Memory Usage – Displays total, used, free memory and utilisation percentage.

Disk Usage – Reports total, used, free space and usage percentage for all mounted filesystems.

Top Processes – Lists the top 5 processes by CPU and by memory consumption.

Health Status – Evaluates CPU, memory, and disk against thresholds and outputs:

🟢 OK – all resources within normal limits

🟡 Warning – usage exceeds 70% but below critical threshold

🔴 Critical – usage exceeds user‑defined thresholds (default: CPU 80%, Memory 80%, Disk 90%)

Additional Info – OS version, system uptime, load average, currently logged‑in users.

Configurable – Thresholds can be customised via /etc/rhel-monitor/config.conf.

Colour Output – Easy‑to‑read terminal output with coloured health status.

Cron‑Ready – Can be scheduled for automated monitoring and logging.

# Requirements
RHEL 7, 8, or 9 (or any RHEL‑based distribution like CentOS, AlmaLinux, Rocky Linux)

Bash 4.0+

Standard commands: top, free, df, ps, cat, uptime, who

# Installation (All Users)
Follow the step‑by‑step guide to install system‑wide:

Create directories: /opt/rhel-system-monitor/, /etc/rhel-monitor/, /var/log/rhel-monitor/

Place script in /opt/rhel-system-monitor/rhel-system-performance-monitor.sh and set chmod 755

Create config file /etc/rhel-monitor/config.conf (optional)

Create symlink: ln -s /opt/rhel-system-monitor/rhel-system-performance-monitor.sh /usr/local/bin/rhel-monitor

# Run as any user
rhel-monitor

# Or with full path
/opt/rhel-system-monitor/rhel-system-performance-monitor.sh

# Override config file location
CONFIG_FILE=/path/to/custom.conf rhel-monitor

Configuration Example (/etc/rhel-monitor/config.conf)
(bash)

CPU_THRESHOLD=75

MEM_THRESHOLD=85

DISK_THRESHOLD=95


