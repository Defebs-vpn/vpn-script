#!/bin/bash

LOG_FILE="/var/log/vpn_setup.log"

# Function to display a banner
display_banner() {
    echo "########################################" | tee -a $LOG_FILE
    echo "#                                      #" | tee -a $LOG_FILE
    echo "#      Auto Setup VPN SSH WebSocket    #" | tee -a $LOG_FILE
    echo "#            by Defebs-vpn             #" | tee -a $LOG_FILE
    echo "#                                      #" | tee -a $LOG_FILE
    echo "########################################" | tee -a $LOG_FILE
    echo "" | tee -a $LOG_FILE
}
# Pre-Installation Checks
function pre_checks() {
    clear
    echo -e "${BLUE}"
    echo "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
    echo " Initial System Verification"
    echo "▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"
    echo -e "${NC}"

    # Check Root Privileges
    echo -e "${CYAN}[1/2]${NC} Verifying root access..."
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}✗ Error: Script must be run as root${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Root access confirmed${NC}"

    # Check OS Compatibility
    echo -e "${CYAN}[2/2]${NC} Checking OS compatibility..."
    source /etc/os-release
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
        echo -e "${RED}✗ Unsupported OS: $PRETTY_NAME${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Supported OS: $PRETTY_NAME${NC}"
    
clean_system() {
    echo "[INFO] Membersihkan sistem..." | tee -a $LOG_FILE
    
    # Hapus paket VPN lama jika ada
    services_to_remove=(
        "openvpn"
        "stunnel4"
        "nginx"
        "dropbear"
        "wstunnel"
        "bind9"
    )
    
    for service in "${services_to_remove[@]}"; do
        if dpkg -l | grep -q "^ii.*$service"; then
            echo "[INFO] Menghapus $service..." | tee -a $LOG_FILE
            apt purge $service -y
        fi
    done
    
    # Bersihkan konfigurasi yang tersisa
    rm -rf /etc/openvpn/*
    rm -rf /etc/stunnel/*
    rm -rf /etc/nginx/sites-enabled/*
    rm -rf /etc/dropbear/*
}

# Function to prompt for domain input and validate
prompt_for_domain() {
    while true; do
        read -p "Please enter your domain name (e.g., example.com): " DOMAIN
        if [[ -z "$DOMAIN" ]]; then
            echo "[ERROR] Domain name cannot be empty. Please provide a valid domain name." | tee -a $LOG_FILE
        elif ! [[ "$DOMAIN" =~ ^[a-zA-Z0-9.-]+$ ]]; then
            echo "[ERROR] Invalid domain name format. Please provide a valid domain name." | tee -a $LOG_FILE
        else
            break
        fi
    done
}

# Function to update the system and install necessary packages
install_packages() {
    echo "[INFO] Updating system and installing necessary packages..." | tee -a $LOG_FILE
    sudo apt update && sudo apt upgrade -y | tee -a $LOG_FILE
    sudo apt install -y openvpn easy-rsa stunnel4 nginx certbot python3-certbot-nginx ufw wstunnel dropbear tzdata locales gcc make cmake git fail2ban dnsutils bind9 bind9utils bind9-doc | tee -a $LOG_FILE
}

# Function to setup timezone
setup_timezone() {
    echo "[INFO] Setting timezone to Asia/Jakarta..." | tee -a $LOG_FILE
    sudo timedatectl set-timezone Asia/Jakarta | tee -a $LOG_FILE
}

# Function to setup locale
setup_locale() {
    echo "[INFO] Setting locale to en_US.UTF-8..." | tee -a $LOG_FILE
    sudo locale-gen en_US.UTF-8 | tee -a $LOG_FILE
    sudo update-locale LANG=en_US.UTF-8 | tee -a $LOG_FILE
    export LANG=en_US.UTF-8
}

performance_optimization() {
    echo "[INFO] Mengoptimasi performa sistem..." | tee -a $LOG_FILE
    
    # Optimasi Sistem
    cat >> /etc/sysctl.conf <<EOF
# Optimasi Network
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1

# Optimasi Memory
vm.swappiness = 10
vm.vfs_cache_pressure = 50
EOF
    
    # Terapkan perubahan
    sysctl -p
}

# Function to setup OpenVPN
setup_openvpn() {
    echo "[INFO] Setting up OpenVPN..." | tee -a $LOG_FILE
    make-cadir ~/openvpn-ca
    cd ~/openvpn-ca
    source vars
    ./clean-all
    ./build-ca --batch
    ./build-key-server --batch server
    ./build-dh
    openvpn --genkey --secret keys/ta.key
    cd keys
    sudo cp ca.crt server.crt server.key ta.key dh2048.pem /etc/openvpn
    cd /etc/openvpn
    sudo gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > server.conf
    sudo sed -i 's/;tls-auth ta.key 0 # This file is secret/tls-auth ta.key 0/g' /etc/openvpn/server.conf
    sudo sed -i 's/;cipher AES-256-CBC/cipher AES-256-CBC/g' /etc/openvpn/server.conf
    sudo sed -i 's/;user nobody/user nobody/g' /etc/openvpn/server.conf
    sudo sed -i 's/;group nogroup/group nogroup/g' /etc/openvpn/server.conf
    sudo sed -i 's/port 1194/port 80/g' /etc/openvpn/server.conf
    sudo sed -i 's/proto udp/proto tcp/g' /etc/openvpn/server.conf
    sudo systemctl start openvpn@server
    sudo systemctl enable openvpn@server
}

# Function to setup additional OpenVPN configurations
setup_additional_openvpn() {
    echo "[INFO] Setting up additional OpenVPN configurations..." | tee -a $LOG_FILE
    cat <<EOF >> /etc/openvpn/server.conf
port 443
proto tcp
port 25000
proto udp
port 53
proto udp
EOF
    sudo systemctl restart openvpn@server
}

# Function to enable IP forwarding and configure firewall
configure_firewall() {
    echo "[INFO] Enabling IP forwarding and configuring firewall..." | tee -a $LOG_FILE
    sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
    sudo sysctl -p | tee -a $LOG_FILE
    sudo ufw allow 80/tcp | tee -a $LOG_FILE
    sudo ufw allow 443/tcp | tee -a $LOG_FILE
    sudo ufw allow 22/tcp | tee -a $LOG_FILE
    sudo ufw allow 2222/tcp | tee -a $LOG_FILE
    sudo ufw allow 444/tcp | tee -a $LOG_FILE
    sudo ufw allow 1194/tcp | tee -a $LOG_FILE
    sudo ufw allow 53/udp | tee -a $LOG_FILE
    sudo ufw allow 5300/udp | tee -a $LOG_FILE
    sudo ufw allow 7788/tcp | tee -a $LOG_FILE
    sudo ufw allow 2082/tcp | tee -a $LOG_FILE
    sudo ufw allow 8080/tcp | tee -a $LOG_FILE
    sudo ufw allow 8880/tcp | tee -a $LOG_FILE
    sudo ufw allow 2052/tcp | tee -a $LOG_FILE
    sudo ufw allow 2086/tcp | tee -a $LOG_FILE
    sudo ufw allow 2095/tcp | tee -a $LOG_FILE
    sudo ufw allow 8443/tcp | tee -a $LOG_FILE
    sudo ufw allow 2053/tcp | tee -a $LOG_FILE
    sudo ufw allow 2083/tcp | tee -a $LOG_FILE
    sudo ufw allow 2087/tcp | tee -a $LOG_FILE
    sudo ufw allow 2096/tcp | tee -a $LOG_FILE
    sudo ufw allow 1:65535/udp | tee -a $LOG_FILE
    sudo ufw allow 9080/tcp | tee -a $LOG_FILE
    sudo ufw allow 3128/tcp | tee -a $LOG_FILE
    sudo ufw allow 7100:7600/udp | tee -a $LOG_FILE
    sudo ufw --force enable | tee -a $LOG_FILE
}

# Function to setup Stunnel
setup_stunnel() {
    echo "[INFO] Setting up Stunnel..." | tee -a $LOG_FILE
    sudo cp /etc/stunnel/stunnel.conf /etc/stunnel/stunnel.conf.bak
    cat <<EOF | sudo tee /etc/stunnel/stunnel.conf
cert = /etc/stunnel/stunnel.pem
key = /etc/stunnel/stunnel.pem
[openvpn]
accept = 443
connect = 127.0.0.1:1194
EOF

    echo "[INFO] Generating SSL certificate for Stunnel..." | tee -a $LOG_FILE
    openssl req -new -x509 -days 365 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=$DOMAIN" | tee -a $LOG_FILE
    sudo systemctl restart stunnel4
    sudo systemctl enable stunnel4
}

# Function to setup Nginx as WebSocket proxy with SSL
setup_nginx() {
    echo "[INFO] Setting up Nginx as WebSocket Proxy with SSL..." | tee -a $LOG_FILE
    sudo rm /etc/nginx/sites-enabled/default
    cat <<EOF | sudo tee /etc/nginx/sites-available/websocket
server {
    listen 81;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
    ssl_ciphers "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384";

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF

    sudo ln -s /etc/nginx/sites-available/websocket /etc/nginx/sites-enabled/websocket

    echo "[INFO] Generating DH parameters for SSL..." | tee -a $LOG_FILE
    sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 | tee -a $LOG_FILE

    echo "[INFO] Obtaining SSL certificate using Certbot..." | tee -a $LOG_FILE
    sudo certbot --nginx --http-01-port=81 -d $DOMAIN | tee -a $LOG_FILE

    echo "[INFO] Restarting Nginx..." | tee -a $LOG_FILE
    sudo systemctl restart nginx
}

# Function to setup WebSocket with wstunnel
setup_websocket() {
    echo "[INFO] Setting up WebSocket with wstunnel..." | tee -a $LOG_FILE
    sudo systemctl stop wstunnel
    sudo tee /etc/systemd/system/wstunnel.service <<EOF
[Unit]
Description=WSTunnel WebSocket Proxy
After=network.target

[Service]
ExecStart=/usr/bin/wstunnel -s 0.0.0.0:8080 -t 127.0.0.1:22
Restart=always
User=nobody

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl start wstunnel
    sudo systemctl enable wstunnel
}

# Function to setup Dropbear
setup_dropbear() {
    echo "[INFO] Setting up Dropbear..." | tee -a $LOG_FILE
    sudo systemctl stop dropbear
    sudo tee /etc/default/dropbear <<EOF
NO_START=0
DROPBEAR_PORT=2222
DROPBEAR_EXTRA_ARGS="-p 80 -p 90 -p 69 -p 143"
DROPBEAR_BANNER="/etc/issue.net"
DROPBEAR_RECEIVE_WINDOW=65536
EOF

    sudo systemctl start dropbear
    sudo systemctl enable dropbear
}

# Function to setup BadVPN
setup_badvpn() {
    echo "[INFO] Setting up BadVPN..." | tee -a $LOG_FILE
    git clone https://github.com/ambrop72/badvpn.git ~/badvpn
    cd ~/badvpn
    cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
    make
    sudo cp badvpn-udpgw /usr/local/bin/
    sudo tee /etc/systemd/system/badvpn.service <<EOF
[Unit]
Description=BadVPN UDP Gateway
After=network.target

[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 0.0.0.0:7300 --max-clients 1024
Restart=always
User=nobody

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl start badvpn
    sudo systemctl enable badvpn
}

# Function to setup SlowDNS
setup_slowdns() {
    echo "[INFO] Setting up SlowDNS..." | tee -a $LOG_FILE
    # Install and configure SlowDNS Server
    sudo apt install -y bind9 bind9utils bind9-doc | tee -a $LOG_FILE

    # Back up the default named.conf.options file
    sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak

    # Configure named.conf.options file for SlowDNS
    sudo tee /etc/bind/named.conf.options <<EOF
acl "trusted" {
    10.0.0.0/8;
    172.16.0.0/12;
    192.168.0.0/16;
    localhost;
    localnets;
};

options {
    directory "/var/cache/bind";

    recursion yes;
    allow-recursion { trusted; };
    listen-on { any; };
    allow-transfer { none; };

    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    dnssec-enable yes;
    dnssec-validation yes;
    auth-nxdomain no;
    listen-on-v6 { none; };
};
EOF

    sudo systemctl restart bind9
    sudo systemctl enable bind9

    # Display DNS server status
    sudo systemctl status bind9 | tee -a $LOG_FILE
}

# Function to setup OHP (Open HTTP Proxy)
setup_ohp() {
    echo "[INFO] Setting up OHP (Open HTTP Proxy)..." | tee -a $LOG_FILE
    git clone https://github.com/lfasmpao/open-http-puncher.git ~/open-http-puncher
    cd ~/open-http-puncher
    make
    sudo cp ohpserver /usr/local/bin/
    sudo tee /etc/systemd/system/ohp.service <<EOF
[Unit]
Description=Open HTTP Proxy
After=network.target

[Service]
ExecStart=/usr/local/bin/ohpserver -port 9080 -proxy 127.0.0.1:3128 -tunnel 127.0.0.1:22
Restart=always
User=nobody

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl start ohp
    sudo systemctl enable ohp
}

# Function to install and configure Fail2Ban
setup_fail2ban() {
    echo "[INFO] Installing and configuring Fail2Ban..." | tee -a $LOG_FILE
    sudo apt install fail2ban -y | tee -a $LOG_FILE

    # Copy the default configuration file to jail.local
    sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

    # Basic configuration for SSH
    sudo tee /etc/fail2ban/jail.local <<EOF
[DEFAULT]
# Ban hosts for one hour:
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = 22,2222
logpath = %(sshd_log)s
backend = %(sshd_backend)s
EOF

    sudo systemctl start fail2ban
    sudo systemctl enable fail2ban

    # Display Fail2Ban status
    sudo fail2ban-client status | tee -a $LOG_FILE
}

# Function to display service status
display_service_status() {
    echo ""
    echo "########################################" | tee -a $LOG_FILE
    echo "#                                      #" | tee -a $LOG_FILE
    echo "#        Service Status Summary        #" | tee -a $LOG_FILE
    echo "#                                      #" | tee -a $LOG_FILE
    echo "########################################" | tee -a $LOG_FILE
    echo "" | tee -a $LOG_FILE
    
    # Display current timezone
    current_timezone=$(timedatectl | grep "Time zone" | awk '{print $3}')
    echo "[INFO] Current Timezone: $current_timezone" | tee -a $LOG_FILE
    echo ""

    # Display service statuses in a table format
    echo "+---------------------+-------------------------------+" | tee -a $LOG_FILE
    echo "|      Service        |           Status              |" | tee -a $LOG_FILE
    echo "+---------------------+-------------------------------+" | tee -a $LOG_FILE

    services=("openvpn@server" "stunnel4" "nginx" "wstunnel" "dropbear" "badvpn" "ohp" "fail2ban" "bind9")
    for service in "${services[@]}"; do
        status=$(sudo systemctl is-active $service)
        printf "| %-19s | %-29s |\n" "$service" "$status" | tee -a $LOG_FILE
    done

    echo "+---------------------+-------------------------------+" | tee -a $LOG_FILE
    echo ""

    # Display open service ports
    echo "[INFO] Open Service Ports:" | tee -a $LOG_FILE
    echo "+---------------------+-------------------------------+" | tee -a $LOG_FILE
    echo "|      Service        |            Port               |" | tee -a $LOG_FILE
    echo "+---------------------+-------------------------------+" | tee -a $LOG_FILE
    echo "| OpenVPN             | 80, 443, 25000, 53            |" | tee -a $LOG_FILE
    echo "| Stunnel             | 443                           |" | tee -a $LOG_FILE
    echo "| Nginx               | 81, 443                       |" | tee -a $LOG_FILE
    echo "| WebSocket           | 8080                          |" | tee -a $LOG_FILE
    echo "| Dropbear            | 80, 90, 69, 143, 2222         |" | tee -a $LOG_FILE
    echo "| BadVPN              | 7300                          |" | tee -a $LOG_FILE
    echo "| OHP                 | 9080                          |" | tee -a $LOG_FILE
    echo "+---------------------+-------------------------------+" | tee -a $LOG_FILE
    echo ""
}

# Main script execution
main() {
    display_banner
    pre_checks
    clean_system
    prompt_for_domain
    install_packages
    setup_timezone
    setup_locale
    performance_optimization
    setup_openvpn
    setup_additional_openvpn
    configure_firewall
    setup_stunnel
    setup_nginx
    setup_websocket
    setup_dropbear
    setup_badvpn
    setup_slowdns
    setup_ohp
    setup_fail2ban
    display_service_status
    echo "########################################" | tee -a $LOG_FILE
    echo "#                                      #" | tee -a $LOG_FILE
    echo "#      Setup completed successfully!   #" | tee -a $LOG_FILE
    echo "#        Enjoy your secure VPN!        #" | tee -a $LOG_FILE
    echo "#                                      #" | tee -a $LOG_FILE
    echo "########################################" | tee -a $LOG_FILE
    echo "" | tee -a $LOG_FILE
    echo "[NOTE] Please shut down or reboot your server to apply all changes." | tee -a $LOG_FILE
}

# Execute the main function
main