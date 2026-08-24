---
allowed-tools: Bash(make test)
description: "Run unit tests for all services (Backend + Bot)"
---

Run: `make test`

It runs Backend and Bot as two SEPARATE pytest processes - this is required,
not an implementation detail. Never combine both packages into a single pytest
invocation:

1. Module-name collision: both services ship `tests/__init__.py`, so the
   second package's `tests.unit` clashes with the first in sys.modules and
   collection aborts.
2. Conflicting global stubs: Backend's conftest replaces
   `pdfnik_contracts.pdf_content` (and reportlab/PIL/faster_whisper) with
   MagicMock stubs in sys.modules, while Bot tests install their own fakes
   for the same module. A shared process would be order-dependent and unsafe
   even if collection succeeded.

No manual env exports needed - each service's tests/conftest.py provides
dummy defaults via os.environ.setdefault.

Show a combined summary. If anything fails, group failures by service.
