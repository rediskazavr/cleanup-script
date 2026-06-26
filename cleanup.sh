#!/bin/bash
clear

# COLORS
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
LIGHT_YELLOW="\e[93m"
ENDCOLOR="\e[0m"

if [ -f /etc/os-release ]; then
	. /etc/os-release
	if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
		echo -e "${RED}Aborted. Script only use for Ubuntu/Debian${ENDCOLOR}"
		exit 1
	fi
else
	echo -e "${RED}Cannot determined distro. Aborted ${ENDCOLOR}"
	exit 1
fi

VERSION_CODENAME=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)

echo "======================================"
echo "CLEANUP SCRIPT by [github/rediskazavr]"
echo "======================================"

echo "[1] - Full cleanup"
echo "[2] - Quick cleanup"
echo "[3] - Docker cleanup"
echo "[0] - Exit"

echo -n "Enter number: "
read -r number

if [[ "$number" == 1 ]]; then
	echo -e "${RED}WARNING! IT'S VERY AGRESSIVE CLEANUP${ENDCOLOR}"
	echo -n "Are you sure? [y/n]: "
	read allow

	if [[ "$allow" == "y" ]]; then
		true
	elif [[ "$allow" == "n" ]]; then
		exit 0
	else
		echo "Aborted."
		exit 1
	fi
    echo -e "${GREEN}Start full cleanup${ENDCOLOR}"
	sudo apt clean
	sudo apt autoclean
	sudo apt autoremove -y
	sudo journalctl --vacuum-time=7d
	sudo find /tmp -type f -atime +7 -delete
	sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
	sudo rm -rf /var/tmp/*
	sudo systemd-tmpfiles --clean
	sudo journalctl --vacuum-size=200M
	sudo find /var/log -type f -exec truncate -s 0 {} \;
	sudo find /tmp -type f -delete
	sudo find /var/tmp -type f -delete
    echo -e "${GREEN}Done.${ENDCOLOR}"
elif [[ "$number" == 2 ]]; then
	echo -e "${GREEN}Start quick cleanup${ENDCOLOR}"
	sudo apt clean
	sudo apt autoclean
	sudo apt autoremove -y
	sudo journalctl --vacuum-time=7d
	sudo find /tmp -type f -atime +7 -delete
    echo -e "${GREEN}Done.${ENDCOLOR}"
elif [[ "$number" == 3 ]]; then
    echo -e "${GREEN}Start docker cleanup${ENDCOLOR}"
	docker system prune -a --volumes -f
	docker builder prune -a -f
	find /var/lib/docker/containers -name "*.log" -exec truncate -s 0 {} \;
    echo -e "${GREEN}Done.${ENDCOLOR}"
elif [[ "$number" == 0 ]]; then
	echo "Exit"
	exit 1
else
	echo "Aborted."
fi
