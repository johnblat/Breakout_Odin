package game 

import rl "vendor:raylib"
import "core:fmt"

bricks := [112]bool{}

bricks_rows_count : int = 8
bricks_columns_count : int = 14



row_colors := [8]rl.Color {
	rl.RED,
	rl.RED,
	rl.ORANGE,
	rl.ORANGE,
	rl.GREEN,
	rl.GREEN,
	rl.YELLOW,
	rl.YELLOW,
}


screen_x : i32 = 896
screen_x_f : f32 = f32(screen_x)
screen_y : i32 = 896
screen_y_f : f32 = f32(screen_y)

brick_width := screen_x_f / f32(bricks_rows_count)
brick_height : f32 = 20

main :: proc() {

	for &active in bricks {
		active = true
	}

	rl.InitWindow(screen_x, screen_y, "Breakout")

	for !rl.WindowShouldClose() {

		mouse_position := rl.GetMousePosition()
		mouse_brick_row := int(mouse_position.y/brick_height)
		mouse_brick_column := int(mouse_position.x/brick_width)

		is_valid_row := mouse_brick_row >= 0 && mouse_brick_row < bricks_rows_count 
		is_valid_column := mouse_brick_column >= 0 && mouse_brick_column < bricks_columns_count

		if is_valid_row && is_valid_column {
			holding_left_button := rl.IsMouseButtonDown(.LEFT)
			if holding_left_button {
				brick_index := mouse_brick_row * bricks_columns_count + mouse_brick_column
				bricks[brick_index] = true
			}
			holding_right_button := rl.IsMouseButtonDown(.RIGHT)
			if holding_right_button {
				brick_index := mouse_brick_row * bricks_columns_count + mouse_brick_column
				bricks[brick_index] = false
			}
		}

		rl.BeginDrawing()

		rl.ClearBackground(rl.BLACK)

		for active, brick_index in bricks {
			if !active do continue
			
			r := brick_index / bricks_columns_count
			c := brick_index % bricks_columns_count

			x := f32(c) * brick_width
			y := f32(r) * brick_height

			padding : f32 = 2

			rect := rl.Rectangle {x + padding, y + padding, brick_width - padding*2, brick_height - padding*2}
			rl.DrawRectangleRec(rect, row_colors[r])
		}

		rl.EndDrawing()
	}
}