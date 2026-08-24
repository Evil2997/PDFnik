# Карта монорепозитория PDFnik

Корень: /home/dmitriy/PycharmProjects/PDFnik
Это монорепо БЕЗ .gitmodules — сабмодули подключены как обычные папки,
у каждой свой .git. Root git status всегда показывает их как untracked
directories — это ОЖИДАЕМО, не проблема. Коммитить надо в каждом репе отдельно.

Репозитории:
- PDFnik-Backend      — свой git, ветка master (main-код в main_app/, НЕ в src/)
- PDFnik-TelegramBot  — свой git, ветка master
- PDFnik-Schemes      — свой git, ветка master
- PDFnik-files_cleaner — свой git, ветка master
- feature/            — просто папка со спеками (.md), НЕ git-репо, кода там нет

# ЛИЧНЫЕ ФАЙЛЫ ПОЛЬЗОВАТЕЛЯ — НЕ ЧИТАТЬ, НЕ ТРОГАТЬ, НЕ КОММИТИТЬ

Эти файлы — личные scratch-заметки пользователя. Они намеренно висят
незакоммиченными. НЕ открывать их, НЕ читать содержимое, НЕ предлагать
удалить, НЕ коммитить. Просто игнорировать при любом аудите:
- 111.py, 222.py, 333.py и любые NNN.py (одноразовые скрипты пользователя)
- push_tags.txt (в любом репе) — личная напоминалка

При git status эти файлы будут в untracked — это нормально, так и надо.
Не трать вызовы на выяснение "что это".

# Запуск тестов

Ручной экспорт env-переменных БОЛЬШЕ НЕ НУЖЕН: dummy-дефолты зашиты в
tests/conftest.py обоих сервисов через os.environ.setdefault (Backend:
RABBITMQ_URL; Bot: BOT_TOKEN/REDIS_URL/RABBITMQ_URL). Реальные env-переменные,
если выставлены (например в CI), имеют приоритет над дефолтами.

Всё запускается одинаково, без подготовки:
    make test                                      # оба сервиса
    /test-all                                      # запускает make test
    /test-backend                                  # uv run pytest PDFnik-Backend/tests/unit -q
    /test-bot                                      # uv run pytest PDFnik-TelegramBot/tests/unit -q
    uv run pytest PDFnik-Backend/tests/unit -q     # руками тоже работает

ВАЖНО: Backend и Bot тесты нельзя передавать одним вызовом pytest
(`pytest PDFnik-Backend/tests/unit PDFnik-TelegramBot/tests/unit`).
Причины ДВЕ, обе фундаментальные:
1. Коллизия имени пакета: оба сервиса содержат tests/__init__.py и
   tests/unit/__init__.py, поэтому пакет `tests.unit` второго сервиса
   конфликтует с первым в sys.modules — collection error.
2. Конфликтующие глобальные заглушки: conftest Backend подменяет
   pdfnik_contracts.pdf_content (и reportlab/PIL/faster_whisper) на
   MagicMock в sys.modules, а тесты Bot ставят СВОИ фейки на тот же
   модуль. Общий процесс даёт порядко-зависимые падения, даже если бы
   коллекция прошла.
Всегда два отдельных pytest-процесса (make test и /test-all так и делают).

При странных ошибках импорта чужих тестов — сначала почистить кэш:
    find . -name "__pycache__" -exec rm -rf {} + 2>/dev/null

# Известные баги (НЕ приписывай их своей работе)

Оба прежних пункта ИСПРАВЛЕНЫ (июль 2026), секция оставлена как формат
на будущее:
1. ~~Перевод duration_str (unknown/неизвестно)~~ — доделан, тесты зелёные.
2. ~~Сломанный CI/CD рерайт~~ — починен и закоммичен в Backend и Bot
   (trivy_check.sh существует, mypy-пути исправлены). Единственный
   намеренно незакоммиченный файл: Backend/.github/workflows/cd.yaml —
   ждёт решения по deploy-target (self-hosted runner), НЕ коммитить и
   НЕ создавать аналог в Bot без отдельного решения пользователя.

# Рецепт безопасного коммита (safe-commit)

pre-commit лежит в .venv/bin, но НЕ на PATH напрямую, поэтому git commit
запускать так:
    PATH="/home/dmitriy/PycharmProjects/PDFnik/.venv/bin:$PATH" git commit -m "..."

ruff во время хука может автопофиксить форматирование → файл изменится →
нужно git add ещё раз и повторить commit.

Если в рабочей папке есть незакоммиченный WIP (сейчас это только
Backend/.github/workflows/cd.yaml — он untracked, git add -A не делать),
а коммитишь чистую работу — стейджи файлы точечно, либо спрячь WIP:
    git stash push --keep-index -- <пути-wip-файлов>
    # ... commit ...
    git stash pop

# Правило разделения коммитов

Никогда не мешай в один коммит: (а) рабочую оттестированную фичу и
(б) недоделанный/битый WIP. Если что-то ссылается на несуществующие
файлы или падает — оставляй незакоммиченным и явно скажи об этом.
