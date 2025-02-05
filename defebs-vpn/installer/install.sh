#!/bin/bash
# Defebs-vpn Installer
# Current Date: 2025-02-04 22:39:21
# Current User: Defebs-vpn

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Repository Information
REPO_OWNER="Defebs-vpn"
REPO_NAME="vpn-script"
REPO_URL="https://github.com/$REPO_OWNER/$REPO_NAME"
REPO_BRANCH="main"
REPO_RAW_URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$REPO_BRANCH"

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "     ${GREEN}Defebs-VPN Script Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Current Date : 2025-02-04 22:39:21"
echo -e "Current User : Defebs-vpn"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Verify download URL before cloning
verify_repo() {
    echo "Verifying repository access..."
    if curl --output /dev/null --silent --head --fail "$REPO_RAW_URL/installer/install.sh"; then
        echo "Repository access verified successfully"
    else
        echo -e "${RED}Error: Cannot access repository${NC}"
        echo "Please check repository URL and permissions"
        exit 1
    fi
}

# Verifikasi file existence
verify_files() {
    local required_files=(
        "setup/setup.sh"
        "menu/menu-ssh.sh"
        "functions/check_users.sh"
        "functions/create_account.sh"
        "functions/delete_account.sh"
        "functions/renew_account.sh"
        "functions/trial_account.sh"
        "functions/list_members.sh"
        "functions/list_expired.sh"
        "functions/lock_account.sh"
        "functions/unlock_account.sh"
        "functions/edit_limit_ip.sh"
        "functions/edit_limit_ip_all.sh"
    )

    echo "Verifying required files..."
    for file in "${required_files[@]}"; do
        if [ ! -f "/tmp/vpn-script/$file" ]; then
            echo -e "${RED}Error: Required file $file not found${NC}"
            echo "Please check repository structure"
            exit 1
        fi
    done
    echo "All required files verified successfully"
}

# Install required packages
install_requirements() {
    echo -e "${YELLOW}Installing requirements...${NC}"
    apt update
    apt install -y git curl wget unzip net-tools ssh dropbear stunnel4 nodejs npm
}

# Clone repository
clone_repo() {
    echo -e "${YELLOW}Cloning repository...${NC}"
    rm -rf /tmp/vpn-script
    git clone -b $REPO_BRANCH $REPO_URL /tmp/vpn-script
}

# Run setup script
run_setup() {
    echo -e "${YELLOW}Running setup script...${NC}"
    if [ -f "/tmp/vpn-script/setup/setup.sh" ]; then
        chmod +x /tmp/vpn-script/setup/setup.sh
        bash /tmp/vpn-script/setup/setup.sh
    else
        echo -e "${RED}Setup script not found!${NC}"
        exit 1
    fi
}

#
# Create update script
create_update_script() {
    cat > $SCRIPT_DIR/update-script <<EOF
#!/bin/bash
# Update script for Defebs-VPN
REPO_URL="$REPO_URL"
REPO_BRANCH="$REPO_BRANCH"
INSTALL_DIR="$INSTALL_DIR"

echo "Updating Defebs-VPN scripts..."
rm -rf /tmp/vpn-script
git clone -b \$REPO_BRANCH \$REPO_URL /tmp/vpn-script

# Update all components
cp -rf /tmp/vpn-script/menu/* \$INSTALL_DIR/
cp -rf /tmp/vpn-script/functions/* \$INSTALL_DIR/functions/
cp -rf /tmp/vpn-script/setup/setup.sh \$INSTALL_DIR/

# Set permissions
chmod +x \$INSTALL_DIR/menu-ssh.sh
chmod +x \$INSTALL_DIR/functions/*
chmod +x \$INSTALL_DIR/setup.sh

# Run setup if needed
bash \$INSTALL_DIR/setup.sh --update

rm -rf /tmp/vpn-script
echo "Update completed!"
EOF
    chmod +x $SCRIPT_DIR/update-script
}

# Create uninstall script
create_uninstall_script() {
    cat > $SCRIPT_DIR/uninstall-script <<EOF
#!/bin/bash
# Uninstall script for Defebs-VPN
INSTALL_DIR="$INSTALL_DIR"
SCRIPT_DIR="$SCRIPT_DIR"

echo "Uninstalling Defebs-VPN scripts..."

# Remove installation directory
rm -rf \$INSTALL_DIR

# Remove symlinks
rm -f \$SCRIPT_DIR/menu-ssh
rm -f \$SCRIPT_DIR/vpn-setup
rm -f \$SCRIPT_DIR/update-script
rm -f \$SCRIPT_DIR/uninstall-script

echo "Uninstall completed!"
EOF
    chmod +x $SCRIPT_DIR/uninstall-script
}

# Display success message
show_success() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "     ${GREEN}Installation Completed!${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "Available Commands:"
    echo -e "${YELLOW}menu-ssh${NC}         - Open SSH/VPN menu"
    echo -e "${YELLOW}vpn-setup${NC}        - Run VPN setup"
    echo -e "${YELLOW}update-script${NC}     - Update scripts"
    echo -e "${YELLOW}uninstall-script${NC}  - Uninstall scripts"
    echo -e ""
    echo -e "Installation Directory: ${GREEN}$INSTALL_DIR${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main installation
main() {
    verify_repo
    verify_files
    install_requirements
    clone_repo
    run_setup
    create_update_script
    create_uninstall_script
    show_success
}

main
