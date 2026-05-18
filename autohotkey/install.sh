#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/src"

WIN_USERPROFILE=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r\n')
DEST_DIR=$(wslpath "$WIN_USERPROFILE")/AutoHotkey

if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
fi

echo "Copying *.ahk files to $DEST_DIR"
for f in "$SOURCE_DIR"/*.ahk; do
    [ -f "$f" ] || continue
    filename=$(basename "$f")
    echo "  Copying $filename"
    cp "$f" "$DEST_DIR/"
done
echo

echo "Copying *.toml files to $DEST_DIR (skip if already exists)"
for f in "$SOURCE_DIR"/*.toml; do
    [ -f "$f" ] || continue
    filename=$(basename "$f")
    if [ ! -f "$DEST_DIR/$filename" ]; then
        echo "  Copying $filename"
        cp "$f" "$DEST_DIR/"
    else
        echo "  Skipping $filename (already exists)"
    fi
done
echo

echo "Removing *.ahk files that do not exist in source"
for g in "$DEST_DIR"/*.ahk; do
    [ -f "$g" ] || continue
    filename=$(basename "$g")
    if [ ! -f "$SOURCE_DIR/$filename" ]; then
        echo "  Removing \"$filename\""
        rm "$g"
    fi
done
echo

echo "Done"
