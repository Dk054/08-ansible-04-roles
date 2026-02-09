# Домашнее задание к занятию 4 «Работа с roles»

## Репозитории с roles:

1. **Vector role:** https://github.com/Dk054/vector-role
2. **Lighthouse role:** https://github.com/Dk054/lighthouse-role

## Структура проекта:

- `site-roles.yml` - основной playbook использующий roles
- `requirements.yml` - зависимости (включая внешнюю роль ClickHouse)
- `inventory/prod.yml` - пример inventory файла
- `playbook/roles/` - директория для скачанных ролей

1. Установить зависимости:
   ```bash
   ansible-galaxy install -r requirements.yml -p playbook/roles/

2. Запустить playbook:
- ansible-playbook -i inventory/prod.yml site-roles.yml
Роли:
- ClickHouse
  Используется внешняя роль: git@github.com:AlexeySetevoi/ansible-clickhouse.git
- Vector
  Собственная роль: устанавливает Vector log aggregator
- Lighthouse
  Собственная роль: устанавливает веб-интерфейс Lighthouse