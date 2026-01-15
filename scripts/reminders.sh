#!/bin/bash
# Apple Reminders CLI Wrapper (calls Swift/EventKit for speed)
SCRIPT_DIR="$(dirname "$0")"
swift "$SCRIPT_DIR/reminders.swift" "$@"
