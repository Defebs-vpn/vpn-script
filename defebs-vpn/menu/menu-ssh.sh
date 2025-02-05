#!/bin/bash
# SSH/OpenVPN Menu Management
# By Defebs-vpn
# Current Date: 2025-02-04 21:15:49

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Path to store user data
USER_DATA="/etc/vps/user_data"
EXPIRED_DATA="/etc/vps/expired_users"
LOCKED_DATA="/etc/vps/locked_users"

# Create directories if they don't exist
mkdir -p /etc/vps

clear

show_menu() {
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "           ${GREEN}SSH-Dropbear-OpenVPN${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "   ${YELLOW}1.)${NC}  Check Users Login"
    echo -e "   ${YELLOW}2.)${NC}  Create Accounts"
    echo -e "   ${YELLOW}3.)${NC}  Delete Accounts"
    echo -e "   ${YELLOW}4.)${NC}  Renew Accounts"
    echo -e "   ${YELLOW}5.)${NC}  Trial Accounts"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "                  ${GREEN}MEMBER${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "   ${YELLOW}6.)${NC}  List Member Accounts"
    echo -e "   ${YELLOW}7.)${NC}  List Expired Accounts"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "               ${GREEN}LOCK & UNLOCK${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "   ${YELLOW}8.)${NC}  Lock Accounts"
    echo -e "   ${YELLOW}9.)${NC}  Unlock Accounts"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "                   ${GREEN}LIMIT${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "  ${YELLOW}10.)${NC}  Edit Limit IP Accounts"
    echo -e "  ${YELLOW}11.)${NC}  Edit Limit IP All Accounts"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "  ${YELLOW}12.)${NC}  Back to Menu"
    echo -e "   ${YELLOW}x.)${NC}  Exit"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
    echo -e "${BLUE}————————————————————————————————————————${NC}"
}

# Source function files
source /usr/local/bin/ssh-vpn-functions

while true; do
    show_menu
    read -p " Select From Options [1-12 or x] : " choice
    case $choice in
        1) check_users_login ;;
        2) create_account ;;
        3) delete_account ;;
        4) renew_account ;;
        5) create_trial ;;
        6) list_members ;;
        7) list_expired ;;
        8) lock_account ;;
        9) unlock_account ;;
        10) edit_limit_ip ;;
        11) edit_limit_ip_all ;;
        12) exit ;;
        "x"|"X") break ;;
        *) echo -e "${RED}Please enter a valid option${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to continue..."
done