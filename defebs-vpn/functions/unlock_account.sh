#!/bin/bash
# Unlock Account Function
# By Defebs-vpn
# Updated: 2025-02-04 21:29:55

unlock_account() {
    clear
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "            ${GREEN}Unlock Account${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    
    read -p "Username to unlock : " username
    
    if id "$username" >/dev/null 2>&1; then
        passwd -u "$username"
        sed -i "/^$username$/d" $LOCKED_DATA
        echo -e "${GREEN}Account $username has been unlocked${NC}"
    else
        echo -e "${RED}Error: Username does not exist${NC}"
    fi
}