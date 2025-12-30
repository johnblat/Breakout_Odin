package game 

import rl "vendor:raylib"
import la "core:math/linalg"
import "core:math"

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


get_brick_rectangle :: proc(index, pitch : int, brick_width, brick_height, brick_padding : f32) -> rl.Rectangle {
	r := index / pitch
	c := index % pitch

	x := f32(c) * brick_width
	y := f32(r) * brick_height

	rect := rl.Rectangle {x + brick_padding, y + brick_padding, brick_width - brick_padding*2, brick_height - brick_padding*2}
	return rect
}


main :: proc() {

	for &active in bricks {
		active = true
	}

	rl.InitWindow(screen_x, screen_y, "Breakout")

	for !rl.WindowShouldClose() {

		frame_time := rl.GetFrameTime()
		frame_time_cap : f32 = 0.01667
		frame_time = min(frame_time, frame_time_cap)

		mouse_position := rl.GetMousePosition()
		mouse_brick_row := int(mouse_position.y/brick_height)
		mouse_brick_column := int(mouse_position.x/brick_width)

		paddle.x = mouse_position.x - paddle.width/2
		if ball_attached_to_paddle {
			ball.x = mouse_position.x - ball.width/2
			ball.y = paddle.y - ball_size
			if rl.IsMouseButtonPressed(.LEFT) {
				ball_attached_to_paddle = false
				ball_speed = 500.0
			}
		}


		should_move_ball := !ball_attached_to_paddle

		if should_move_ball { 
			ball_direction = la.vector_normalize(ball_direction)
			ball_velocity := ball_direction * ball_speed

			ball.x += ball_velocity.x * frame_time
			ball.y += ball_velocity.y * frame_time

			ball_collides_with_top_of_playfield := ball.y < 0 
			if ball_collides_with_top_of_playfield {
				ball.y = 0
				ball_direction.y = -ball_direction.y
			}

			ball_out_of_bounds_on_bottom_of_playfield := ball.y > screen_y_f
			if ball_out_of_bounds_on_bottom_of_playfield {
				ball_attached_to_paddle = true
			}

			ball_collides_with_left_side_of_playfield := ball.x < 0
			ball_collides_with_right_side_of_playfield := ball.x + ball.width > screen_x_f 

			if ball_collides_with_left_side_of_playfield || ball_collides_with_right_side_of_playfield {
				ball_direction.x = -ball_direction.x
			}

			if ball_collides_with_left_side_of_playfield {
				ball.x = 0
			}

			if ball_collides_with_right_side_of_playfield {
				ball.x = screen_x_f - ball.width
			}

			collides_with_paddle := rl.CheckCollisionRecs(paddle, ball)
			if collides_with_paddle {
				collision_rect := rl.GetCollisionRec(paddle, ball)
				collision_rectangle_mid_x := collision_rect.x + collision_rect.width/2
				relative_intersect_x := paddle.x + (paddle.width/2) - collision_rectangle_mid_x
				normalized_intersect_x := relative_intersect_x / (paddle.width/2)
				bounce_angle := normalized_intersect_x * (5*3.14/12)
				ball_direction.x = -math.sin(bounce_angle)
				ball_direction.y = -math.cos(bounce_angle)
				ball.y = paddle.y - ball.height
			}

			for active, index in bricks {
				brick_rectangle := get_brick_rectangle(index, bricks_columns_count, brick_width, brick_height, 2)
				if active {
					collides := rl.CheckCollisionRecs(brick_rectangle, ball)
					if collides {
						collision_rect := rl.GetCollisionRec(brick_rectangle, ball)
						left_or_right_collision := collision_rect.height > collision_rect.width
						top_or_bottom_collision := !left_or_right_collision
						if left_or_right_collision {
							moving_left := ball_direction.x < 0
							if moving_left {
								ball.x = brick_rectangle.x + brick_rectangle.width
							} else {
								ball.x = brick_rectangle.x - ball.width
							}
							ball_direction.x = -ball_direction.x
						} else if top_or_bottom_collision {
							moving_up := ball_direction.y < 0
							if moving_up {
								ball.y = brick_rectangle.y + brick_rectangle.height
							} else {
								ball.y = brick_rectangle.y - ball.height
							}
							ball_direction.y = -ball_direction.y
						}
						bricks[index] = false
						ball_speed += 40
					}
				}
			}
		}

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
			rect := get_brick_rectangle(brick_index, bricks_columns_count, brick_width, brick_height, 2)			
			rl.DrawRectangleRec(rect, row_colors[r])
		}

		rl.DrawRectangleRec(paddle, rl.WHITE)
		rl.DrawRectangleRec(ball, rl.RAYWHITE)
		rl.EndDrawing()
	}
}