#!/bin/sh
# install-server-hook.sh
# Author: Your Name <you@example.com>
# Contact: https://example.com/ or you@example.com
#
# Description:
# - Copies the repo's server-side hook files to a remote bare Git repository
#   over SSH and sets correct permissions. Requires `scp` and `ssh`.
#
# Usage:
#   ./install-server-hook.sh user@host:/path/to/repo.git
#
# Examples:
#   ./install-server-hook.sh git@myserver:/srv/git/project.git
#   ./install-server-hook.sh -n git@myserver:/srv/git/project.git  # dry-run
#
# What good looks like:
# - `hooks/pre-receive` present and executable on the target bare repo.
# - Optional `hooks/allow-branches` or `hooks/admin-bypass` installed when provided.

set -eu

usage() {
  cat <<EOF
Usage: $0 [ -n ] user@host:/path/to/repo.git

Options:
  -n    Dry run (print commands but don't execute)

This script copies the contents of git/server-hooks/ into the target
bare-repo's hooks directory and sets executable permissions on
pre-receive.
EOF
  exit 1
}

DRY_RUN=0
while getopts ":n" opt; do
  case "$opt" in
    n) DRY_RUN=1 ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

if [ $# -ne 1 ]; then
  usage
fi

TARGET=$1
HOOK_SRC_DIR="$(cd "$(dirname "$0")" && pwd)/git/server-hooks"

if [ $DRY_RUN -eq 1 ]; then
  echo "DRY RUN: scp -r $HOOK_SRC_DIR/* $TARGET/hooks/"
  echo "DRY RUN: ssh $TARGET 'chmod +x /path/to/repo.git/hooks/pre-receive || true'"
  exit 0
fi

echo "Copying hooks to $TARGET/hooks/"
scp -r "$HOOK_SRC_DIR"/* "$TARGET":hooks/ || { echo "scp failed"; exit 2; }

# Parse TARGET into host and remote path (user@host:/abs/path)
case "$TARGET" in
  *:*)
    HOST=${TARGET%%:*}
    REMOTE_PATH=${TARGET#*:}
    ;;
  *)
    echo "Invalid target format. Expected user@host:/path/to/repo.git" >&2
    exit 2
    ;;
esac

echo "Setting executable bit on pre-receive"
ssh "$HOST" "chmod +x \"$REMOTE_PATH/hooks/pre-receive\"" || true

echo "Installed hooks to $TARGET/hooks/"
