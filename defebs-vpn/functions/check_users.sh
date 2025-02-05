#!/bin/bash
# Check Users Login Function
# By Defebs-vpn
# Updated: 2025-02-04 21:29:55

check_users_login() {
    clear
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "            ${GREEN}Users Login Check${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo ""
    
    # Check OpenVPN users
    echo -e "${YELLOW}OpenVPN Users:${NC}"
    cat /etc/openvpn/openvpn-status.log 2>/dev/null | grep "CLIENT_LIST" | tail -n +2 | awk '{print $2}' | sort
    
    # Check Dropbear users
    echo -e "\n${YELLOW}Dropbear Users:${NC}"
    ps aux | grep -i dropbear | awk '{print $2}' | grep -v "grep" | xargs -I {} netstat -tnp | grep "{}"
    
    # Check SSH users
    echo -e "\n${YELLOW}SSH Users:${NC}"
    ps aux | grep -i sshd | grep -v root | grep priv | awk '{print $2}' | xargs -I {} netstat -tnp | grep "{}"
}