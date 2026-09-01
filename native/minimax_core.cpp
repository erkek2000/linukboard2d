#include "minimax_core.hpp"

#include <algorithm>
#include <cstdlib>
#include <limits>

namespace linukboard {
namespace {

constexpr std::int64_t NEGATIVE_INFINITY = -9223372036854775800LL;
constexpr std::int64_t POSITIVE_INFINITY = 9223372036854775800LL;
constexpr std::array<Position, 8> DIRECTIONS{{
	{-1, 1}, {0, 1}, {1, 1}, {1, 0},
	{1, -1}, {0, -1}, {-1, -1}, {-1, 0},
}};

struct MoveResult {
	int completed = 0;
	int next_index = 0;
	Board board{};
	Position move;
	Position block1;
	Position block2;
};

struct SearchContext {
	bool pruning = false;
	std::array<std::int64_t, MAX_TRACKED_DEPTH + 1> calls{};
};

bool in_bounds(int index) {
	return index >= 0 && index < BOARD_SIZE;
}

int board_index(Position position) {
	return position.x * BOARD_SIZE + position.y;
}

int cell(const Board &board, Position position) {
	return board[board_index(position)];
}

void set_cell(Board &board, Position position, int value) {
	board[board_index(position)] = static_cast<std::int8_t>(value);
}

bool check_move(Position old_position, Position new_position, const Board &board) {
	if (!in_bounds(new_position.x) || !in_bounds(new_position.y) || cell(board, new_position) != 0) {
		return false;
	}
	const int delta_x = std::abs(new_position.x - old_position.x);
	const int delta_y = std::abs(new_position.y - old_position.y);
	return delta_x <= 1 && delta_y <= 1;
}

bool check_block(Position position, const Board &board) {
	return in_bounds(position.x) && in_bounds(position.y) && cell(board, position) == 0;
}

int calculate_position(Position position, const Board &board) {
	if (!in_bounds(position.x) || !in_bounds(position.y)) {
		return 0;
	}

	int points = 0;
	for (int x_offset = -1; x_offset <= 1; ++x_offset) {
		for (int y_offset = -1; y_offset <= 1; ++y_offset) {
			if (x_offset == 0 && y_offset == 0) {
				continue;
			}
			const Position adjacent{position.x + x_offset, position.y + y_offset};
			if (in_bounds(adjacent.x) && in_bounds(adjacent.y) && cell(board, adjacent) == 0) {
				++points;
			}
		}
	}
	return points;
}

// Returns 0 for no victory, 1 for the player, and 2 for the AI.
int check_victory(Position ai_position, Position player_position, const Board &board,
		bool maximizing_player) {
	const int player_mobility = calculate_position(player_position, board);
	const int ai_mobility = calculate_position(ai_position, board);

	if (!maximizing_player) {
		if (ai_mobility == 0) {
			return 1;
		}
	} else if (player_mobility == 0) {
		return 2;
	}

	if (!maximizing_player && player_mobility == 0) {
		return 2;
	}
	if (maximizing_player && ai_mobility == 0) {
		return 1;
	}
	return 0;
}

std::int64_t calculate_minimax_points(Position ai_position, Position player_position,
		const Board &board, bool maximizing_player, int depth) {
	const int victory = check_victory(ai_position, player_position, board, maximizing_player);
	if (victory == 1) {
		return -100000LL - (10LL * depth);
	}
	if (victory == 2) {
		return 100000LL + (10LL * depth);
	}
	return calculate_position(ai_position, board) - calculate_position(player_position, board);
}

MoveResult generate_move(const Board &board, Position self_position, Position opponent_position,
		int move_index) {
	MoveResult result;
	const int move_direction_index = (move_index / 64) % 8;
	const int block1_index = (move_index / 8) % 8;
	const int block2_index = move_index % 8;
	const int player = cell(board, self_position);
	const Position move_direction = DIRECTIONS[move_direction_index];
	const Position new_position{self_position.x + move_direction.x,
			self_position.y + move_direction.y};

	if (!check_move(self_position, new_position, board)) {
		result.next_index = move_index + 64;
		return result;
	}

	result.board = board;
	set_cell(result.board, self_position, 0);
	set_cell(result.board, new_position, player);
	result.move = new_position;

	const Position block1_direction = DIRECTIONS[block1_index];
	const Position block1_position{opponent_position.x + block1_direction.x,
			opponent_position.y + block1_direction.y};
	if (!check_block(block1_position, result.board)) {
		result.completed = 1;
		result.next_index = move_index + 8;
		return result;
	}

	set_cell(result.board, block1_position, -1);
	result.block1 = block1_position;
	const Position block2_direction = DIRECTIONS[block2_index];
	const Position block2_position{opponent_position.x + block2_direction.x,
			opponent_position.y + block2_direction.y};
	if (!check_block(block2_position, result.board) || block1_position == block2_position) {
		result.completed = 2;
		result.next_index = move_index + 1;
		return result;
	}

	set_cell(result.board, block2_position, -1);
	result.completed = 3;
	result.next_index = move_index + 1;
	result.block2 = block2_position;
	return result;
}

SearchResult minimax(const Board &board, Position ai_position, Position player_position,
		int depth, std::int64_t alpha, std::int64_t beta, bool maximizing_player,
		SearchContext &context) {
	SearchResult result;
	if (depth >= 0 && depth <= MAX_TRACKED_DEPTH) {
		++context.calls[depth];
	}

	if (depth == 0 || check_victory(ai_position, player_position, board, maximizing_player) != 0) {
		result.evaluation = calculate_minimax_points(
				ai_position, player_position, board, maximizing_player, depth);
		return result;
	}

	if (maximizing_player) {
		std::int64_t maximum_evaluation = NEGATIVE_INFINITY;
		int move_index = 0;
		while (move_index < 512) {
			const MoveResult move = generate_move(board, ai_position, player_position, move_index);
			if (move.completed == 3) {
				const SearchResult child = minimax(move.board, move.move, player_position,
						depth - 1, alpha, beta, false, context);
				if (child.evaluation > maximum_evaluation) {
					maximum_evaluation = child.evaluation;
					result.move = move.move;
					result.block1 = move.block1;
					result.block2 = move.block2;
				}
				if (context.pruning) {
					alpha = std::max(alpha, child.evaluation);
					if (beta <= alpha) {
						break;
					}
				}
			} else if (move.completed > 0) {
				++context.calls[0];
				if (check_victory(move.move, player_position, move.board, true) == 2) {
					result.evaluation = 100000LL + (10LL * depth);
					result.move = move.move;
					if (move.completed == 2) {
						result.block1 = move.block1;
					}
					return result;
				}
			}
			move_index = move.next_index;
		}
		result.evaluation = maximum_evaluation;
		return result;
	}

	std::int64_t minimum_evaluation = POSITIVE_INFINITY;
	int move_index = 0;
	while (move_index < 512) {
		const MoveResult move = generate_move(board, player_position, ai_position, move_index);
		if (move.completed == 3) {
			const SearchResult child = minimax(move.board, ai_position, move.move,
					depth - 1, alpha, beta, true, context);
			if (child.evaluation < minimum_evaluation) {
				minimum_evaluation = child.evaluation;
				result.move = move.move;
				result.block1 = move.block1;
				result.block2 = move.block2;
			}
			if (context.pruning) {
				beta = std::min(beta, child.evaluation);
				if (beta <= alpha) {
					break;
				}
			}
		} else if (move.completed > 0) {
			++context.calls[0];
			if (check_victory(ai_position, move.move, move.board, false) == 1) {
				result.evaluation = -100000LL - (10LL * depth);
				result.move = move.move;
				if (move.completed == 2) {
					result.block1 = move.block1;
				}
				return result;
			}
		}
		move_index = move.next_index;
	}
	result.evaluation = minimum_evaluation;
	return result;
}

} // namespace

SearchResult find_best_move(const Board &board, Position ai_position,
		Position player_position, int depth, bool pruning) {
	SearchContext context;
	context.pruning = pruning;
	SearchResult result = minimax(board, ai_position, player_position, depth,
			NEGATIVE_INFINITY, POSITIVE_INFINITY, true, context);
	result.calls = context.calls;
	return result;
}

} // namespace linukboard
