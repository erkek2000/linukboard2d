#include "../native/minimax_core.hpp"

#include <cassert>
#include <iostream>

using namespace linukboard;

namespace {

Board initial_board() {
	Board board{};
	board[7 * BOARD_SIZE + 3] = 1;
	board[0 * BOARD_SIZE + 4] = 2;
	return board;
}

void test_depth_zero_evaluation() {
	const SearchResult result = find_best_move(initial_board(), {0, 4}, {7, 3}, 0, true);
	assert(result.evaluation == 0);
	assert((result.move == Position{-1, -1}));
	assert(result.calls[0] == 1);
}

void test_pruning_preserves_choice() {
	const SearchResult without_pruning = find_best_move(initial_board(), {0, 4}, {7, 3}, 2, false);
	const SearchResult with_pruning = find_best_move(initial_board(), {0, 4}, {7, 3}, 2, true);
	assert(without_pruning.evaluation == with_pruning.evaluation);
	assert(without_pruning.move == with_pruning.move);
	assert(without_pruning.block1 == with_pruning.block1);
	assert(without_pruning.block2 == with_pruning.block2);
	assert(with_pruning.calls[0] <= without_pruning.calls[0]);
}

void test_terminal_ai_win() {
	Board board = initial_board();
	for (int x = 6; x < BOARD_SIZE; ++x) {
		for (int y = 2; y <= 4; ++y) {
			if (x != 7 || y != 3) {
				board[x * BOARD_SIZE + y] = -1;
			}
		}
	}
	const SearchResult result = find_best_move(board, {0, 4}, {7, 3}, 3, true);
	assert(result.evaluation == 100030);
	assert((result.move == Position{-1, -1}));
	assert(result.calls[3] == 1);
}

} // namespace

int main() {
	test_depth_zero_evaluation();
	test_pruning_preserves_choice();
	test_terminal_ai_win();
	std::cout << "minimax core tests passed\n";
	return 0;
}
