package main

import "core:fmt"
import "core:time"
import rl "vendor:raylib"

Player :: struct {
	position:  rl.Vector2,
	velocity:  rl.Vector2,
	speed:     f32,
	on_ground: bool,
}

FONT_SIZE: i32 : 20
GRAVITY: rl.Vector2 : {0.0, 2000.0}
JUMP_FORCE: f32 : 800.0


physics :: proc(player: ^Player, platforms: ^[2]rl.Rectangle) {
	if player.on_ground == false {
		player.position += player.velocity * rl.GetFrameTime()
		player.velocity += GRAVITY * rl.GetFrameTime()
	}

	for element in platforms {
		if rl.CheckCollisionRecs(
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
	screen_width, screen_height: f32 : 1280, 720
	rl.InitWindow(i32(screen_width), i32(screen_height), "Game")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)
	rl.SetTraceLogLevel(.WARNING)

	// game initialization
	player_position := rl.Vector2{screen_width / 2.0, screen_height / 2.0}
	player_velocity := rl.Vector2{0.0, 0.0}

	player := Player{player_position, player_velocity, 200.0, true}
	ground_height: f32 = screen_height - 50.0

	box_1: rl.Rectangle = {0.0, ground_height, screen_width, 5.0}
	box_2: rl.Rectangle = {100.0, ground_height - 100.0, 300.0, 5.0}

	platforms := [2]rl.Rectangle{box_1, box_2}

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

		rl.DrawRectangleRec(box_1, rl.BLACK)
		rl.DrawRectangleRec(box_2, rl.BLACK)

		rl.DrawText("Press Escape to close", 0.0, 0.0, FONT_SIZE, rl.BLACK)
		rl.EndDrawing()
	}
}
