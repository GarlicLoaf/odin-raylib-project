package main

import "core:fmt"
import rl "vendor:raylib"

Player :: struct {
	x: i32,
	y: i32,
}

FONT_SIZE: i32 : 20

main :: proc() {
	// raylib initialization
	screen_width, screen_height: i32 : 1280.0, 720.0
	rl.InitWindow(screen_width, screen_height, "Game")
	defer rl.CloseWindow()

	rl.SetTargetFPS(30)
	rl.SetTraceLogLevel(.WARNING)

    // game initialization
    player := Player{screen_width / 2.0, screen_height / 2.0}

	for !rl.WindowShouldClose() {
		// game logic
		if rl.IsKeyPressed(.ESCAPE) {
			rl.CloseWindow()
		}

		// drawing
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

        rl.DrawRectangle(player.x, player.y, 40.0, 40.0, rl.BLACK)

		rl.DrawText("Press Escape to close", 0.0, 0.0, FONT_SIZE, rl.BLACK)
		rl.EndDrawing()
	}
}
