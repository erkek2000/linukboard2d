#include "minimax_engine.hpp"

#include "minimax_core.hpp"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string.hpp>

namespace godot {
namespace {

Dictionary error_result(const String &message) {
	Dictionary result;
	result["ok"] = false;
	result["error"] = message;
	return result;
}

bool valid_position(Vector2i position) {
	return position.x >= 0 && position.x < linukboard::BOARD_SIZE &&
			position.y >= 0 && position.y < linukboard::BOARD_SIZE;
}

Vector2i to_vector(linukboard::Position position) {
	return Vector2i(position.x, position.y);
}

} // namespace

void MinimaxEngine::_bind_methods() {
	ClassDB::bind_method(D_METHOD("search", "board", "ai_position", "player_position", "depth", "pruning"),
			&MinimaxEngine::search, DEFVAL(false));
}

Dictionary MinimaxEngine::search(const Array &board, Vector2i ai_position,
		Vector2i player_position, int depth, bool pruning) const {
	if (depth < 0 || depth > linukboard::MAX_TRACKED_DEPTH) {
		return error_result("Minimax depth must be between 0 and 6.");
	}
	if (!valid_position(ai_position) || !valid_position(player_position)) {
		return error_result("AI and player positions must be inside the 8x8 board.");
	}
	if (board.size() != linukboard::BOARD_SIZE) {
		return error_result("Minimax board must contain exactly 8 rows.");
	}

	linukboard::Board native_board{};
	for (int row_index = 0; row_index < linukboard::BOARD_SIZE; ++row_index) {
		const Variant row_variant = board[row_index];
		if (row_variant.get_type() != Variant::ARRAY) {
			return error_result("Every minimax board row must be an Array.");
		}
		const Array row = row_variant;
		if (row.size() != linukboard::BOARD_SIZE) {
			return error_result("Every minimax board row must contain exactly 8 cells.");
		}
		for (int column_index = 0; column_index < linukboard::BOARD_SIZE; ++column_index) {
			const Variant value_variant = row[column_index];
			if (value_variant.get_type() != Variant::INT) {
				return error_result("Every minimax board cell must be an integer.");
			}
			const std::int64_t value = value_variant;
			if (value != -1 && value != 0 && value != 1 && value != 2) {
				return error_result("Minimax board cells must be -1, 0, 1, or 2.");
			}
			native_board[row_index * linukboard::BOARD_SIZE + column_index] =
					static_cast<std::int8_t>(value);
		}
	}

	const linukboard::SearchResult native_result = linukboard::find_best_move(
			native_board, {ai_position.x, ai_position.y},
			{player_position.x, player_position.y}, depth, pruning);

	Array calls;
	calls.resize(linukboard::MAX_TRACKED_DEPTH + 1);
	for (int index = 0; index <= linukboard::MAX_TRACKED_DEPTH; ++index) {
		calls[index] = native_result.calls[index];
	}

	Dictionary result;
	result["ok"] = true;
	result["eval"] = native_result.evaluation;
	result["move"] = to_vector(native_result.move);
	result["block1"] = to_vector(native_result.block1);
	result["block2"] = to_vector(native_result.block2);
	result["calls"] = calls;
	return result;
}

} // namespace godot
