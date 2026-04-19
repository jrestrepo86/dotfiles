Create a git commit. Never stash — the user manages stashing. Do not commit until the user approves.

## 1. Inspect state

Run:
- `git status`
- `git diff --cached`

## 2. If nothing is staged

Stop. List the modified/untracked files from `git status` and tell the user to stage what they want committed. Do NOT run `git add`. Do NOT stash. End the turn.

## 3. Secrets scan

Scan added lines (`+` lines) in `git diff --cached` for likely secrets:
- assignments like `password`, `secret`, `token`, `api[_-]?key` followed by a literal string
- `-----BEGIN .* PRIVATE KEY-----`
- AWS access keys: `AKIA[0-9A-Z]{16}`
- GitHub tokens: `ghp_`, `gho_`, `ghs_`, `ghu_`, `ghr_`
- Slack tokens: `xox[baprs]-`
- long opaque base64/hex literals (>32 chars) assigned to suspiciously named vars

If any hit, list `file:line` for each and use AskUserQuestion with options:
1. **continue** — ignore the warning (false positive)
2. **cancel** — stop so the user can fix it

## 4. Split detection

Inspect the staged diff for mixed concerns, e.g.:
- unrelated top-level areas touched together (e.g. `dot_config/nvim/**` and `chezmoiscripts/**`)
- behavior change mixed with pure formatting / whitespace
- dependency bumps mixed with logic changes
- docs-only files mixed with code files

If mixed, briefly describe the groups and use AskUserQuestion:
1. **split** — stop so the user can unstage and re-run `/commit` per group
2. **one commit** — proceed with a single message covering everything

Do NOT run `git reset` or `git restore` to unstage on the user's behalf.

## 5. Propose ONE commit message

Conventional Commits, no emoji, no scope, no body:
- `feat: <description>` — new feature
- `fix: <description>` — bug fix
- `chore: <description>` — maintenance, deps, config
- `refactor: <description>` — code restructure, no behavior change
- `docs: <description>` — docs only
- `style: <description>` — formatting, whitespace
- `test: <description>` — tests only
- `perf: <description>` — performance
- `ci: <description>` — CI/build pipeline

Rules:
- lowercase, imperative mood ("add", not "added")
- under 72 characters total
- no trailing period
- subject line only — no body, no footer

## 6. Ask for approval

Use AskUserQuestion. The question text MUST include the proposed message verbatim in backticks, e.g.:

  "Commit with this message?\n\n`fix: guard starship init on non-interactive shells`"

Options:
1. **approve** — commit with the proposed message
2. **edit** — user provides a different message
3. **cancel** — do nothing

## 7. Act on the answer

- **approve** → run `git commit -m "<proposed message>"` and report the new SHA and subject from its output.
- **edit** → ask the user for their preferred message, then run `git commit -m "<their message>"` and report the result.
- **cancel** → stop and do nothing.

Never pass `--amend`, `--no-verify`, or `-a`. Never run `git push`.
