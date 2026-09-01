#ifndef LINUKBOARD_MINIMAX_CORE_HPP
#define LINUKBOARD_MINIMAX_CORE_HPP

#include <array>
#include <cstdint>

namespace linukboard {

constexpr int BOARD_SIZE = 8;
constexpr int BOARD_CELL_COUNT = BOARD_SIZE * BOARD_SIZE;
constexpr int MAX_TRACKED_DEPTH = 6;

struct Position {
	int x = -1;
	int y = -1;

	bool operator==(const Position &other) const {
		return x == other.x && y == other.y;
	}
};

using Board = std::array<std::int8_t, BOARD_CELL_COUNT>;

struct SearchResult {
	std::int64_t evaluation = 0;
	Position move;
	Position block1;
	Position block2;
	std::array<std::int64_t, MAX_TRACKED_DEPTH + 1> calls{};
};

SearchResult find_best_move(const Board &board, Position ai_position,
		Position player_position, int depth, bool pruning);

} // namespace linukboard

#endif
