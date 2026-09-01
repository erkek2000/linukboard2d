#ifndef LINUKBOARD_MINIMAX_ENGINE_HPP
#define LINUKBOARD_MINIMAX_ENGINE_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/vector2i.hpp>

namespace godot {

class MinimaxEngine : public RefCounted {
	GDCLASS(MinimaxEngine, RefCounted)

protected:
	static void _bind_methods();

public:
	Dictionary search(const Array &board, Vector2i ai_position, Vector2i player_position,
			int depth, bool pruning) const;
};

} // namespace godot

#endif
