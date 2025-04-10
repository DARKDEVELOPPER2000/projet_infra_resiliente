Vagrant.configure("2") do |config|
  machines = {
    "lb" => "192.168.56.10",
    "web1" => "192.168.56.11",
    "web2" => "192.168.56.12",
    "db-master" => "192.168.56.13",
    "db-slave" => "192.168.56.14",
    "monitoring" => "192.168.56.15",
    "client" => "192.168.56.16"
  }

  machines.each do |name, ip|
    config.vm.define name do |machine|
      machine.vm.box = "ubuntu/bionic64"
      machine.vm.hostname = name
      machine.vm.network "private_network", ip: ip

      # ✅ Port forwarding pour l'accès depuis le navigateur
      if name == "lb"
        machine.vm.network "forwarded_port", guest: 80, host: 8080   # Load Balancer
      elsif name == "monitoring"
        machine.vm.network "forwarded_port", guest: 9090, host: 9090 # Prometheus
        machine.vm.network "forwarded_port", guest: 3000, host: 3000 # Grafana
      end

      machine.vm.provider "virtualbox" do |vb|
        vb.memory = 512
        vb.cpus = 1
      end

      # 🎯 Provisioning par script adapté
      if name == "db-master"
        machine.vm.provision "shell", path: "scripts/setup_db_master.sh"
      elsif name == "db-slave"
        machine.vm.provision "shell", path: "scripts/setup_db_slave.sh"
      else
        machine.vm.provision "shell", path: "scripts/setup_#{name}.sh"
      end
    end
  end
end
