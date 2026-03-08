Server-side hook installation

This repository includes a server-side `pre-receive` hook that mirrors
our local `pre-commit` checks. It rejects pushes that introduce
`@do-not-commit` or `@review` markers in added lines.

Installation (on the Git server, in the bare repo):

1. SSH to the Git server and change into the bare repository directory.
   Example:

   ```pwsh
   cd /srv/git/your-repo.git
   ```

2. Copy the hook into the repository's `hooks/pre-receive` (overwrite if
   present):

   ```pwsh
   cp /path/to/Dotfiles/git/server-hooks/pre-receive hooks/pre-receive
   chmod +x hooks/pre-receive
   ```

   Or edit in-place and ensure it's executable.

3. Test the hook locally by attempting to push a branch that contains a
   file with an added line containing `@do-not-commit` or `@review`. The
   push should be rejected with an explanatory message.

Notes and guidance

- This hook uses `git diff <oldrev>.. <newrev>` to inspect changes.
  It only checks added lines (those starting with `+`) to minimize
  false positives from existing files.

- This script assumes it's executed in the bare repository (the usual
  location for server-side hooks). If your hosting environment wraps
  or isolates hooks (managed hosting), you may need to adapt the
  installation or use your host's custom hook support.

- Administrators who need to bypass the hook temporarily can push from
  the server itself or remove the hook; we recommend using branch
  protections and audit logs instead of disabling enforcement.

- If you use a CI system (GitHub/GitLab), keep the CI-based scan as a
  secondary enforcement layer (it provides a visible failure in PRs).

If you'd like, I can:
- Add a more verbose output format listing the file and hunk locations of
  offending lines.
- Add an allow-list (e.g., `refs/heads/release/*`) or a per-user bypass
  controlled by a server-side configuration file.
