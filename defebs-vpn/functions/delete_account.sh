#!/bin/bash
# Delete Account Function
# By Defebs-vpn
# Updated: 2025-02-04 21:29:55

delete_account() {
    clear
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "            ${GREEN}Delete Account${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    
    read -p "Username to delete : " username
    
    if id "$username" >/dev/null 2>&1; then
        userdel -r "$username"
        sed -i "/^$username:/d" $USER_DATA
        echo -e "${GREEN}Account $username has been deleted${NC}"
    else
        echo -e "${RED}Error: Username does not exist${NC}"
    fi
}