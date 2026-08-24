# Специфика бэкенда
- Используем FastAPI (вижу main_app/api)
- Все схемы импортировать из `pdfnik_contracts` (папка Schemes)
- RabbitMQ: продюсеры и консьюмеры через `main_app/rabbitmq/`
- Логирование через `main_app/core/logger.py`
- Не хардкодить очереди — брать из констант `pdfnik_contracts.Queues`
  (общие для бота и бэкенда; не Settings — имя очереди не per-environment
  конфигурация, а константа протокола). См. .claude/rules/python/data-contracts.md.

