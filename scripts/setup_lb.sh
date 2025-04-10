# #!/bin/bash
# echo "📦 Installation de Node Exporter..."
# cd /opt
# wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
# tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
# mv node_exporter-1.8.1.linux-amd64 node_exporter
# rm node_exporter-1.8.1.linux-amd64.tar.gz
# /opt/node_exporter/node_exporter &
#!/bin/bash

echo "📦 Mise à jour et installation de Nginx..."
sudo apt-get update -y
sudo apt-get install nginx -y

echo "⚙️ Configuration de Nginx comme Load Balancer..."

sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
upstream backend {
    server 192.168.56.11;
    server 192.168.56.12;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;
    }
}
EOF

echo "🔄 Redémarrage de Nginx..."
sudo systemctl restart nginx
sudo systemctl enable nginx

echo "📦 Installation de Node Exporter..."
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
mv node_exporter-1.8.1.linux-amd64 node_exporter
rm node_exporter-1.8.1.linux-amd64.tar.gz

echo "🚀 Lancement de Node Exporter..."
/opt/node_exporter/node_exporter &

echo "✅ Load Balancer prêt et supervisé !"
