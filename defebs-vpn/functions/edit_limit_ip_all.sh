#!/bin/bash
# Edit IP Limit All Function
# By Defebs-vpn
# Updated: 2025-02-04 21:29:55

edit_limit_ip_all() {
    clear
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "            ${GREEN}Edit IP Limit All${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    
    read -p "New IP limit for all users : " iplimit
    
    mkdir -p /etc/vps/limit_ip
    while IFS=: read -r user pass exp; do
        echo "$iplimit" > "/etc/vps/limit_ip/$user"
    done < $USER_DATA
    
    echo -e "${GREEN}IP limit has been set to $iplimit for all users${NC}"
}