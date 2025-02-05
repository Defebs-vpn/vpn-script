#!/bin/bash
# List Members Function
# By Defebs-vpn
# Updated: 2025-02-04 21:29:55

list_members() {
    clear
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "            ${GREEN}Member List${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    
    echo -e "Username : Expiry Date"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    while IFS=: read -r user pass exp; do
        echo -e "$user : $exp"
    done < $USER_DATA
}