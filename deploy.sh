#!/usr/bin/env bash
#
# Deploy the course website to www.cs.toronto.edu over SSH/rsync.
#
# Mirrors the local website/ folder up to:
#   sftp://guerzhoy@www.cs.toronto.edu/public_html/1626s26
# (published at https://www.cs.toronto.edu/~guerzhoy/1626s26/)
#
# rsync only sends files that changed, so re-running is cheap.
# You'll be prompted for your CS password once per run unless you've
# set up an SSH key (see the note at the bottom of this file).
#
# Usage:
#   ./deploy.sh            upload changed files (never deletes anything remote)
#   ./deploy.sh -n         dry run: show exactly what WOULD change, transfer nothing
#   ./deploy.sh --delete   mirror: also remove remote files no longer present locally
#   ./deploy.sh -n --delete  preview a mirror (recommended before a real --delete)
#
set -euo pipefail

REMOTE_USER="guerzhoy"
REMOTE_HOST="www.cs.toronto.edu"
REMOTE_PATH="public_html/1626s26"

# The folder to publish lives next to this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="$SCRIPT_DIR/website"

# Files that should never be published, even though we ship "everything".
EXCLUDES=(
  ".git" ".gitignore"
  ".DS_Store" "Thumbs.db"
  "*~" "*.swp" "*.bak"
  ".Rhistory" ".RData" ".Rproj.user"
  "*_cache/" "__pycache__/" ".ipynb_checkpoints/"
  "deploy.sh"
)

DRY_RUN=()
DELETE=()
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=(--dry-run) ;;
    --delete|--mirror) DELETE=(--delete --delete-after) ;;
    -h|--help) awk 'NR>1 && /^#/{sub(/^# ?/,"");print;next} NR>1{exit}' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

if [[ ! -d "$LOCAL_DIR" ]]; then
  echo "Error: cannot find website folder at $LOCAL_DIR" >&2
  exit 1
fi

EXCLUDE_ARGS=()
for e in "${EXCLUDES[@]}"; do
  EXCLUDE_ARGS+=(--exclude "$e")
done

DEST="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

echo "Local : $LOCAL_DIR/"
echo "Remote: $DEST"
if [[ ${#DRY_RUN[@]} -gt 0 ]]; then echo "Mode  : DRY RUN (no changes will be made)"; fi
if [[ ${#DELETE[@]} -gt 0 ]]; then echo "Mode  : MIRROR (stale remote files will be DELETED)"; fi
echo

# -a archive, -v verbose, -z compress, -h human-readable, --progress live status.
# --rsync-path ensures the remote target directory exists before transferring.
# --chmod forces web-readable permissions so the server can serve every file.
rsync -avzh --progress \
  "${DRY_RUN[@]}" \
  "${DELETE[@]}" \
  "${EXCLUDE_ARGS[@]}" \
  --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r \
  --rsync-path="mkdir -p $REMOTE_PATH && rsync" \
  -e ssh \
  "$LOCAL_DIR/" \
  "$DEST"

echo
if [[ ${#DRY_RUN[@]} -gt 0 ]]; then
  echo "Dry run complete. Re-run without -n to actually upload."
else
  echo "Done. Live at https://www.cs.toronto.edu/~${REMOTE_USER}/1626s26/"
fi

# --- Tired of typing your password every deploy? ---------------------------
# One-time SSH key setup (then rsync runs without prompting):
#   ssh-keygen -t ed25519               # if you don't already have a key
#   ssh-copy-id guerzhoy@www.cs.toronto.edu
# ---------------------------------------------------------------------------
