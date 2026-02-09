# Lighthouse Role

Ansible роль для установки веб-интерфейса Lighthouse для ClickHouse.

## Переменные

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `lighthouse_version` | "master" | Версия Lighthouse |
| `clickhouse_host` | "{{ hostvars['clickhouse-vm']['ansible_host'] }}" | Хост ClickHouse |
| `clickhouse_port` | 8123 | Порт ClickHouse |
| `clickhouse_user` | default | Пользователь ClickHouse |

## Зависимости

- Nginx

## Пример использования

```yaml
- hosts: lighthouse
  roles:
    - role: lighthouse_role
      clickhouse_host: "192.168.1.100"
