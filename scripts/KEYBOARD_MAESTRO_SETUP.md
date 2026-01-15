# Keyboard Maestro + DataGrip Setup

## Macro: "DataGrip Execute Query"

### Trigger
- Script trigger: `do script "DataGrip Execute Query"`

### Actions

```
1. Activate DataGrip
   [Activate Application: DataGrip]

2. Open new console (or use existing)
   [Type Keystroke: ⌘+Shift+L]  # Jump to console
   # OR
   [Type Keystroke: ⌘+N]        # New query console

3. Select all existing text
   [Type Keystroke: ⌘+A]

4. Paste SQL from clipboard
   [Type Keystroke: ⌘+V]

5. Execute query
   [Type Keystroke: ⌃+Enter]    # Ctrl+Enter

6. Wait for results (adjust timing as needed)
   [Pause: 3 seconds]

7. Focus results grid
   [Type Keystroke: ⌘+↓]        # Move to results

8. Select all results
   [Type Keystroke: ⌘+A]

9. Copy as CSV to clipboard
   [Type Keystroke: ⌘+C]
   # OR for CSV export:
   # [Type Keystroke: ⌘+Shift+E] then select CSV
```

### Alternative: Export to File

If you want results saved to a file instead of clipboard:

```
After step 5:
6. Wait for results
   [Pause: 3 seconds]

7. Export results
   - Right-click results → Export Data → CSV
   - Or use [Type Keystroke: ⌘+Shift+E]

8. Save to /tmp/datagrip-result.csv
```

## Macro: "DataGrip Execute Query to File"

Same as above but exports to `/tmp/datagrip-result.csv`:

```
1-5. Same as above

6. Wait for results
   [Pause: 3 seconds]

7. Open export dialog
   [Type Keystroke: ⌘+Shift+E]

8. Pause for dialog
   [Pause: 0.5 seconds]

9. Type file path
   [Insert Text: /tmp/datagrip-result.csv]

10. Confirm
    [Type Keystroke: Enter]
```

## Usage from Sektor/CLI

```bash
# Execute query (results to clipboard)
./scripts/datagrip-query.sh "SELECT * FROM teams LIMIT 5"

# Then paste results or read from clipboard
pbpaste
```

## Pro Tips

1. **Keep a console open** - Faster than creating new ones each time
2. **Use named consoles** - Name one "Sektor Queries" for easy switching
3. **Connection** - Make sure the Streamer DB connection is selected before running

## DataGrip Shortcuts Reference

| Action | Shortcut |
|--------|----------|
| Execute query | ⌃+Enter |
| Execute all | ⌘+Enter |
| New console | ⌘+N |
| Switch console | ⌘+Shift+L |
| Export data | ⌘+Shift+E |
| Copy as CSV | (select) → ⌘+C |
