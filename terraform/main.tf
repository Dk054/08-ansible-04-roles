terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.184.0"
    }
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
  service_account_key_file = file("/root/authorized_key.json")
}



# 2. RESOURCE: ClickHouse VM
resource "yandex_compute_instance" "clickhouse" {
  name        = "clickhouse-vm"
  hostname    = "clickhouse-vm"
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory_gb
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = var.vm_boot_disk_size_gb
      type     = var.vm_disk_type
    }
  }

  network_interface {
    subnet_id = "e9b28iagh6b01lk19vgn"
    nat       = var.vm_enable_nat
  }

  metadata = {
    ssh-keys = "${var.vm_ssh_user}:${local.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = var.vm_preemptible
  }

  allow_stopping_for_update = var.allow_stopping_for_update
}

# 3. RESOURCE: Vector VM
resource "yandex_compute_instance" "vector" {
  name        = "vector-vm"
  hostname    = "vector-vm"
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory_gb
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = var.vm_boot_disk_size_gb
      type     = var.vm_disk_type
    }
  }

  network_interface {
    subnet_id = "e9b28iagh6b01lk19vgn"
    nat       = var.vm_enable_nat
  }

  metadata = {
    ssh-keys = "${var.vm_ssh_user}:${local.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = var.vm_preemptible
  }

  allow_stopping_for_update = var.allow_stopping_for_update
}

# 4. RESOURCE: Lighthouse VM
resource "yandex_compute_instance" "lighthouse" {
  name        = "lighthouse-vm"
  hostname    = "lighthouse-vm"
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory_gb
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = var.vm_boot_disk_size_gb
      type     = var.vm_disk_type
    }
  }

  network_interface {
    subnet_id = "e9b28iagh6b01lk19vgn"
    nat       = var.vm_enable_nat
  }

  metadata = {
    ssh-keys = "${var.vm_ssh_user}:${local.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = var.vm_preemptible
  }

  allow_stopping_for_update = var.allow_stopping_for_update
}

# 5. RESOURCE: Ansible Inventory
resource "local_file" "ansible_inventory" {
  filename = "/root/IdeaProjects/08-ansible-03-yandex/playbook/inventory/prod.yml"
  content = templatefile("${path.module}/inventory.tmpl", {
    clickhouse_ip = yandex_compute_instance.clickhouse.network_interface[0].nat_ip_address
    vector_ip     = yandex_compute_instance.vector.network_interface[0].nat_ip_address
    lighthouse_ip = yandex_compute_instance.lighthouse.network_interface[0].nat_ip_address
    vm_ssh_user   = var.vm_ssh_user
  })
}

# 6. OUTPUTS
output "vm_external_ips" {
  value = {
    "clickhouse-vm" = yandex_compute_instance.clickhouse.network_interface[0].nat_ip_address
    "vector-vm"     = yandex_compute_instance.vector.network_interface[0].nat_ip_address
    "lighthouse-vm" = yandex_compute_instance.lighthouse.network_interface[0].nat_ip_address
  }
  description = "Внешние IP-адреса ВМ для подключения"
}

output "vm_internal_ips" {
  value = {
    "clickhouse-vm" = yandex_compute_instance.clickhouse.network_interface[0].ip_address
    "vector-vm"     = yandex_compute_instance.vector.network_interface[0].ip_address
    "lighthouse-vm" = yandex_compute_instance.lighthouse.network_interface[0].ip_address
  }
  description = "Внутренние IP-адреса ВМ"
}

output "ssh_connection_commands" {
  value = [
    "ssh ${var.vm_ssh_user}@${yandex_compute_instance.clickhouse.network_interface[0].nat_ip_address} -i ${replace(var.ssh_public_key_path, ".pub", "")}",
    "ssh ${var.vm_ssh_user}@${yandex_compute_instance.vector.network_interface[0].nat_ip_address} -i ${replace(var.ssh_public_key_path, ".pub", "")}",
    "ssh ${var.vm_ssh_user}@${yandex_compute_instance.lighthouse.network_interface[0].nat_ip_address} -i ${replace(var.ssh_public_key_path, ".pub", "")}"
  ]
  description = "Команды для подключения по SSH"
}

output "configuration_summary" {
  value = <<-EOT
  Создано 3 ВМ в зоне ${var.default_zone}

  Параметры ВМ:
  - Платформа: ${var.vm_platform_id}
  - Ресурсы: ${var.vm_cores} vCPU, ${var.vm_memory_gb} ГБ RAM
  - Диск: ${var.vm_boot_disk_size_gb} ГБ (${var.vm_disk_type})
  - Тип: ${var.vm_preemptible ? "Прерываемая" : "Обычная"}
  - Публичный IP: ${var.vm_enable_nat ? "Да" : "Нет"}

  Имена ВМ: clickhouse-vm, vector-vm, lighthouse-vm

  Ansible inventory создан: ${local_file.ansible_inventory.filename}
  EOT
}