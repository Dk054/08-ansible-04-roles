В этой папке находятся файлы для создания двух вм
с параметрами
Создано 2 ВМ в зоне ru-central1-a

Параметры ВМ:
- Платформа: standard-v3
- Ресурсы: 2 vCPU, 1 ГБ RAM
- Диск: 10 ГБ (network-hdd)
- Тип: Прерываемая
- Публичный IP: Да

Имена ВМ: vm-1, vm-2

EOT
ssh_connection_commands = [
"ssh ubuntu@89.169.149.50 -i ~/.ssh/id_rsa",
"ssh ubuntu@89.169.137.127 -i ~/.ssh/id_rsa",
]