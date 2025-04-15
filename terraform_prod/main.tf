resource "yandex_vpc_network" "sockshop_network" {
  name = "sockshop-network"
}

resource "yandex_vpc_subnet" "sockshop_subnet" {
  name           = "sockshop-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.sockshop_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "swarm_nodes" {
  count       = var.vm_count
  name        = count.index == 0 ? "manager" : "worker-${count.index}" #"${var.vm_name_prefix}-${count.index}"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sockshop_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${var.public_ssh_key}"
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ${var.vm_user}
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh-authorized-keys:
            - ${var.public_ssh_key}
      EOF
  }
}

resource "null_resource" "configure_swarm" {
  depends_on = [yandex_compute_instance.swarm_nodes]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -qq",
      "sudo apt-get install -y docker.io",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo docker swarm init --advertise-addr ${yandex_compute_instance.swarm_nodes[0].network_interface.0.ip_address}",
      "sudo docker swarm join-token -q worker | sudo tee /home/user/swarm_token",
      "sudo chmod 0400 /home/user/swarm_token",
      "sudo chown user:user /home/user/swarm_token",
    ]

    connection {
      type        = "ssh"
      user        = var.vm_user
      private_key = file("/home/user/.ssh/yandex_terraform")
      host        = yandex_compute_instance.swarm_nodes[0].network_interface.0.nat_ip_address
      timeout     = "10m"
    }
  }
}

resource "null_resource" "join_workers" {
  count      = var.vm_count - 1
  depends_on = [null_resource.configure_swarm]

  triggers = {
    swarm_token = null_resource.configure_swarm.id
    manager_ip = yandex_compute_instance.swarm_nodes[0].network_interface.0.ip_address
  }

  provisioner "file" {
    source      = "/home/user/.ssh/yandex_terraform"
    destination = "/tmp/yandex_terraform"

    connection {
      type        = "ssh"
      user        = var.vm_user
      private_key = file("/home/user/.ssh/yandex_terraform")
      host        = yandex_compute_instance.swarm_nodes[count.index + 1].network_interface.0.nat_ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/user/.ssh",
      "sudo chown user:user /home/user/.ssh",
      "sudo chmod 700 /home/user/.ssh",
      "sudo mv /tmp/yandex_terraform /home/user/.ssh/",
      "sudo chmod 600 /home/user/.ssh/yandex_terraform",
      "sudo apt-get update -qq",
      "sudo apt-get install -y docker.io",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "ssh -i /home/user/.ssh/yandex_terraform -o StrictHostKeyChecking=no -o ConnectTimeout=5 ${var.vm_user}@${yandex_compute_instance.swarm_nodes[0].network_interface.0.nat_ip_address} 'cat /home/user/swarm_token' | sudo tee /tmp/swarm_token",
      "sudo docker swarm join --token $(cat /tmp/swarm_token) ${yandex_compute_instance.swarm_nodes[0].network_interface.0.ip_address}:2377"
    ]

    connection {
      type        = "ssh"
      user        = var.vm_user
      private_key = file("/home/user/.ssh/yandex_terraform")
      host        = yandex_compute_instance.swarm_nodes[count.index + 1].network_interface.0.nat_ip_address
      timeout     = "15m"
    }
  }
}

resource "null_resource" "deploy_sockshop" {
  depends_on = [
    null_resource.configure_swarm,
    null_resource.join_workers
  ]

  triggers = {
    swarm_ready = sha1(join("", [for inst in yandex_compute_instance.swarm_nodes : inst.network_interface.0.ip_address]))
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/user/sockshop",
      "git clone https://github.com/SkillfactoryCoding/DEVOPS-Kubernates-microservices-demo.git /home/user/sockshop/source || true",
      "cp /home/user/sockshop/source/deploy/docker-compose/docker-compose.yml /home/user/sockshop/",
      "sed -i 's/version: .*/version: \"3.6\"/' /home/user/sockshop/docker-compose.yml",
      "sudo usermod -aG docker ${var.vm_user}",
      "exec sudo -u ${var.vm_user} bash -c 'docker stack deploy -c /home/user/sockshop/docker-compose.yml sockshop'",
      "sleep 30",
      "docker service ls"
    ]

    connection {
      type        = "ssh"
      user        = var.vm_user
      private_key = file("/home/user/.ssh/yandex_terraform")
      host        = yandex_compute_instance.swarm_nodes[0].network_interface.0.nat_ip_address
      timeout     = "20m"
    }
  }
}

output "manager_public_ip" {
  value = yandex_compute_instance.swarm_nodes[0].network_interface.0.nat_ip_address
}

output "sockshop_url" {
  value = "http://${yandex_compute_instance.swarm_nodes[0].network_interface.0.nat_ip_address}"
}
