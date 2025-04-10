#!/bin/bash

echo "📦 Mise à jour du système..."
sudo apt-get update -y

echo "📥 Installation de Prometheus..."
cd /opt
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.48.1/prometheus-2.48.1.linux-amd64.tar.gz
sudo tar xvf prometheus-2.48.1.linux-amd64.tar.gz
sudo mv prometheus-2.48.1.linux-amd64 prometheus
sudo rm prometheus-2.48.1.linux-amd64.tar.gz

# Ajouter une config simple
sudo tee /opt/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'vms'
    static_configs:
      - targets: ['192.168.56.10:9100', '192.168.56.11:9100', '192.168.56.12:9100']
EOF

echo "🚀 Lancement de Prometheus..."
nohup /opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml > /dev/null 2>&1 &

echo "📥 Installation de Grafana..."
sudo apt-get install -y apt-transport-https software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update -y
sudo apt-get install -y grafana

echo "🚀 Lancement de Grafana..."
sudo systemctl daemon-reexec
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
