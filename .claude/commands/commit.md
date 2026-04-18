Run `git status` and `git diff --cached` to see what is staged.

Based on the changes, propose ONE commit message using conventional commit format:
- `feat: <description>` — new feature
- `fix: <description>` — bug fix
- `chore: <description>` — maintenance, deps, config
- `refactor: <description>` — code restructure without behavior change
- `docs: <description>` — documentation only
- `style: <description>` — formatting, whitespace
- `test: <description>` — tests only

Rules:
- Keep the description under 72 characters, lowercase, no period at the end
- Do NOT stash anything — the user manages stashing manually
- Do NOT commit anything yet

After proposing the message, use AskUserQuestion. The question text MUST include the proposed commit message, e.g.:
  "Commit with this message?\n\n`docs: move architecture diagram to dedicated file`"

Provide three options:
1. **approve** — commit with the proposed message
2. **edit** — user provides a different message
3. **cancel** — do nothing

If approved: run `git commit -m "<proposed message>"` and report the result.
If edit: ask the user for their preferred message, then run `git commit -m "<their message>"`.
If cancel: stop and do nothing.
