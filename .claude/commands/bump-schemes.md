---
allowed-tools: Bash(python3 .claude/hooks/bump-schemes.py *), Bash(make test)
argument-hint: "[patch|minor|major]"
description: "Bumps PDFnik-Schemes version, creates git tag, updates requirements.txt in Backend and Bot"
---

1. If bump type not specified in $ARGUMENTS, ask: patch / minor / major?
2. Run: `python3 .claude/hooks/bump-schemes.py $ARGUMENTS`
3. Run: `make test`
4. If tests pass, show the commit commands from the script output and ask to confirm before committing.
5. If tests fail, stop and report what broke.