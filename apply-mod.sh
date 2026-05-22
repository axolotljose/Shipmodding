#!/bin/bash
# Light Shield Mod - Apply Script
# This script applies the Light Shield mod to a Ship of Harkinian repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${1:-.}"

if [ ! -d "$REPO_ROOT/soh/soh/Enhancements" ]; then
    echo "ERROR: This doesn't look like a Shipwright repository."
    echo "Usage: ./apply-mod.sh /path/to/Shipwright"
    echo "Or run from within the Shipwright repo: ./apply-mod.sh"
    exit 1
fi

echo "=== Light Shield Mod Installer ==="
echo "Target repository: $REPO_ROOT"
echo ""

# Step 1: Copy the LightShield directory
echo "[1/4] Copying LightShield module..."
mkdir -p "$REPO_ROOT/soh/soh/Enhancements/LightShield"
cp "$SCRIPT_DIR/soh/soh/Enhancements/LightShield/LightShield.cpp" "$REPO_ROOT/soh/soh/Enhancements/LightShield/"
cp "$SCRIPT_DIR/soh/soh/Enhancements/LightShield/LightShield.h" "$REPO_ROOT/soh/soh/Enhancements/LightShield/"

# Step 2: Add to CMakeLists.txt
echo "[2/4] Updating CMakeLists.txt..."
CMAKE_FILE="$REPO_ROOT/soh/soh/Enhancements/CMakeLists.txt"
if [ -f "$CMAKE_FILE" ]; then
    # Check if already added
    if ! grep -q "LightShield" "$CMAKE_FILE"; then
        # Add the LightShield source file after the comment about new source files
        sed -i '/# Add new source files here/a \
set(ENHANCEMENT_SRCS ${ENHANCEMENT_SRCS} ${CMAKE_CURRENT_SOURCE_DIR}/LightShield/LightShield.cpp)' "$CMAKE_FILE"
        echo "      - Added LightShield.cpp to CMakeLists.txt"
    else
        echo "      - LightShield already in CMakeLists.txt, skipping"
    fi
else
    echo "WARNING: Could not find $CMAKE_FILE"
    echo "         You may need to manually add the LightShield source file."
fi

# Step 3: Add to mods.cpp
echo "[3/4] Updating mods.cpp..."
MODS_FILE="$REPO_ROOT/soh/soh/Enhancements/mods.cpp"
if [ -f "$MODS_FILE" ]; then
    if ! grep -q "LightShield" "$MODS_FILE"; then
        # Add include
        sed -i '1a #include "LightShield/LightShield.h"' "$MODS_FILE"
        # Add init call inside InitMods function
        sed -i '/void InitMods() {/a \    LightShield_Init();' "$MODS_FILE"
        echo "      - Added LightShield_Init() to mods.cpp"
    else
        echo "      - LightShield already in mods.cpp, skipping"
    fi
else
    echo "WARNING: Could not find $MODS_FILE"
    echo "         You may need to manually add the LightShield init."
fi

# Step 4: Add to SohMenuEnhancements.cpp
echo "[4/4] Updating SohMenuEnhancements.cpp..."
MENU_FILE="$REPO_ROOT/soh/soh/SohGui/SohMenuEnhancements.cpp"
if [ -f "$MENU_FILE" ]; then
    if ! grep -q "LightShield" "$MENU_FILE"; then
        # Add include after TimeDisplay include
        sed -i '/#include <soh\/Enhancements\/TimeDisplay\/TimeDisplay.h>/a #include <soh\/Enhancements\/LightShield\/LightShield.h>' "$MENU_FILE"
        
        # Add menu entries after AssignableTunicsAndBoots
        # Find the line with AssignableTunicsAndBoots tooltip and add after it
        sed -i '/Allows equipping tunics and boots to C-buttons/a \\n    // Light Shield Enhancement\n    path = { "Enhancements", "Equipment", "Gameplay" };\n    AddWidget(path, "Light Shield", WIDGET_SEPARATOR);\n    AddWidget(path, "Enable Light Shield", WIDGET_CVAR_CHECKBOX)\n        .CVar("gEnhancements.LightShield")\n        .Options(CheckboxOptions().Tooltip(\n            "When enabled, your shield will glow with warm golden light at nighttime, "\n            "illuminating the area around you."));\n    AddWidget(path, "Start with Light Shield", WIDGET_CVAR_CHECKBOX)\n        .CVar("gEnhancements.LightShield.StartWithShield")\n        .Options(CheckboxOptions().Tooltip(\n            "Start new games with a Deku Shield (Light Shield) already equipped."));' "$MENU_FILE"
        echo "      - Added LightShield menu entries"
    else
        echo "      - LightShield already in menu, skipping"
    fi
else
    echo "WARNING: Could not find $MENU_FILE"
    echo "         You may need to manually add the menu entries."
fi

echo ""
echo "=== Mod Applied Successfully! ==="
echo ""
echo "Next steps:"
echo "  1. Build Ship of Harkinian following the official BUILDING.md guide"
echo "  2. Or push to your fork and use GitHub Actions to build"
echo "  3. In-game: Go to Enhancements > Equipment > Gameplay to enable"
echo ""
