# HestiaCP Node.js Quick Install App

> Deploy and manage multiple Node.js applications on [HestiaCP](https://hestiacp.com/) with ease. Each app runs on its own port with PM2 process management, Nginx reverse proxy, and optional NVM support.

<p align="center">
  <img src="quickinstall-app/NodeJs/nodejs.png" alt="Node.js" width="80">
</p>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Directory Structure](#-directory-structure)
- [Permissions & Users](#-permissions--users)
- [Configuration Details](#-configuration-details)
- [Troubleshooting](#-troubleshooting)
- [Uninstallation](#-uninstallation)
- [FAQ](#-faq)
- [Changelog](#-changelog)
- [License](#-license)

---

## 🔍 Overview

This plugin adds a **Node.js Quick Install App** to HestiaCP's web interface, allowing you to:

- ✅ Deploy multiple Node.js apps on the same server with different ports
- ✅ Automatic Nginx reverse proxy configuration (HTTP & HTTPS)
- ✅ PM2 process management with auto-restart and memory limits
- ✅ NVM support for per-app Node.js version management
- ✅ Automatic `.env` file with port configuration
- ✅ Security headers and `.env`/`.git` access protection

### Supported Versions

| Component    | Supported Versions                        |
|:-------------|:------------------------------------------|
| HestiaCP     | 1.8.x, 1.9.x (tested on 1.9.4)          |
| Node.js LTS  | v24.11.0 (Active), v22.21.0 (Maintenance), v20.20.0 (Maintenance) |
| PHP          | 8.1, 8.2, 8.3, 8.4                       |
| Nginx        | 1.18+ (HTTP/2 modern syntax for 1.25.1+) |
| PM2          | 5.x+                                      |

---

## 🏗️ Architecture

When you install a Node.js app via the Quick Install interface, the plugin performs the following:

```
┌──────────────────────────────────────────────────────────┐
│                    HestiaCP Server                       │
│                                                          │
│  ┌─────────────┐     ┌──────────────┐     ┌──────────┐  │
│  │   Client     │────▶│    Nginx     │────▶│ Node.js  │  │
│  │   Browser    │◀────│  (Reverse    │◀────│   App    │  │
│  │              │     │   Proxy)     │     │ (PM2)    │  │
│  └─────────────┘     └──────────────┘     └──────────┘  │
│                                                          │
│  Port 80/443 ──────▶ Proxy Pass ──────▶ Port 3000+      │
│                                                          │
│  Files:                                                  │
│  /home/<user>/web/<domain>/private/nodeapp/  (App)       │
│  /home/<user>/hestiacp_nodejs_config/        (Config)    │
│  /usr/local/hestia/data/templates/web/nginx/ (Templates) │
└──────────────────────────────────────────────────────────┘
```

**Flow:**
1. Client sends HTTP/HTTPS request to your domain
2. Nginx receives it and proxies to `127.0.0.1:<PORT>`
3. PM2 manages your Node.js app process on that port
4. Response flows back through Nginx to the client

---

## 📦 Requirements

### System Requirements
- **OS**: Ubuntu 20.04+ / Debian 11+ (64-bit)
- **HestiaCP**: Version 1.8.x or 1.9.x installed and running
- **Access**: Root (sudo) access via SSH

### Software Prerequisites

#### 1. Node.js (Required)
Install using one of these methods:

**Option A: NodeSource (system-wide)**
```bash
# Node.js 24.x LTS (Recommended)
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Option B: NVM (per-user version management)**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install 24
```

#### 2. PM2 (Required)
```bash
sudo npm install -g pm2
```

#### 3. PM2 Startup (Recommended)
Ensures PM2 restarts your apps automatically after server reboot:
```bash
pm2 startup
# Follow the printed command, then:
pm2 save
```

---

## 🚀 Installation

### Step 1: Clone the Repository
```bash
cd /tmp
git clone https://github.com/Tayeb-Ali/hestiacp-nodejs.git
cd hestiacp-nodejs
```

### Step 2: Run the Installer
```bash
sudo chmod 755 install.sh
sudo ./install.sh
```

The installer will:
- ✅ Verify HestiaCP is installed
- ✅ Check for Node.js and PM2
- ✅ Copy Quick Install App files to HestiaCP
- ✅ Copy Nginx proxy templates
- ✅ Set correct file permissions
- ✅ Install PM2 manager script

### Step 3: Verify Installation
Log into HestiaCP → Web → Edit any domain → You should see **Quick Install App** with **NodeJS** option.

---

## 📖 Usage

### Creating a New Node.js App

#### 1. Create a User (if needed)
- Go to **HestiaCP** → **Users** → **Add User**
- Or use an existing user

#### 2. Enable Bash Access
> ⚠️ **Important**: The user MUST have bash access for PM2 to work.

- Go to **Users** → **Edit User** → **Advanced Options**
- Set **SSH Access** → **bash**

#### 3. Create a Web Domain
- Go to **Web** → **Add Web Domain**
- Enter your domain (e.g., `app.example.com`)

#### 4. Install Node.js via Quick Install
- Go to **Web** → **Edit** your domain → **Quick Install App**
- Select **NodeJS** and configure:

| Field            | Description                                                          | Example                |
|:-----------------|:---------------------------------------------------------------------|:-----------------------|
| **Node Version** | Creates `.nvmrc` file for NVM users (ignored if using system Node)   | `v24.11.0`             |
| **Start Script** | The PM2 startup command (matches your `package.json` scripts)        | `npm run start`        |
| **Port**         | Unique port for this app (different port per app)                    | `3000`                 |
| **PHP Version**  | Required by HestiaCP form, can be any value **(NOT IMPORTANT)**      | `8.2`                  |

#### 5. Set Proxy Template
- Go to **Web** → **Edit** your domain → **Advanced Options**
- Set **Proxy Template** → **NodeJS**

#### 6. Upload Your App
Upload your Node.js application to:
```
/home/<user>/web/<domain>/private/nodeapp/
```

Methods:
- **File Manager**: Use HestiaCP's built-in file manager
- **SFTP**: Connect via SFTP client (FileZilla, WinSCP)
- **Git**: SSH into the server and clone directly
  ```bash
  cd /home/<user>/web/<domain>/private/nodeapp/
  git clone <your-repo-url> .
  npm install --production
  ```

#### 7. Start Your App
Your app should start automatically via PM2. If not:
```bash
cd /home/<user>/web/<domain>/private/nodeapp/
pm2 start ecosystem.config.js
pm2 save
```

🎉 **Done!** Your app is now accessible at your domain.

---

## 📁 Directory Structure

After installation, the following structure is created:

```
/home/<user>/
├── web/
│   └── <domain>/
│       ├── private/
│       │   └── nodeapp/              # ← Your Node.js app goes here
│       │       ├── ecosystem.config.js   # PM2 configuration (auto-generated)
│       │       ├── .nvmrc                # Node.js version for NVM (auto-generated)
│       │       ├── .env                  # PORT variable (auto-generated)
│       │       ├── package.json          # Your app's package.json
│       │       └── ...                   # Your app files
│       └── public_html/
│           └── app.conf              # HestiaCP app detection marker
│
└── hestiacp_nodejs_config/
    └── web/
        └── <domain>/
            ├── nodejs-app.conf           # Nginx proxy configuration
            ├── nodejs-app-fallback.conf  # Nginx fallback configuration
            └── .conf                     # App settings backup
```

### HestiaCP System Files

```
/usr/local/hestia/
├── web/src/app/WebApp/Installers/
│   └── NodeJs/                       # Quick Install App
│       ├── NodeJsSetup.php               # Main installer class
│       ├── nodejs.png                    # App icon
│       ├── NodeJsUtils/
│       │   ├── NodeJsPaths.php           # Path utilities
│       │   └── NodeJsUtil.php            # File/template utilities
│       └── templates/
│           ├── nginx/
│           │   ├── nodejs-app.tpl        # Proxy config template
│           │   └── nodejs-app-fallback.tpl  # Fallback template
│           └── web/
│               └── entrypoint.tpl        # ecosystem.config.js template
├── data/templates/web/nginx/
│   ├── NodeJS.tpl                    # HTTP Nginx template
│   └── NodeJS.stpl                   # HTTPS Nginx template
└── bin/
    └── v-add-pm2-app                 # PM2 app manager script
```

---

## 🔐 Permissions & Users

### Who Should Install This Plugin?

| Action                      | Required User   | Why                                           |
|:----------------------------|:----------------|:----------------------------------------------|
| Run `install.sh`            | **root**        | Copies files to `/usr/local/hestia/`          |
| Create web domain           | HestiaCP admin  | Admin panel access required                   |
| Upload Node.js app          | Domain owner    | Files go to user's home directory             |
| Manage PM2 processes        | Domain owner    | PM2 runs under the user context               |

### File Permissions

| Path                                    | Permission | Owner         |
|:----------------------------------------|:-----------|:--------------|
| Quick Install App (`NodeJs/`)           | 755/644    | root:root     |
| Nginx templates (`.tpl`, `.stpl`)       | 644        | root:root     |
| `v-add-pm2-app`                         | 755        | root:root     |
| User's `nodeapp/` directory             | 755        | user:user     |
| User's config directory                 | 755        | user:user     |

### SSH Access Requirement

PM2 requires bash access for the user. Without it, PM2 commands fail:

```
HestiaCP → Users → Edit User → Advanced Options → SSH Access → bash
```

> ⚠️ Only enable bash access for users who need to run Node.js apps. Regular website users should keep the default `nologin` setting.

---

## ⚙️ Configuration Details

### ecosystem.config.js (Auto-Generated)

```javascript
module.exports = {
    apps : [{
        name   : 'example.com',
        script : 'npm run start',
        cwd    : '/home/user/web/example.com/private/nodeapp',
        env    : {
            NODE_ENV : 'production',
            PORT     : '3000'
        },
        watch  : false,
        max_memory_restart : '512M',
        instances : 1,
        autorestart : true
    }]
}
```

**Customizable fields:**
- `watch`: Set to `true` for auto-restart on file changes (development only)
- `max_memory_restart`: Increase for memory-heavy apps
- `instances`: Set to `'max'` for cluster mode

### .env (Auto-Generated)

```env
PORT="3000"
```

Your app should read this port:
```javascript
const port = process.env.PORT || 3000;
app.listen(port);
```

### Changing the Port

1. Change Proxy Template to **default** (in Web → Edit → Advanced Options)
2. Re-run Quick Install App with the new port
3. Change Proxy Template back to **NodeJS**

---

## 🔧 Troubleshooting

### App Not Accessible

1. **Check PM2 status**:
   ```bash
   pm2 list
   pm2 logs <app-name>
   ```

2. **Check if the port is correct**:
   ```bash
   cat ~/hestiacp_nodejs_config/web/<domain>/nodejs-app.conf
   # Should show: proxy_pass http://127.0.0.1:<YOUR_PORT>;
   ```

3. **Check Nginx configuration**:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

4. **Verify Proxy Template**:
   - Go to HestiaCP → Web → Edit domain → Advanced Options
   - Proxy Template must be set to **NodeJS**

### PM2 Won't Start

1. **Check bash access** for the user (see [Permissions & Users](#-permissions--users))
2. **Check Node.js installation**:
   ```bash
   node -v
   npm -v
   ```
3. **Re-start manually**:
   ```bash
   cd /home/<user>/web/<domain>/private/nodeapp/
   pm2 start ecosystem.config.js
   pm2 save
   ```

### 502 Bad Gateway

This usually means your Node.js app crashed or is not running:
```bash
pm2 list          # Check if app is 'online'
pm2 logs          # Check for errors
pm2 restart all   # Restart all apps
```

### SSL/HTTPS Not Working

1. Enable SSL in HestiaCP → Web → Edit domain → SSL
2. Make sure **Proxy Template** is set to **NodeJS** (not the default)

---

## 🗑️ Uninstallation

### Remove the Plugin
```bash
cd /tmp/hestiacp-nodejs
sudo ./install.sh --uninstall
```

This removes:
- Quick Install App files from HestiaCP
- Nginx templates
- PM2 manager script

> **Note**: This does NOT remove your running Node.js apps, PM2 processes, or user data.

### Remove a Single Domain's App
1. Remove the domain in HestiaCP normally
2. Clean up the config directory:
   ```bash
   rm -rf ~/hestiacp_nodejs_config/web/<domain>
   ```
3. Stop PM2 process:
   ```bash
   pm2 delete <domain-name>
   pm2 save
   ```

---

## ❓ FAQ

### Can I run multiple Node.js apps?
**Yes!** Each app uses a different port. Create a new domain, install the Quick Install App with a unique port (3000, 3001, 3002, etc.).

### Do I need PHP for Node.js apps?
**No.** The PHP version field in the Quick Install form is a HestiaCP requirement. You can select any version — it won't affect your Node.js app.

### Can I use a framework like Next.js, Nuxt, or Express?
**Yes!** Any Node.js application that listens on a port works. Just set the correct `start_script` in the Quick Install form (e.g., `npm run start`, `node server.js`).

### How do I update my app?
```bash
cd /home/<user>/web/<domain>/private/nodeapp/
git pull  # or upload new files
npm install --production
pm2 restart <app-name>
```

### How do I view app logs?
```bash
pm2 logs <app-name>       # Real-time logs
pm2 logs <app-name> --lines 100  # Last 100 lines
```

### What happens after server reboot?
If you ran `pm2 startup` and `pm2 save`, your apps restart automatically. If not:
```bash
pm2 startup
pm2 save
```

### Can I use WebSockets?
**Yes!** The Nginx proxy template is configured to support WebSocket connections with the `Upgrade` and `Connection` headers.

---

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes.

---

## 📄 License

This project is licensed under the GNU General Public License v3.0 — see the [LICENSE](LICENSE) file for details.
