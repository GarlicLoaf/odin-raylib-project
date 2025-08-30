package main

import "core:fmt"
import "core:math/noise"
import rl "vendor:raylib"

FONT_SIZE: i32 : 20

Terrain :: struct {
	tiles:         [][]f32,
	width, height: int,
}

Camera2D :: struct {
	pos:           rl.Vector2,
	zoom:          f64,
	width, height: f64,
}

simple_blur :: proc(tiles: ^[][]f32) {
	w := len(tiles[1])
	h := len(tiles)

	if w == 0 || h == 0 {return}

	for x in 1 ..< w - 2 {
		for y in 1 ..< h - 2 {
			tiles[x][y] =
				(tiles[x][y] +
					tiles[x + 1][y] +
					tiles[x - 1][y] +
					tiles[x][y + 1] +
					tiles[x][y - 1]) /
				5
		}
	}
}


generate_terrain :: proc(size: int) -> Terrain {
	tiles := make([][]f32, size)
	scale := 0.05

	pos: [2]f64
	for x in 0 ..< size {
		row := make([]f32, size)

		for y in 0 ..< size {
			pos[0] = f64(x) * scale
			pos[1] = f64(y) * scale
			row[y] = f32((noise.noise_2d(1, pos) + 1) / 2)
		}
		tiles[x] = row
	}

	simple_blur(&tiles)

	terrain := Terrain{tiles, size, size}
	return terrain
}

cam_to_world :: proc(cam: Camera2D, input: rl.Vector2) -> (rl.Vector2, ok: bool) {
	output := rl.Vector2{}

    if input.x < 0.0 || input.x > cam.width || input.y < 0.0 || input.y > cam.height {
        return output, false
    }
	output.x := cam.pos.x + (input.x - cam.pos.x) * cam.zoom
	output.y := cam.pos.y + (input.y - cam.pos.y) * cam.zoom
    
    return output, true
}

world_to_cam :: proc(cam: Camera2D, input: rl.Vector2) -> (rl.Vector2, ok: bool) {
	output := rl.Vector2{}

	output[0] := cam.pos[0] + (input[0] - cam.pos[0]) / cam.zoom
	output[1] := cam.pos[1] + (input[1] - cam.pos[1]) / cam.zoom

    ok := (0.0 <= output.x && output.x <= cam.width) &&
          (0.0 <= output.y && output.y <= cam.height)
    
    return output, true
}

draw_terrain :: proc(terrain: Terrain, tile_size: int, cam: Camera2D) {
	cam_left := int(cam.pos[0]) / tile_size
	cam_top := int(cam.pos[1]) / tile_size
	cam_right := cam_left + int(cam.width) / 64
	cam_bot := cam_top + int(cam.height) / 64

	for i, x in cam_left ..< cam_right {
		for j, y in cam_top ..< cam_bot {
			if terrain.tiles[i][j] > 0.75 {
				rl.DrawRectangle(
					i32(f64(x * tile_size) * cam.zoom),
					i32(f64(y * tile_size) * cam.zoom),
					32,
					32,
					rl.BLUE,
				)
			} else {
				rl.DrawRectangle(
					i32(f64(x * tile_size) * cam.zoom),
					i32(f64(y * tile_size) * cam.zoom),
					32,
					32,
					rl.GREEN,
				)
			}
		}
	}
	return
}


main :: proc() {
	// raylib initialization
	screen_width, screen_height: f64 : 1280, 720
	rl.InitWindow(i32(screen_width), i32(screen_height), "Game")
	defer rl.CloseWindow()

	rl.SetTargetFPS(20)
	rl.SetTraceLogLevel(.WARNING)

	terrain_size := 64
	terrain: Terrain = generate_terrain(terrain_size)
	tile_size := 32
	scale := 0.25

	camera := Camera2D{{0.0, 0.0}, 1.0, screen_width, screen_height}

	for !rl.WindowShouldClose() {
		// game logic
		if rl.IsKeyPressed(.ESCAPE) {
			rl.CloseWindow()
		}

		if rl.IsKeyPressed(.D) {
			camera.pos[1] += 64
		}

		// drawing
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		draw_terrain(terrain, tile_size, camera)

		rl.DrawText("Press Escape to close", 0.0, 0.0, FONT_SIZE, rl.BLACK)

		rl.EndDrawing()
	}
}
