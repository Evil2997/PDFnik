# pydantic-over-primitives.md — структурные данные оформляются как Pydantic BaseModel

Личное требование пользователя (зафиксировано 2026-07-12, финализировано
2026-07-12 — снят ошибочный `RootModel`, добавлена схема `list[BaseModel]`
для словарей с открытым ключом), не завершённый стандарт — пользователь
явно предупредил, что список уточнений будет пополняться отдельными
сообщениями позже. Читать в дополнение к `core-python.md` и
`data-contracts.md`.

## Правило

`dict`/`tuple` любой формы — без исключений — это `pydantic.BaseModel`.
Это касается не только моделей, пересекающих границу сервиса (для них это
уже требует `data-contracts.md`), но и внутрипроцессных структур —
return-значений функций, промежуточных результатов конвейера, локальных
переменных, играющих роль структуры или счётчика.

```python
# плохо — позиционный tuple, значения различимы только по порядку
def compute_draw_size(width_px: int, height_px: int) -> tuple[float, float]:
    ...
    return draw_w, draw_h

# хорошо — поля именованы, IDE и mypy проверяют использование
class DrawSize(BaseModel):
    model_config = ConfigDict(frozen=True)
    draw_w: float
    draw_h: float

def compute_draw_size(width_px: int, height_px: int) -> DrawSize:
    ...
    return DrawSize(draw_w=draw_w, draw_h=draw_h)

# плохо — "просто счётчик", но это всё ещё голый dict без имени
def count_blocks(blocks: list[Block]) -> dict[str, int]:
    ...
    return {"photo_count": photo_count, "text_count": text_count}

# хорошо — счётчик с фиксированным набором полей тоже BaseModel
class BlockCounts(BaseModel):
    photo_count: int
    text_count: int
```

## Словарь с открытым/семантическим ключом — `list[BaseModel]`, не `dict`

Там, где раньше предполагалось исключение "ключ — это данные, произвольное
множество" — ключ никогда не остаётся ключом словаря. Он становится полем
модели, а сама структура — `list[BaseModel]`:

```python
# плохо — ключ несёт смысл, но спрятан в dict
_MIME_DEFAULT_EXT: dict[str, str] = {"audio/mpeg": "mp3", "audio/wav": "wav"}

# хорошо — ключ и значение оба явные поля
class MimeExtension(BaseModel):
    mime_type: str
    extension: str

MIME_DEFAULT_EXTENSIONS: list[MimeExtension] = [
    MimeExtension(mime_type="audio/mpeg", extension="mp3"),
    MimeExtension(mime_type="audio/wav", extension="wav"),
]
```

Если в конкретном месте использования нужен O(1)-доступ по ключу —
собрать обычный `dict` из списка в точке использования
(`{m.mime_type: m.extension for m in MIME_DEFAULT_EXTENSIONS}`), а не
хранить его как каноническую форму данных. `pydantic.RootModel` для этого
случая не используется — это была самостоятельная инициатива предыдущей
сессии, пользователь её не подтверждал.

Не подпадает под правило:
- Однородная коллекция переменной длины БЕЗ роли записи/справочника/
  счётчика (`list[Path]`, `tuple[int, ...]`) — просто список элементов
  для итерации, не структура с зафиксированным смыслом каждого элемента.
- Результат стороннего API, который сам возвращает `tuple`/`dict`
  (`img.size` из PIL и подобное) — оборачивать сразу на границе с этим
  API в модель, не переносить голый tuple/dict дальше по коду.

## Открытый вопрос — объекты, которые не сериализуются

`data-contracts.md` п.4 отдельно предупреждает: `arbitrary_types_allowed=True`
ради того, чтобы запихнуть нерасходуемый/несериализуемый объект
(`asyncio.Task`, сокет, `PIL.Image.Image` и подобное) в поле модели —
сигнал, что модель здесь не нужна. Это правило пока не разрешает
противоречие с данным пунктом: если tuple/dict вперемешку с обычными
полями содержит такой объект — решение (заводить ли всё равно модель
с `arbitrary_types_allowed`, оставить как есть, или вынести объект
отдельным параметром вне модели) принимается точечно с пользователем
на месте, не по умолчанию.
