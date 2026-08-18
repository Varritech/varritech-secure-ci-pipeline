#!/bin/bash
# ai-review-check.sh - Local pre-commit hook to verify AI-generated code has human review

set -e

echo "🔍 Checking for AI-only changes..."

# Get list of commits in current branch not in main
COMMITS=$(git log HEAD --not main --format="%an" 2>/dev/null || echo "")

if [ -z "$COMMITS" ]; then
    echo "✅ No unmerged commits or already on main"
    exit 0
fi

# Check if all authors are bots
AI_AUTHORS=("github-actions" "dependabot" "copilot-suggestions" "renovate")
ALL_AI=true

while IFS= read -r author; do
    IS_AI=false
    for ai in "${AI_AUTHORS[@]}"; do
        if [[ "$author" == *"$ai"* ]]; then
            IS_AI=true
            break
        fi
    done
    
    if [ "$IS_AI" = false ]; then
        ALL_AI=false
        break
    fi
done <<< "$COMMITS"

if [ "$ALL_AI" = true ]; then
    echo "⚠️  Warning: All commits appear to be from AI/bots"
    echo "   Ensure a human has reviewed these changes before merging"
    echo ""
    echo "   To mark as reviewed, add the 'ai-reviewed' label on GitHub:"
    echo "   https://github.com/$(git remote get-url origin | sed 's/.*:\(.*\)\.git/\1/')/labels"
    exit 0
fi

echo "✅ Human-authored commits detected"
