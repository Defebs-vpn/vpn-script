#!/bin/bash
# List Expired Function
# By Defebs-vpn
# Updated: 2025-02-04 21:29:55

list_expired() {
    clear
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "            ${GREEN}Expired Accounts${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    
    current_date=$(date +%s)
    while IFS=: read -r user pass exp; do
        exp_date=$(date -d "$exp" +%s)
        if [ $current_date -gt $exp_date ]; then
            echo -e "$user : $exp"
        fi
    done < $USER_DATA
}