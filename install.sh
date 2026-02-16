#!/bin/bash

#----------------------------------------------------------#
#              HestiaCP Node.js Quick Install               #
#           https://github.com/Tayeb-Ali/hestiacp-nodejs   #
#----------------------------------------------------------#

set -e

# Colors
RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"
PREFIX="[${GREEN}hestiacp${ENDCOLOR}/${BLUE}nodejs${ENDCOLOR}]"

# Banner
show_banner() {
    echo -e "${GREEN}"
    echo "  _   _           _   _        ____ ____  "
    echo " | | | | ___  ___| |_(_) __ _ / ___|  _ \ "
    echo " | |_| |/ _ \/ __| __| |/ _\` | |   | |_) |"
    echo " |  _  |  __/\__ \ |_| | (_| | |___|  __/ "
    echo " |_| |_|\___||___/\__|_|\__,_|\____|_|    "
    echo -e "${ENDCOLOR}"
    echo -e "${BLUE}  ╔══════════════════════════════════════╗"
    echo -e "  ║   Node.js Quick Install App v2.0.0   ║"
    echo -e "  ╚══════════════════════════════════════╝${ENDCOLOR}"
    echo ""
}

# Log functions
log_success() { echo -e "${PREFIX} ${GREEN}✅ $1${ENDCOLOR}"; }
log_info()    { echo -e "${PREFIX} ${BLUE}ℹ️  $1${ENDCOLOR}"; }
log_warn()    { echo -e "${PREFIX} ${YELLOW}⚠️  $1${ENDCOLOR}"; }
log_error()   { echo -e "${PREFIX} ${RED}❌ $1${ENDCOLOR}"; }

# Check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Check if HestiaCP is installed
check_hestia() {
    if [ ! -d "/usr/local/hestia" ]; then
        log_error "HestiaCP is not installed on this server"
        log_info "Install HestiaCP first: https://hestiacp.com/install.html"
        exit 1
    fi
    log_success "HestiaCP detected"
}

# Check if Node.js is installed
check_node() {
    if command -v node &> /dev/null; then
        local node_version=$(node -v)
        log_success "Node.js detected: $node_version"
    elif command -v nvm &> /dev/null || [ -d "$HOME/.nvm" ]; then
        log_warn "NVM detected but no active Node.js version"
        log_info "Make sure to activate a Node.js version: nvm use <version>"
    else
        log_warn "Node.js is not installed"
        log_info "Install Node.js: https://github.com/nodesource/distributions"
        log_info "Or install NVM: https://github.com/nvm-sh/nvm"
    fi
}

# Check if PM2 is installed
check_pm2() {
    if command -v pm2 &> /dev/null; then
        local pm2_version=$(pm2 -v)
        log_success "PM2 detected: v$pm2_version"
    else
        log_warn "PM2 is not installed"
        log_info "Install PM2: npm install -g pm2"
    fi
}

# Install function
do_install() {
    show_banner
    check_root
    check_hestia
    check_node
    check_pm2

    echo ""
    log_info "Starting installation..."
    echo ""

    # Copy QuickInstall App
    sudo cp -r quickinstall-app/NodeJs /usr/local/hestia/web/src/app/WebApp/Installers/
    log_success "QuickInstall App copied"

    # Copy Nginx templates
    sudo cp templates/* /usr/local/hestia/data/templates/web/nginx
    log_success "Nginx templates copied"

    # Set permissions for Nginx templates
    sudo chmod 644 /usr/local/hestia/data/templates/web/nginx/NodeJS.tpl
    sudo chmod 644 /usr/local/hestia/data/templates/web/nginx/NodeJS.stpl

    # Set permissions for QuickInstall App
    sudo chmod -R 644 /usr/local/hestia/web/src/app/WebApp/Installers/NodeJs/
    sudo chmod 755 /usr/local/hestia/web/src/app/WebApp/Installers/NodeJs
    sudo chmod 755 /usr/local/hestia/web/src/app/WebApp/Installers/NodeJs/NodeJsUtils
    sudo chmod 755 /usr/local/hestia/web/src/app/WebApp/Installers/NodeJs/templates
    sudo chmod 755 /usr/local/hestia/web/src/app/WebApp/Installers/NodeJs/templates/nginx
    sudo chmod 755 /usr/local/hestia/web/src/app/WebApp/Installers/NodeJs/templates/web
    log_success "Permissions configured"

    # Copy PM2 manager script
    sudo cp bin/v-add-pm2-app /usr/local/hestia/bin
    sudo chmod 755 /usr/local/hestia/bin/v-add-pm2-app
    log_success "PM2 manager script installed"

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════${ENDCOLOR}"
    echo -e "${GREEN}   🚀 Installation completed successfully!${ENDCOLOR}"
    echo -e "${GREEN}═══════════════════════════════════════════${ENDCOLOR}"
    echo ""
    log_info "Next steps:"
    echo -e "  1. Create a web domain in HestiaCP"
    echo -e "  2. Go to Edit > Quick Install App > NodeJS"
    echo -e "  3. Set Proxy Template to 'NodeJS'"
    echo -e "  4. Upload your app to ~/web/<domain>/private/nodeapp/"
    echo ""
}

# Uninstall function
do_uninstall() {
    show_banner
    check_root

    log_info "Removing HestiaCP Node.js Quick Install App..."

    if [ -d "/usr/local/hestia/web/src/app/WebApp/Installers/NodeJs" ]; then
        sudo rm -rf /usr/local/hestia/web/src/app/WebApp/Installers/NodeJs
        log_success "QuickInstall App removed"
    fi

    if [ -f "/usr/local/hestia/data/templates/web/nginx/NodeJS.tpl" ]; then
        sudo rm -f /usr/local/hestia/data/templates/web/nginx/NodeJS.tpl
        sudo rm -f /usr/local/hestia/data/templates/web/nginx/NodeJS.stpl
        log_success "Nginx templates removed"
    fi

    if [ -f "/usr/local/hestia/bin/v-add-pm2-app" ]; then
        sudo rm -f /usr/local/hestia/bin/v-add-pm2-app
        log_success "PM2 manager script removed"
    fi

    echo ""
    log_success "Uninstallation completed"
    log_warn "Note: Running Node.js apps and PM2 processes are NOT affected"
    echo ""
}

# Main
case "${1}" in
    --uninstall|-u)
        do_uninstall
        ;;
    --help|-h)
        show_banner
        echo "Usage: sudo ./install.sh [OPTION]"
        echo ""
        echo "Options:"
        echo "  (none)          Install the Node.js Quick Install App"
        echo "  --uninstall, -u Remove the Node.js Quick Install App"
        echo "  --help, -h      Show this help message"
        echo ""
        ;;
    *)
        do_install
        ;;
esac