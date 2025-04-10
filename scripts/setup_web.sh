#!/bin/bash

# 🔄 Mise à jour du système
sudo apt-get update -y

# 🌐 Installation d'Apache
sudo apt-get install apache2 -y

# 🌍 Page d'accueil simple avec IP
echo "<html><body><h1>Bonjour depuis $(hostname) - $(hostname -I)</h1></body></html>" | sudo tee /var/www/html/index.html

# 🔧 Installation de PHP et MySQLi
echo "🌐 Installation de PHP et mysqli..."
sudo apt-get install php libapache2-mod-php php-mysql -y

# 📝 Création de la page web stylée avec formulaire
echo "📝 Création de la page web avec joli frontend..."
cat <<'EOF' | sudo tee /var/www/html/index.php
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Formulaire de test - Réplication MySQL</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #f0f2f5;
      margin: 0;
      padding: 40px;
    }
    .container {
      max-width: 600px;
      background: white;
      padding: 30px;
      margin: auto;
      border-radius: 12px;
      box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    }
    h1 {
      text-align: center;
      color: #333;
    }
    .ip {
      text-align: center;
      margin-bottom: 20px;
      color: #555;
    }
    form {
      display: flex;
      justify-content: center;
      gap: 10px;
      margin-bottom: 30px;
    }
    input[type="text"] {
      flex: 1;
      padding: 10px;
      border: 1px solid #ccc;
      border-radius: 8px;
      font-size: 16px;
    }
    button {
      padding: 10px 20px;
      background: #28a745;
      color: white;
      border: none;
      border-radius: 8px;
      cursor: pointer;
    }
    button:hover {
      background: #218838;
    }
    .message {
      color: green;
      text-align: center;
      font-weight: bold;
    }
    ul {
      list-style: none;
      padding: 0;
    }
    li {
      background: #f7f7f7;
      margin: 5px 0;
      padding: 8px;
      border-radius: 6px;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Test de Formulaire</h1>
    <div class="ip">
      Serveur : <?php echo gethostname(); ?> | IP : <?php echo $_SERVER['SERVER_ADDR']; ?>
    </div>

    <form method="post">
      <input type="text" name="nom" placeholder="Entrez un nom" required>
      <button type="submit">Envoyer</button>
    </form>

    <?php
    $conn = new mysqli('192.168.56.13', 'webuser', 'webpass', 'demo_db');

    if ($conn->connect_error) {
        die("<p style='color:red;text-align:center;'>Connexion échouée : " . $conn->connect_error . "</p>");
    }

    if (!empty($_POST['nom'])) {
        $nom = $conn->real_escape_string($_POST['nom']);
        $conn->query("INSERT INTO test_replication(nom) VALUES ('$nom')");
        echo "<p class='message'>✅ Nom ajouté : $nom</p>";
    }

    $result = $conn->query("SELECT * FROM test_replication");
    if ($result->num_rows > 0) {
        echo "<h3>Données existantes :</h3><ul>";
        while($row = $result->fetch_assoc()) {
            echo "<li>ID {$row['id']} - Nom : {$row['nom']}</li>";
        }
        echo "</ul>";
    }

    $conn->close();
    ?>
  </div>
</body>
</html>
EOF

# 🔄 Redémarrage d'Apache
sudo systemctl restart apache2

# 📦 Installation de Node Exporter pour Prometheus
echo "📦 Installation de Node Exporter..."
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
mv node_exporter-1.8.1.linux-amd64 node_exporter
rm node_exporter-1.8.1.linux-amd64.tar.gz

# 🚀 Lancement de Node Exporter en arrière-plan
/opt/node_exporter/node_exporter &

echo "✅ Serveur web prêt  sur $(hostname)"
