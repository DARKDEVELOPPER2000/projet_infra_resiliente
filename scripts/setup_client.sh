#!/bin/bash

echo "📦 Mise à jour du système..."
sudo apt-get update -y

echo "🌐 Installation des outils de test : curl, mysql-client..."
sudo apt-get install -y curl mysql-client

echo "🧪 Test de connectivité :"

# Test Web 1
echo -e "\n➡️ curl vers web1 (192.168.56.11)"
curl -s http://192.168.56.11 | grep Bonjour

# Test Web 2
echo -e "\n➡️ curl vers web2 (192.168.56.12)"
curl -s http://192.168.56.12 | grep Bonjour

# Test LB
echo -e "\n➡️ curl vers le load balancer (192.168.56.10)"
curl -s http://192.168.56.10 | grep Bonjour

# Test Prometheus
echo -e "\n➡️ curl vers Prometheus (192.168.56.15:9090)"
curl -s http://192.168.56.15:9090 | grep Prometheus || echo "OK (page sans HTML)"

# Test Grafana
echo -e "\n➡️ curl vers Grafana (192.168.56.15:3000)"
curl -s http://192.168.56.15:3000 | grep Grafana || echo "OK (page sans HTML)"

# Test MySQL Master
echo -e "\n➡️ Test de connexion MySQL (db-master)"
mysql -h 192.168.56.13 -u webuser -pwebpass -e "SHOW DATABASES;" 2>/dev/null

# 📈 Node Exporter
echo "📈 Installation de Node Exporter pour supervision..."
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
mv node_exporter-1.8.1.linux-amd64 node_exporter
rm node_exporter-1.8.1.linux-amd64.tar.gz

echo "🚀 Lancement de Node Exporter..."
/opt/node_exporter/node_exporter &

echo "✅ Client prêt et supervisé !"
