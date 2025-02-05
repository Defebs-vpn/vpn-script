#!/bin/bash
# Create Account Function
# By Defebs-vpn
# Updated: 2025-02-04 21:29:55

create_account() {
    clear
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "            ${GREEN}Create New Account${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    
    read -p "Username : " username
    read -p "Password : " password
    read -p "Duration (days) : " duration
    
    # Check if username exists
    if id "$username" >/dev/null 2>&1; then
        echo -e "${RED}Error: Username already exists${NC}"
        return 1
    fi
    
    exp_date=$(date -d "+$duration days" +"%Y-%m-%d")
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    # Store user data
    echo "$username:$password:$exp_date" >> $USER_DATA
    
    echo -e "${GREEN}Account Created Successfully${NC}"
    echo -e "Username      : $username"
    echo -e "Password      : $password"
    echo -e "Expires on    : $exp_date"
}