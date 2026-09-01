# Modified Linuk Game: Minimax AI and Alpha-Beta Pruning

This repository contains a modified implementation of **Linuk**, an 8×8
turn-based adversarial board game developed with the Godot Engine. The game
features an artificial-intelligence opponent based on the Minimax algorithm and
provides optional Alpha-Beta Pruning for reducing the number of game states
examined during search.

The project was developed by **Mehmet Özer Bulut** as part of a bachelor's
thesis at **Yeditepe University**. It serves as an experimental platform for
evaluating the computational efficiency of Alpha-Beta Pruning under controlled
board configurations and Minimax search depths.

<img width="5670" height="8505" alt="Bachelor thesis poster for the Modified Linuk Game" src="https://github.com/user-attachments/assets/baa13577-3f03-496e-b75a-d5a316f507c0" />

## Abstract

Minimax provides a systematic method for selecting moves in deterministic,
two-player, zero-sum games, but its computational cost grows rapidly with the
search depth and branching factor. Alpha-Beta Pruning improves the practical
efficiency of Minimax by eliminating branches that cannot influence the final
decision.

This project implements both configurations in GDScript and records search
behavior across different depths. The resulting measurements can be used to
compare execution time and the number of evaluated states while confirming that
pruning preserves the move selected by the complete Minimax search.

## About the game

Linuk is played by a human participant and an AI opponent on an 8×8 board. Each
participant controls one piece and attempts to restrict the opponent's movement
by occupying empty squares with permanent blocks.

During a turn, a participant:

1. Moves their piece to an empty adjacent square, including diagonally.
2. Places a block on an empty square.
3. Places a second block on another empty square.

A participant loses when their piece has no valid adjacent move.

## Features

- Recursive Minimax search implemented entirely in GDScript
- Optional Alpha-Beta Pruning
- Configurable search depth from 1 to 6
- Standard and center-oriented starting positions
- Optional automatic depth adjustment based on game state
- Execution-time and per-depth search-call diagnostics
- Debug output for examining AI decisions
- Menu controls for configuring and restarting experiments

## Minimax model

The AI is represented as the maximizing participant and the human player as the
minimizing participant. At each search node, the algorithm generates candidate
piece movements and block placements before recursively evaluating the
resulting board states.

Non-terminal states are evaluated using the difference between the available
adjacent squares around the two pieces:

```text
evaluation = AI mobility - player mobility
```

Winning and losing states receive substantially larger positive or negative
scores. Remaining search depth is included in terminal scores, causing the AI
to prefer earlier wins and postpone unavoidable losses.

## Alpha-Beta Pruning

Alpha-Beta Pruning avoids evaluating branches that cannot change the outcome
of the Minimax decision:

- **Alpha** is the best score currently guaranteed to the maximizing
  participant.
- **Beta** is the best score currently guaranteed to the minimizing
  participant.
- Further evaluation of a branch stops when `beta <= alpha`.

The optimization changes the amount of work performed by the search without
changing the theoretical Minimax result.

## Experimental use

The project can compare standard Minimax with Alpha-Beta Pruning using the
following measurements:

- Total execution time for an AI decision
- Number of calls made at each search depth
- Number of terminal or depth-limited states evaluated
- Effect of increasing search depth on response time
- Selected move under pruned and unpruned search

For a controlled comparison, keep the following variables constant between
runs:

- Initial board configuration
- Search depth
- Turn order
- Board state at the start of the measured AI turn
- Debug and automatic-depth settings
- Hardware and Godot version

Because execution time is affected by background processes and runtime
conditions, repeated trials should be reported using an average together with
a measure of variation.

## Requirements

- Godot Engine 4.x

The AI is implemented in GDScript, so no external libraries or native
compilation steps are required.

## Running the project

1. Clone or download the repository.
2. Open the Godot Engine project manager.
3. Import `project.godot` from the repository root.
4. Open the project and press **F5**, or select **Run Project** in the editor.

The configured main scene is `scenes/menu.tscn`.

## Game and experiment settings

The main menu provides the following controls:

- **Minimax Depth:** Selects the maximum recursive search depth.
- **Enable Pruning:** Enables Alpha-Beta Pruning.
- **Enable Center Positions:** Moves the initial pieces closer to the center.
- **Enable Iterative Depth:** Adjusts search depth using the current turn and
  piece mobility.
- **Debug Enabled:** Prints detailed search information to the Godot output
  console.

Search complexity increases rapidly with depth. Higher settings can therefore
produce long waits when the recursive search runs in GDScript.

## Project structure

```text
assets/                 Game artwork and icons
scenes/                 Menu, game, information, and board scenes
scripts/game.gd         Rules, move generation, evaluation, and Minimax search
scripts/menu.gd         Menu controls and experiment settings
scripts/game_data.gd    Shared configuration
project.godot           Godot project configuration
```

## C++ migration and performance

A native GDExtension version of the Minimax search is available on the
[`cpp-migration` branch](https://github.com/erkek2000/linukboard2d/tree/cpp-migration).
That branch retains the GDScript implementation for comparison and adds a menu
option for switching between GDScript and C++.

The following depth-3 timings were observed for the same search workload:

| Implementation | Search time | Relative speed |
| --- | ---: | ---: |
| GDScript | 246.482 seconds | 1× |
| C++ GDExtension | 0.291 seconds | approximately 847× faster |

Both implementations reported the same 3,211,392 counted search states:

```text
depth 0: 3,198,811
depth 1:    12,480
depth 2:       100
depth 3:         1
```

For this run, the C++ migration reduced search time by approximately **99.882%**
and saved **246.191 seconds** on a single AI decision. These figures represent
one observed debug run; absolute timings vary with hardware, compiler settings,
board position, pruning configuration, and search depth.

## Academic context

This software was produced as part of the bachelor's thesis of Mehmet Özer
Bulut at Yeditepe University. Its primary purpose is to demonstrate and
experimentally examine the effect of Alpha-Beta Pruning on adversarial search
efficiency in a playable game environment.
