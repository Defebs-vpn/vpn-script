#!/bin/bash
# Renew Account Function
# By Defebs-vpn
# Updated: 2025-02-04 21:29:55

renew_account() {
    clear
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "            ${GREEN}Renew Account${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    
    read -p "Username to renew : " username
    read -p "Add duration (days) : " duration
    
    if id "$username" >/dev/null 2>&1; then
        current_exp=$(grep "^$username:" $USER_DATA | cut -d: -f3)
        new_exp=$(date -d "$current_exp +$duration days" +"%Y-%m-%d")
        sed -i "s|$username:.*|$username:$(grep "^$username:" $USER_DATA | cut -d: -f2):$new_exp|" $USER_DATA
        echo -e "${GREEN}Account $username has been renewed until $new_exp${NC}"
    else
        echo -e "${RED}Error: Username does not exist${NC}"
    fi
}