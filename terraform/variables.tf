# ==================== ОБЯЗАТЕЛЬНЫЕ ПЕРЕМЕННЫЕ ====================
variable "cloud_id" {
  type        = string
  default     = "b1gsjth4p4d9mq314dsk"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1gsugenqt9rfairour5"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

# ==================== НАСТРОЙКИ СЕТИ ====================
variable "network_name" {
  description = "Имя создаваемой VPC сети"
  type        = string
  default     = "default-network"
}

variable "subnet_name" {
  description = "Имя создаваемой подсети"
  type        = string
  default     = "default-subnet"
}

variable "default_zone" {
  description = "Зона доступности для всех ресурсов"
  type        = string
  default     = "ru-central1-a"
  validation {
    condition     = can(regex("^ru-central1-[a-d]$", var.default_zone))
    error_message = "Зона должна быть в формате ru-central1-[a-d]"
  }
}

variable "subnet_cidr" {
  description = "CIDR блок для подсети"
  type        = string
  default     = "10.0.1.0/24"
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Должен быть валидный CIDR блок (например, 10.0.1.0/24)"
  }
}

# ==================== НАСТРОЙКИ ВМ ====================
variable "vm_count" {
  description = "Количество создаваемых ВМ"
  type        = number
  default     = 1
  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10
    error_message = "Количество ВМ должно быть от 1 до 10"
  }
}

variable "vm_name_prefix" {
  description = "Префикс имени ВМ (будет vm-1, vm-2 и т.д.)"
  type        = string
  default     = "vm"
}

variable "vm_hostname_prefix" {
  description = "Префикс hostname ВМ"
  type        = string
  default     = "vm"
}

variable "vm_platform_id" {
  description = "Платформа для ВМ"
  type        = string
  default     = "standard-v3"
  validation {
    condition     = contains(["standard-v1", "standard-v2", "standard-v3"], var.vm_platform_id)
    error_message = "Допустимые платформы: standard-v1, standard-v2, standard-v3"
  }
}

# ==================== РЕСУРСЫ ВМ ====================
variable "vm_cores" {
  description = "Количество ядер CPU для каждой ВМ"
  type        = number
  default     = 2
  validation {
    condition     = var.vm_cores >= 1 && var.vm_cores <= 8
    error_message = "Количество ядер должно быть от 1 до 8"
  }
}

variable "vm_memory_gb" {
  description = "Объем оперативной памяти в ГБ для каждой ВМ"
  type        = number
  default     = 1
  validation {
    condition     = var.vm_memory_gb >= 1 && var.vm_memory_gb <= 16
    error_message = "Объем памяти должен быть от 1 до 16 ГБ"
  }
}

variable "vm_core_fraction" {
  description = "Гарантированная доля ядра в процентах"
  type        = number
  default     = 20
  validation {
    condition     = contains([20, 50, 100], var.vm_core_fraction)
    error_message = "Допустимые значения: 20, 50, 100 для standard-v3"
  }
}

# ==================== ДИСКИ ВМ ====================
variable "vm_image_id" {
  description = "ID образа ОС для ВМ"
  type        = string
  default     = "fd8vmcue7aajpmeo39kk" # Ubuntu 22.04 LTS
}

variable "vm_disk_type" {
  description = "Тип загрузочного диска"
  type        = string
  default     = "network-hdd"
  validation {
    condition     = contains(["network-hdd", "network-ssd", "network-ssd-nonreplicated"], var.vm_disk_type)
    error_message = "Допустимые типы дисков: network-hdd, network-ssd, network-ssd-nonreplicated"
  }
}

variable "vm_boot_disk_size_gb" {
  description = "Размер загрузочного диска в ГБ"
  type        = number
  default     = 10
  validation {
    condition     = var.vm_boot_disk_size_gb >= 10 && var.vm_boot_disk_size_gb <= 100
    error_message = "Размер диска должен быть от 10 до 100 ГБ"
  }
}

# ==================== СЕТЕВЫЕ НАСТРОЙКИ ====================
variable "vm_enable_nat" {
  description = "Включить публичный IP-адрес (NAT) для ВМ"
  type        = bool
  default     = true
}

# ==================== SSH ДОСТУП ====================
variable "vm_ssh_user" {
  description = "Имя пользователя для SSH доступа"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Путь к файлу с публичным SSH-ключом"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  validation {
    condition     = fileexists(pathexpand(var.ssh_public_key_path))
    error_message = "Файл с SSH-ключом не найден по указанному пути"
  }
}

# ==================== ЭКОНОМИЯ/НАДЕЖНОСТЬ ====================
variable "vm_preemptible" {
  description = "Создавать прерываемые ВМ для экономии средств"
  type        = bool
  default     = true
}

variable "allow_stopping_for_update" {
  description = "Разрешить остановку ВМ для обновления конфигурации"
  type        = bool
  default     = true
}

# ==================== ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ ====================
locals {
  # Чтение SSH-ключа из файла
  ssh_public_key = file(pathexpand(var.ssh_public_key_path))

  # Формирование полных имен ВМ
  vm_names = [
    for i in range(var.vm_count) :
    "${var.vm_name_prefix}-${i + 1}"
  ]

  vm_hostnames = [
    for i in range(var.vm_count) :
    "${var.vm_hostname_prefix}-${i + 1}"
  ]
}