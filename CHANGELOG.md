# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-02-16

### ⬆️ Updated
- **Node.js versions**: Updated to current LTS releases (v24.11.0, v22.21.0, v20.20.0)
- **PHP versions**: Updated supported PHP versions to 8.1, 8.2, 8.3, 8.4
- **Nginx SSL template**: Migrated from deprecated `http2` listen parameter to `http2 on;` directive (Nginx 1.25.1+)
- **Nginx gzip**: Added modern content types (`application/json`, `application/javascript`)
- **PM2 ecosystem config**: Enhanced with `NODE_ENV`, `PORT`, memory limits, and auto-restart settings

### 🐛 Fixed
- **Fallback proxy template**: Fixed malformed URL (`http://127.0.0.1:%port%:/$1` → `http://127.0.0.1:%port%`)
- **Nginx proxy headers**: Added missing `X-Forwarded-Proto` and `X-Forwarded-Host` headers
- **Proxy timeouts**: Added `proxy_connect_timeout`, `proxy_send_timeout`, `proxy_read_timeout`

### 🔒 Security
- Added security headers: `X-Frame-Options`, `X-Content-Type-Options`, `X-XSS-Protection`
- Added `.env` file access protection in Nginx templates
- Added PM2 and entrypoint existence checks in `v-add-pm2-app`

### 🆕 Added
- **Install script**: Root check, HestiaCP check, Node.js/PM2 detection
- **Uninstall option**: `./install.sh --uninstall` to cleanly remove the plugin
- **Help option**: `./install.sh --help` for usage information
- **CHANGELOG.md**: This file

### 📝 Documentation
- Complete README.md rewrite with detailed sections:
  - System requirements and prerequisites
  - Step-by-step installation guide
  - Architecture and directory structure
  - Permissions and user management
  - Troubleshooting guide
  - FAQ

## [1.0.0] - Initial Release

### Added
- Initial Node.js Quick Install App for HestiaCP
- Nginx proxy templates (HTTP and SSL)
- PM2 ecosystem.config.js generation
- NVM support with .nvmrc
- Port-based multi-app support
