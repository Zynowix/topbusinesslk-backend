#!/usr/bin/env bash
set -e

# ==============================================================================
# TopBusiness.lk — Hostinger VPS Automated Deployment Script
# ==============================================================================

echo ">>> [1/7] Updating system and installing dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install -y curl git ufw

# Install Node.js 20 LTS if not present
if ! command -v node >/dev/null 2>&1; then
    echo ">>> Installing Node.js 20 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi

# Install PM2 and Nginx
if ! command -v pm2 >/dev/null 2>&1; then
    echo ">>> Installing PM2..."
    npm install -g pm2
fi

if ! command -v nginx >/dev/null 2>&1; then
    echo ">>> Installing Nginx..."
    apt install -y nginx
fi

echo ">>> [2/7] Preparing web directory..."
mkdir -p /var/www
cd /var/www

# Clone or pull latest frontend
if [ ! -d "/var/www/topbusinesslk-frontend" ]; then
    echo ">>> Cloning frontend repository..."
    git clone https://github.com/Zynowix/topbusinesslk-frontend.git
    cd topbusinesslk-frontend
else
    echo ">>> Pulling latest changes..."
    cd /var/www/topbusinesslk-frontend
    git fetch origin main
    git reset --hard origin/main
fi

echo ">>> [3/7] Setting up live Supabase environment variables..."
cat << 'EOF' > .env.local
NEXT_PUBLIC_SUPABASE_URL=https://rodoltevqllzmbohitrr.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvZG9sdGV2cWxsem1ib2hpdHJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg4MzYxODUsImV4cCI6MjEwNDQxMjE4NX0.3FdY7bRRi4S3MT8wgrAMtPfWgLy1tqRxIwDImUQ-Ex8
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvZG9sdGV2cWxsem1ib2hpdHJyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4ODgzNjE4NSwiZXhwIjoyMTA0NDEyMTg1fQ.5EPyw4AeS5HAJedsw8lZCZQVj138KWoOxe_i4JHPkm4
NEXT_PUBLIC_ADMIN_PASSCODE=topbiz2026
EOF

echo ">>> [4/7] Installing npm packages..."
npm install

echo ">>> [5/7] Building Next.js production bundle..."
npm run build

echo ">>> [6/7] Managing PM2 process..."
if pm2 describe topbusiness >/dev/null 2>&1; then
    echo ">>> Reloading existing PM2 process..."
    pm2 reload topbusiness --update-env
else
    echo ">>> Starting new PM2 process..."
    pm2 start npm --name "topbusiness" -- start
fi
pm2 save
pm2 startup systemd -u root --hp /root || true

echo ">>> [7/7] Configuring Nginx reverse proxy..."
cat << 'EOF' > /etc/nginx/sites-available/topbusiness
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Enable site if not already enabled
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/topbusiness /etc/nginx/sites-enabled/topbusiness
nginx -t
systemctl restart nginx

echo "===================================================================="
echo ">>> SUCCESS! TopBusiness.lk is live at: http://72.61.213.191"
echo "===================================================================="
