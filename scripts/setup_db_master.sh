#!/bin/bash

echo "📦 Mise à jour et installation de MySQL..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install mysql-server -y

echo "⚙️ Configuration du serveur MySQL pour la réplication..."

# Modifier la config de MySQL pour activer la réplication
sudo sed -i "/^bind-address/s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf > /dev/null <<EOF

server-id=1
log_bin=/var/log/mysql/mysql-bin.log
binlog_do_db=demo_db
EOF

# Redémarrer MySQL
sudo systemctl restart mysql

echo "🛠️ Création de la base de données et d'un utilisateur de réplication..."

sudo mysql <<EOF
CREATE DATABASE demo_db;
CREATE USER 'replica'@'%' IDENTIFIED BY 'replica_pass';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
FLUSH PRIVILEGES;
EOF

echo "✅ Serveur MASTER prêt pour la réplication."

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
