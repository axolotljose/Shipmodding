# Light Shield Mod for Ship of Harkinian

A mod that adds a **Light Shield** enhancement to Ship of Harkinian. When enabled, your shield glows with warm golden light at nighttime, illuminating the area around you.

## Features

- **Nighttime Glow**: When you have a shield equipped at night, it emits a warm golden light that helps you see in the dark
- **Start with Shield**: Option to begin new games with a Deku Shield (Light Shield) already equipped
- **Toggleable**: Enable/disable the effect anytime from the Enhancements menu
- **Zero Performance Impact**: Uses the game's built-in lighting system efficiently

## How to Build (Using GitHub Actions - Easiest Method)

Since this is a code mod for Ship of Harkinian, it requires compiling the game. The easiest way is to use GitHub's free build servers (Actions):

### Step 1: Fork the Shipwright Repository

1. Go to https://github.com/HarbourMasters/Shipwright
2. Click the **Fork** button (top right)
3. This creates your own copy of the repository

### Step 2: Apply the Mod Files

**Option A: Apply the patch automatically**

1. Clone your forked repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Shipwright.git
   cd Shipwright
   git checkout develop
   ```

2. Copy the mod files into the repo:
   ```bash
   # Copy the LightShield directory
   cp -r /path/to/this/mod/soh/soh/Enhancements/LightShield soh/soh/Enhancements/
   ```

3. Apply the patch:
   ```bash
   git apply light-shield.patch
   ```

4. Commit and push:
   ```bash
   git add -A
   git commit -m "Add Light Shield mod"
   git push origin develop
   ```

**Option B: Manual file edits**

If the patch doesn't apply cleanly, manually:

1. Copy `soh/soh/Enhancements/LightShield/` directory to your forked repo at the same path
2. Add the source file to CMake in `soh/soh/Enhancements/CMakeLists.txt`:
   ```cmake
   set(ENHANCEMENT_SRCS ${ENHANCEMENT_SRCS} ${CMAKE_CURRENT_SOURCE_DIR}/LightShield/LightShield.cpp)
   ```
3. Add the include to `soh/soh/Enhancements/mods.cpp`:
   ```cpp
   #include "LightShield/LightShield.h"
   ```
   And call `LightShield_Init();` inside `InitMods()`
4. Add menu entries to `soh/soh/SohGui/SohMenuEnhancements.cpp` in the Equipment > Gameplay section

### Step 3: Build with GitHub Actions

1. In your fork on GitHub, go to **Actions** tab
2. Find the workflow for your platform (Windows/Linux/macOS)
3. Click **Run workflow** or create a Pull Request from your changes
4. Wait for the build to complete (may take 30-60 minutes)
5. Download the built artifact from the Actions page or PR description

### Step 4: Install and Play

1. Download the built Ship of Harkinian zip for your platform
2. Extract it and run as normal
3. Go to **Enhancements > Equipment > Gameplay** in the menu
4. Enable **"Enable Light Shield"**
5. Start a new game (or load existing save) and enjoy!

## How to Build Locally

If you prefer to build on your own machine, follow the [official BUILDING guide](https://github.com/HarbourMasters/Shipwright/blob/develop/docs/BUILDING.md) for your platform, then apply the mod patch before building.

### Windows Requirements
- Visual Studio 2022 Community Edition
- CMake
- Python 3
- Git

### Linux Requirements
```bash
# Debian/Ubuntu
sudo apt-get install gcc g++ git cmake ninja-build libsdl2-dev libpng-dev libsdl2-net-dev libzip-dev libboost-dev

# Then apply the patch and build as described in BUILDING.md
```

### macOS Requirements
```bash
brew install sdl2 libpng glew ninja cmake tinyxml2 nlohmann-json libzip opusfile libvorbis
# Then apply the patch and build as described in BUILDING.md
```

## How It Works

The mod hooks into two game systems:

1. **Save Initialization**: When a new save is created, if the enhancement is enabled, it adds a Deku Shield to your inventory and auto-equips it

2. **Player Update**: Every frame, the mod checks:
   - Is the Light Shield enhancement enabled?
   - Is it nighttime? (OoT's day/night cycle: night = 0xC001-0x3FFF)
   - Do you have a shield equipped?
   
   If all conditions are met, a dynamic point light is attached to the player at shield height, creating a warm golden glow effect.

## Files Added/Modified

### New Files
- `soh/soh/Enhancements/LightShield/LightShield.cpp` - Main mod implementation
- `soh/soh/Enhancements/LightShield/LightShield.h` - Header file

### Modified Files
- `soh/soh/Enhancements/CMakeLists.txt` - Added source to build
- `soh/soh/Enhancements/mods.cpp` - Initialize the mod
- `soh/soh/SohGui/SohMenuEnhancements.cpp` - Added menu entries

## Compatibility

- Works with SoH v9.0.0+
- Compatible with Randomizer
- Compatible with existing shield model replacement mods
- No conflicts with other enhancements

## License

This mod follows the same license as Ship of Harkinian (CC0). No Nintendo assets are included.
