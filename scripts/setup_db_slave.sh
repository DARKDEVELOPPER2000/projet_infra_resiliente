#!/bin/bash

echo "📦 Mise à jour et installation de MySQL..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install mysql-server -y

echo "⚙️ Configuration du serveur MySQL pour la réplication (SLAVE)..."

# Modifier la configuration MySQL
sudo sed -i "/^bind-address/s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf > /dev/null <<EOF

server-id=2
relay-log=/var/log/mysql/mysql-relay-bin.log
log_bin=/var/log/mysql/mysql-bin.log
binlog_do_db=demo_db
EOF

# Redémarrer MySQL
sudo systemctl restart mysql

echo "🛠️ Configuration du SLAVE pour se connecter au MASTER..."

# Attendre que le master soit prêt (sécurité)
sleep 10

# Connexion au master pour récupérer les infos de binlog
MASTER_STATUS=$(mysql -h 192.168.56.13 -u root -e "SHOW MASTER STATUS\\G")
LOG_FILE=$(echo "$MASTER_STATUS" | grep File: | awk '{print $2}')
LOG_POS=$(echo "$MASTER_STATUS" | grep Position: | awk '{print $2}')

# Lancer la réplication
sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS demo_db;
STOP SLAVE;
CHANGE MASTER TO
  MASTER_HOST='192.168.56.13',
  MASTER_USER='replica',
  MASTER_PASSWORD='replica_pass',
  MASTER_LOG_FILE='$LOG_FILE',
  MASTER_LOG_POS=$LOG_POS;
START SLAVE;
EOF

echo "✅ Serveur SLAVE connecté au MASTER !"

# 🧩 Partie supervision : installation de Node Exporter

echo "📦 Installation de Node Exporter..."
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
mv node_exporter-1.8.1.linux-amd64 node_exporter
rm node_exporter-1.8.1.linux-amd64.tar.gz

echo "🚀 Lancement de Node Exporter..."
/opt/node_exporter/node_exporter &

echo "✅ Node Exporter installé et lancé sur $(hostname)"
