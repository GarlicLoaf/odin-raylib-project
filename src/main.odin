package main

import "core:fmt"
import rl "vendor:raylib"

Player :: struct {
	position:  rl.Vector2,
	velocity:  rl.Vector2,
	speed:     f32,
	on_ground: bool,
}

HLine :: struct {
	x, y, length: i32,
	color:        rl.Color,
}

FONT_SIZE: i32 : 20
GRAVITY: rl.Vector2 : {0.0, 1800.0}
JUMP_FORCE: f32 : 800.0

check_collision_rec_hline :: proc(rec: rl.Rectangle, line: HLine) -> bool {
	return(
		(f32(rec.y) + rec.height > f32(line.y)) &&
		(rec.y <= f32(line.y)) &&
		(rec.x + rec.width >= f32(line.x)) &&
		rec.x <= f32(line.x) + f32(line.length) \
	)
}

draw_hline :: proc(line: ^HLine) {
	rl.DrawLine(line.x, line.y, line.length, line.y, line.color)
}

physics :: proc(player: ^Player, platforms: ^[2]HLine) {
	if player.on_ground == false {
		player.velocity += GRAVITY * rl.GetFrameTime()
		player.position += player.velocity * rl.GetFrameTime()
	}

	for element in platforms {
		if check_collision_rec_hline(
			rl.Rectangle{player.position.x, player.position.y, 40.0, 40.0},
			element,
		) {
			player.velocity.y = 0.0
			player.on_ground = true
		}
	}
}

player_input :: proc(player: ^Player) {
	if rl.IsKeyDown(.D) {
		player.position.x += player.speed * rl.GetFrameTime()
	}
	if rl.IsKeyDown(.A) {
		player.position.x -= player.speed * rl.GetFrameTime()
	}
	if rl.IsKeyDown(.SPACE) && player.on_ground {
		player.velocity.y -= JUMP_FORCE
		player.on_ground = false
	}
}

main :: proc() {
	// raylib initialization
	screen_width, screen_height: i32 : 1280, 720
	rl.InitWindow(screen_width, screen_height, "Game")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)
	rl.SetTraceLogLevel(.WARNING)

	// game initialization
	player_position := rl.Vector2{f32(screen_width) / 2.0, f32(screen_height) / 2.0}
	player_velocity := rl.Vector2{0.0, 0.0}

	player := Player{player_position, player_velocity, 200.0, true}
	ground_height: i32 = screen_height - 50

	line_1: HLine = {0, ground_height, screen_width, rl.BLACK}
	line_2: HLine = {100, ground_height - 100, 300, rl.BLACK}

	platforms := [2]HLine{line_1, line_2}

	for !rl.WindowShouldClose() {
		// game logic
		if rl.IsKeyPressed(.ESCAPE) {
			rl.CloseWindow()
		}

		player_input(&player)
		physics(&player, &platforms)

		// drawing
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawRectangle(i32(player.position.x), i32(player.position.y), 40.0, 40.0, rl.BLACK)
		draw_hline(&line_1)
		draw_hline(&line_2)

		rl.DrawText("Press Escape to close", 0.0, 0.0, FONT_SIZE, rl.BLACK)
		rl.EndDrawing()
	}
}
