#!/usr/bin/env bash
#
# scripts/sync-conventions.sh — Pull canonical shared files from the template.
#
# Reads:
#   .claude/sync-source.txt   — the source repo URL (e.g. a GitHub clone URL)
#   scripts/sync-manifest.txt — list of repo-relative paths to sync
#
# Behavior:
#   1. Shallow-clones the source repo into a temp dir.
#   2. For each manifest path, compares source vs. local; shows a unified diff
#      for any file that differs or is new.
#   3. Asks for confirmation; on "y", copies the new versions into place,
#      preserving the executable bit for files whose first two bytes are "#!".
#   4. Cleans up the temp dir on exit.
#
# Usage:
#   ./scripts/sync-conventions.sh            # interactive
#   ./scripts/sync-conventions.sh --yes      # non-interactive (auto-apply)
#   ./scripts/sync-conventions.sh --dry-run  # show diffs, write nothing
#
# Re-run after a PR to tnosugar/project-template lands that changes any of the
# synced files.

set -euo pipefail

# ---------- args ----------
ASSUME_YES=false
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --yes|-y) ASSUME_YES=true ;;
    --dry-run|-n) DRY_RUN=true ;;
    -h|--help)
      sed -n '2,/^set -/p' "$0" | sed 's/^# \{0,1\}//' | head -n -1
      exit 0
      ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

# ---------- locate repo root ----------
if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "ERROR: not inside a git repository." >&2
  exit 1
fi

SOURCE_FILE="$REPO_ROOT/.claude/sync-source.txt"
MANIFEST="$REPO_ROOT/scripts/sync-manifest.txt"

if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "ERROR: $SOURCE_FILE not found." >&2
  echo "       Create it and put the source repo URL on the first line." >&2
  exit 1
fi
if [[ ! -f "$MANIFEST" ]]; then
  echo "ERROR: $MANIFEST not found." >&2
  exit 1
fi

SOURCE_URL="$(grep -v '^[[:space:]]*#' "$SOURCE_FILE" | grep -v '^[[:space:]]*$' | head -n1 | tr -d '[:space:]')"
if [[ -z "$SOURCE_URL" ]]; then
  echo "ERROR: $SOURCE_FILE has no source URL." >&2
  exit 1
fi

# ---------- fetch source ----------
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "Fetching latest from $SOURCE_URL ..."
if ! git clone --depth 1 --quiet "$SOURCE_URL" "$TMPDIR/source" 2>"$TMPDIR/clone.err"; then
  echo "ERROR: failed to clone $SOURCE_URL" >&2
  cat "$TMPDIR/clone.err" >&2
  exit 1
fi

# ---------- compare ----------
declare -a CHANGED=()
declare -a NEW=()
declare -a MISSING=()
declare -a UNCHANGED=()

while IFS= read -r line; do
  path="${line%%#*}"                       # strip trailing comments
  path="${path#"${path%%[![:space:]]*}"}"  # ltrim
  path="${path%"${path##*[![:space:]]}"}"  # rtrim
  [[ -z "$path" ]] && continue

  src="$TMPDIR/source/$path"
  dst="$REPO_ROOT/$path"

  if [[ ! -f "$src" ]]; then
    MISSING+=("$path")
    continue
  fi

  if [[ ! -f "$dst" ]]; then
    NEW+=("$path")
    continue
  fi

  if cmp -s "$src" "$dst"; then
    UNCHANGED+=("$path")
  else
    CHANGED+=("$path")
  fi
done < "$MANIFEST"

# ---------- report ----------
if [[ ${#UNCHANGED[@]} -gt 0 ]]; then
  echo
  echo "Up to date:"
  printf '  %s\n' "${UNCHANGED[@]}"
fi

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo
  echo "WARNING: listed in manifest but not found in source:"
  printf '  %s\n' "${MISSING[@]}"
fi

show_diff() {
  local path="$1" label="$2"
  local src="$TMPDIR/source/$path"
  local dst="$REPO_ROOT/$path"
  echo
  echo "---- $label: $path ----"
  if [[ -f "$dst" ]]; then
    diff -u "$dst" "$src" || true
  else
    echo "(new file — preview first 40 lines)"
    head -n 40 "$src"
  fi
  echo "---- end ----"
}

for path in "${NEW[@]}";     do show_diff "$path" "NEW"; done
for path in "${CHANGED[@]}"; do show_diff "$path" "CHANGED"; done

TOTAL=$(( ${#NEW[@]} + ${#CHANGED[@]} ))
if [[ $TOTAL -eq 0 ]]; then
  echo
  echo "Everything up to date. Nothing to write."
  exit 0
fi

echo
echo "Files to write: $TOTAL ($(( ${#NEW[@]} )) new, $(( ${#CHANGED[@]} )) changed)"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "(--dry-run: no changes written)"
  exit 0
fi

if [[ "$ASSUME_YES" != "true" ]]; then
  read -r -p "Apply these changes? [y/N] " ANSWER
  if [[ "$ANSWER" != "y" && "$ANSWER" != "Y" ]]; then
    echo "Aborted. No changes written."
    exit 0
  fi
fi

# ---------- write ----------
copy_one() {
  local path="$1"
  local src="$TMPDIR/source/$path"
  local dst="$REPO_ROOT/$path"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  # Preserve +x for files that look like scripts.
  if head -c 2 "$dst" 2>/dev/null | grep -q '^#!'; then
    chmod +x "$dst"
  fi
  echo "WROTE: $path"
}

for path in "${NEW[@]}";     do copy_one "$path"; done
for path in "${CHANGED[@]}"; do copy_one "$path"; done

echo
echo "Done. Review with 'git diff' and commit when ready."
