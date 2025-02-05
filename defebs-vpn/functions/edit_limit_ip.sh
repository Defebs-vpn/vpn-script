#!/bin/bash
# Edit IP Limit Function
# By Defebs-vpn
# Updated: 2025-02-04 21:29:55

edit_limit_ip() {
    clear
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "            ${GREEN}Edit IP Limit${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    
    read -p "Username : " username
    read -p "New IP limit : " iplimit
    
    if id "$username" >/dev/null 2>&1; then
        mkdir -p /etc/vps/limit_ip
        echo "$iplimit" > "/etc/vps/limit_ip/$username"
        echo -e "${GREEN}IP limit for $username has been set to $iplimit${NC}"
    else
        echo -e "${RED}Error: Username does not exist${NC}"
    fi
}