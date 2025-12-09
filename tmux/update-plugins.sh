#!/usr/bin/env bash
# Update all tmux plugin submodules

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

error() {
    echo -e "${RED}Error:${NC} $1" >&2
    exit 1
}

info() {
    echo -e "${GREEN}Info:${NC} $1"
}

warn() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Check if we're in a git repository
if ! git -C "$REPO_ROOT" rev-parse --git-dir > /dev/null 2>&1; then
    error "Not a git repository: $REPO_ROOT"
fi

# Check if .gitmodules exists
if [ ! -f "$REPO_ROOT/.gitmodules" ]; then
    error ".gitmodules file not found. Are submodules configured?"
fi

# Parse command line arguments
DRY_RUN=false
UPDATE_ALL=true
PLUGIN_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --plugin|-p)
            UPDATE_ALL=false
            PLUGIN_NAME="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Update tmux plugin submodules"
            echo ""
            echo "Options:"
            echo "  -n, --dry-run    Show what would be updated without making changes"
            echo "  -p, --plugin     Update a specific plugin (e.g., tpm, tmux-sensible)"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                # Update all plugins"
            echo "  $0 --dry-run      # Show what would be updated"
            echo "  $0 --plugin tpm   # Update only tpm plugin"
            exit 0
            ;;
        *)
            error "Unknown option: $1. Use --help for usage."
            ;;
    esac
done

cd "$REPO_ROOT" || error "Failed to change to repository root"

info "Checking submodule status..."

# Show current status
echo ""
echo "Current plugin versions:"
git submodule status tmux/plugins/ || error "Failed to get submodule status"

if [ "$DRY_RUN" = true ]; then
    echo ""
    warn "DRY RUN MODE - No changes will be made"
    echo ""
    echo "Would update submodules:"
    if [ "$UPDATE_ALL" = true ]; then
        git submodule foreach --quiet 'echo "  $name -> $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")"'
    else
        if [ -d "tmux/plugins/$PLUGIN_NAME" ]; then
            echo "  tmux/plugins/$PLUGIN_NAME"
        else
            error "Plugin not found: $PLUGIN_NAME"
        fi
    fi
    exit 0
fi

echo ""
info "Updating tmux plugin submodules..."

# Update submodules
if [ "$UPDATE_ALL" = true ]; then
    if ! git submodule update --remote --merge; then
        error "Failed to update submodules"
    fi
else
    PLUGIN_PATH="tmux/plugins/$PLUGIN_NAME"
    if [ ! -d "$PLUGIN_PATH" ]; then
        error "Plugin not found: $PLUGIN_NAME"
    fi
    
    info "Updating $PLUGIN_NAME..."
    if ! (cd "$PLUGIN_PATH" && git pull origin "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo master)" && cd "$REPO_ROOT" && git add "$PLUGIN_PATH"); then
        error "Failed to update $PLUGIN_NAME"
    fi
fi

echo ""
info "Updated plugins:"
git submodule status tmux/plugins/

echo ""
echo "To commit these changes, run:"
echo "  git add tmux/plugins/"
echo "  git commit -m 'Update tmux plugins'"
