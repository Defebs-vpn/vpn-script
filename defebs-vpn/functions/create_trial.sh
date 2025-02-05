#!/bin/bash
# Trial Account Function
# By Defebs-vpn
# Updated: 2025-02-04 21:29:55

create_trial() {
    clear
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "            ${GREEN}Create Trial Account${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    
    username="trial$(date +%s)"
    password="trial$(date +%s)"
    duration=1
    
    create_account "$username" "$password" "$duration"
}