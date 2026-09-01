# Native minimax build

The recursive minimax search, alpha-beta pruning, move generation, victory
evaluation, and board scoring live in `native/`. GDScript converts no recursive
state: `scripts/game.gd` makes one `MinimaxEngine.search()` call per AI turn.

## Prerequisites

- Godot 4.7
- Python 3.8 or newer
- SCons 4 or newer
- A C++ compiler supported by Godot (MSVC on Windows, GCC or Clang on Linux,
  and Apple Clang on macOS)

Initialize the pinned dependency after cloning:

```sh
git submodule update --init --recursive
```

## Build

From the repository root, build the debug library used by editor and debug
exports:

```sh
scons platform=windows target=template_debug
scons platform=linux target=template_debug
scons platform=macos target=template_debug
```

Replace `template_debug` with `template_release` for release exports. Only run
the command matching the current platform unless cross-compilers are installed.
The output is written to `bin/`, where `bin/linukboard_ai.gdextension` loads it.

Build and run the C++ core regression tests independently of Godot:

```sh
scons tests
./build/tests/minimax_core_test
```

On Windows, the executable is `build/tests/minimax_core_test.exe`.
