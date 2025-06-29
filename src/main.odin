package main

import "core:fmt"
import rl "vendor:raylib"

Player :: struct {
	position:   rl.Vector2,
	velocity:   rl.Vector2,
	speed:      f32,
	is_jumping: bool,
}

FONT_SIZE: i32 : 20
GRAVITY: rl.Vector2 : {0.0, 1800.0}
JUMP_FORCE: f32 : 200.0

physics :: proc(player: ^Player, ground_height: i32) {
	player.velocity += GRAVITY * rl.GetFrameTime()
	player.position += player.velocity * rl.GetFrameTime()

	if player.position.y > f32(ground_height) - 40.0 {
		player.velocity.y = 0.0
		player.is_jumping = false
	}
}

player_input :: proc(player: ^Player) {
	if rl.IsKeyDown(.D) {
		player.position.x += player.speed * rl.GetFrameTime()
	}
	if rl.IsKeyDown(.A) {
		player.position.x -= player.speed * rl.GetFrameTime()
	}
	if rl.IsKeyDown(.SPACE) {
		player.velocity.y -= JUMP_FORCE
		player.is_jumping = true
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

	player := Player{player_position, player_velocity, 200.0, false}
	ground_height: i32 = screen_height - 50

	for !rl.WindowShouldClose() {
		// game logic
		if rl.IsKeyPressed(.ESCAPE) {
			rl.CloseWindow()
		}

		player_input(&player)
		physics(&player, ground_height)

		// drawing
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawRectangle(i32(player.position.x), i32(player.position.y), 40.0, 40.0, rl.BLACK)
		rl.DrawLine(0, ground_height, screen_width, ground_height, rl.BLACK)
		rl.DrawLine(100, ground_height - 100, 300, ground_height - 100, rl.BLACK)

		rl.DrawText("Press Escape to close", 0.0, 0.0, FONT_SIZE, rl.BLACK)
		rl.EndDrawing()
	}
}
