package main

import "core:fmt"
import rl "vendor:raylib"

Player :: struct {
	position: rl.Vector2,
	speed:    f32,
}

FONT_SIZE: i32 : 20

player_input :: proc(player: ^Player) {
	direction := rl.Vector2{0.0, 0.0}

	if rl.IsKeyDown(.W) {
		direction.y -= 1
	}
	if rl.IsKeyDown(.S) {
		direction.y += 1
	}
	if rl.IsKeyDown(.D) {
		direction.x += 1
	}
	if rl.IsKeyDown(.A) {
		direction.x -= 1
	}
	player.position += direction * player.speed * rl.GetFrameTime()
}

main :: proc() {
	// raylib initialization
	screen_width, screen_height: i32 : 1280, 720
	rl.InitWindow(screen_width, screen_height, "Game")
	defer rl.CloseWindow()

	rl.SetTargetFPS(30)
	rl.SetTraceLogLevel(.WARNING)

	// game initialization
	player := Player{rl.Vector2{f32(screen_width) / 2.0, f32(screen_height) / 2.0}, 200.0}

	for !rl.WindowShouldClose() {
		// game logic
		if rl.IsKeyPressed(.ESCAPE) {
			rl.CloseWindow()
		}

		player_input(&player)

		// drawing
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawRectangle(i32(player.position.x), i32(player.position.y), 40.0, 40.0, rl.BLACK)

		rl.DrawText("Press Escape to close", 0.0, 0.0, FONT_SIZE, rl.BLACK)
		rl.EndDrawing()
	}
}
