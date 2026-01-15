#!/bin/bash
# DataGrip Query Runner via Keyboard Maestro
# Usage: ./datagrip-query.sh "SELECT * FROM users LIMIT 10"
# 
# This script:
# 1. Copies the SQL to clipboard
# 2. Triggers a Keyboard Maestro macro to execute in DataGrip
# 3. Returns the results from clipboard

SQL="$1"
OUTPUT_FILE="${2:-/tmp/datagrip-result.csv}"

if [ -z "$SQL" ]; then
    echo "Usage: $0 'SQL QUERY' [output_file]"
    exit 1
fi

# Copy SQL to clipboard
echo "$SQL" | pbcopy

# Trigger Keyboard Maestro macro
# The macro should:
# 1. Activate DataGrip
# 2. Cmd+N (new query console) or use existing
# 3. Cmd+A (select all), then paste
# 4. Ctrl+Enter (execute)
# 5. Wait for results
# 6. Cmd+Shift+E (export to clipboard as CSV)

osascript -e 'tell application "Keyboard Maestro Engine" to do script "DataGrip Execute Query"' 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Query sent to DataGrip via Keyboard Maestro"
    echo "📋 Results will be in clipboard when done"
else
    echo "⚠️ Keyboard Maestro macro 'DataGrip Execute Query' not found"
    echo "Create a macro with that name in Keyboard Maestro"
fi
