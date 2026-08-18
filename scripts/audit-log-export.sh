#!/bin/bash
# audit-log-export.sh - Export GitHub audit logs for compliance

set -e

ORG="${GITHUB_ORG:-your-org}"
BUCKET="${S3_BUCKET:-your-audit-bucket}"
DAYS="${DAYS_BACK:-1}"

echo "📊 Exporting GitHub audit logs for org: $ORG"
echo "   Time range: Last $DAYS day(s)"
echo "   Destination: s3://$BUCKET/github/"

# Calculate timestamp
SINCE=$(date -d "$DAYS days ago" -Iseconds 2>/dev/null || date -v-${DAYS}d +%Y-%m-%dT%H:%M:%S%z)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Export audit log
OUTPUT_FILE="audit-log-${ORG}-${TIMESTAMP}.json"

gh api \
  "/orgs/${ORG}/audit-log" \
  -f phrase="action:git.push OR action:pull_request.merge OR action:repository.created" \
  -f since="$SINCE" \
  > "$OUTPUT_FILE"

echo "✅ Audit log exported: $OUTPUT_FILE"
echo "   Records: $(jq length "$OUTPUT_FILE" 2>/dev/null || echo 'unknown')"

# Upload to S3 if AWS CLI is available
if command -v aws &> /dev/null; then
    echo "📤 Uploading to S3..."
    aws s3 cp "$OUTPUT_FILE" "s3://${BUCKET}/github/"
    echo "✅ Upload complete"
else
    echo "⚠️  AWS CLI not found. File saved locally: $OUTPUT_FILE"
fi

# Cleanup local file after upload
if [ -f "$OUTPUT_FILE" ] && command -v aws &> /dev/null; then
    rm "$OUTPUT_FILE"
    echo "🧹 Cleaned up local file"
fi
