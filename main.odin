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

paddle := rl.Rectangle {screen_x_f / 2, screen_y_f - 40, brick_width, brick_height}
ball_size : f32 = 20 
ball := rl.Rectangle {paddle.x + paddle.width, paddle.y - ball_size, ball_size, ball_size}
ball_direction := [2]f32{0,-1}
ball_speed : f32 = 0

ball_attached_to_paddle := true

main :: proc() {

	for &active in bricks {
		active = true
	}

	rl.InitWindow(screen_x, screen_y, "Breakout")

	for !rl.WindowShouldClose() {

		frame_time := rl.GetFrameTime()

		mouse_position := rl.GetMousePosition()
		mouse_brick_row := int(mouse_position.y/brick_height)
		mouse_brick_column := int(mouse_position.x/brick_width)

		paddle.x = mouse_position.x - paddle.width/2
		if ball_attached_to_paddle {
			ball.x = mouse_position.x - ball.width/2
			ball.y = paddle.y - ball_size
		}

		if rl.IsMouseButtonPressed(.LEFT) {
			ball_attached_to_paddle = false
			ball_speed = 300.0
		}

		ball_velocity := ball_direction * ball_speed
		ball.x += ball_velocity.x * frame_time
		ball.y += ball_velocity.y * frame_time

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

		rl.DrawRectangleRec(paddle, rl.WHITE)
		rl.DrawRectangleRec(ball, rl.RAYWHITE)
		rl.EndDrawing()
	}
}