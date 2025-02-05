#!/bin/bash
# Lock Account Function
# By Defebs-vpn
# Updated: 2025-02-04 21:29:55

lock_account() {
    clear
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "            ${GREEN}Lock Account${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    
    read -p "Username to lock : " username
    
    if id "$username" >/dev/null 2>&1; then
        passwd -l "$username"
        echo "$username" >> $LOCKED_DATA
        echo -e "${GREEN}Account $username has been locked${NC}"
    else
        echo -e "${RED}Error: Username does not exist${NC}"
    fi
}