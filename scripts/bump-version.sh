#!/usr/bin/env bash
# Usage: bump-version.sh [patch|minor|major]
set -euo pipefail

BUMP_TYPE="${1:-patch}"
VERSION_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/versions/VERSION"

# Get latest tag or fall back to VERSION file
LATEST_TAG=$(git tag -l "v*" | sort -V | tail -1)
if [[ -z "$LATEST_TAG" ]]; then
  CURRENT=$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")
else
  CURRENT="${LATEST_TAG#v}"
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

case "$BUMP_TYPE" in
  patch) PATCH=$((PATCH + 1)) ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  *) echo "Usage: $0 [patch|minor|major]"; exit 1 ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
TAG="v${NEW_VERSION}"

echo "$NEW_VERSION" > "$VERSION_FILE"
git add "$VERSION_FILE"
git commit -m "chore: bump version to $TAG" --no-verify || true
git tag -a "$TAG" -m "$TAG"
git push origin HEAD --tags

echo "✅ Tagged $TAG and pushed"
