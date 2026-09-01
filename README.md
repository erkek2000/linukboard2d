# LinukBoard2D

LinukBoard2D is a two-player strategy game built with Godot 4.7. The player
competes against a minimax-controlled opponent on an 8×8 board. Each turn moves
a piece to an adjacent square and places two blocks; the first immobilized
player loses.

This branch contains both the original recursive GDScript minimax and a native
C++ migration built with Godot's GDExtension API and `godot-cpp`. The active
implementation can be changed from the game menu with **Use C++ Minimax**.

## Performance

Moving the complete recursive search path to C++ produced the following
depth-3 result:

| Implementation | Search time | Relative speed |
| --- | ---: | ---: |
| GDScript | 246.482 seconds | 1× |
| C++ GDExtension | 0.291 seconds | approximately 847× faster |

Both searches visited the same 3,211,392 counted states:

```text
depth 0: 3,198,811
depth 1:    12,480
depth 2:       100
depth 3:         1
```

The native implementation reduced the measured search time by approximately
**99.882%**, saving **246.191 seconds**—about 4 minutes and 6 seconds—for that AI
move. Timings are from one observed debug run and will vary with hardware,
compiler settings, board position, pruning, and search depth.

## Minimax implementations

The menu's **Use C++ Minimax** check button controls the search engine:

- Unchecked: use the original GDScript implementation.
- Checked: use the native C++ implementation.
- Checked without a loaded native library: warn and safely fall back to
  GDScript.

The native side includes move generation, board copying, victory checks,
evaluation, alpha-beta pruning, search counters, and recursion. Only one call
crosses from GDScript into C++ for each AI turn.

## Requirements

Running with GDScript requires:

- Godot 4.7

Building and running the C++ implementation additionally requires:

- Python 3.8 or newer
- SCons 4 or newer
- A supported C++ compiler:
  - MSVC with **Desktop development with C++** on Windows
  - GCC or Clang on Linux
  - Apple Clang on macOS

## Clone

Clone recursively so that the `godot-cpp` submodule is included:

```sh
git clone --recurse-submodules <repository-url>
cd linukboard2d
```

For an existing clone:

```sh
git submodule update --init --recursive
```

## Build the C++ extension

From the project root, run the command for the current platform:

```sh
scons platform=windows target=template_debug
scons platform=linux target=template_debug
scons platform=macos target=template_debug
```

Use `target=template_release` for release exports. The resulting native library
is placed in `bin/` and loaded through
`bin/linukboard_ai.gdextension`.

On Windows, build from **Developer PowerShell for VS 2022**. After the first
successful build, restart Godot so that it discovers and registers
`MinimaxEngine`.

## Run

Open `project.godot` with Godot 4.7 and run the project. Leave **Use C++
Minimax** unchecked to run immediately with GDScript, or enable it after
building the native extension.

## Native tests

Build and run the standalone minimax regression tests:

```sh
scons tests
./build/tests/minimax_core_test
```

On Windows, run:

```powershell
.\build\tests\minimax_core_test.exe
```

## Project structure

```text
assets/                 Game artwork
bin/                    GDExtension manifest and compiled libraries
native/                 C++ minimax core and Godot binding
scenes/                 Godot scenes
scripts/                GDScript gameplay and original minimax
tests/                  Standalone C++ regression tests
SConstruct              Cross-platform native build configuration
```

More detailed native build notes are available in [NATIVE_BUILD.md](NATIVE_BUILD.md).
