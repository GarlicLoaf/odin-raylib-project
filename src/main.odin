package main

import "core:fmt"
import "core:math"
import "core:math/noise"
import rl "vendor:raylib"

FONT_SIZE: i32 : 20

Terrain :: struct {
	tiles:         [][]f32,
	width, height: int,
	tile_size:     int,
}

Camera2D :: struct {
	pos:           rl.Vector2,
	zoom:          f32,
	width, height: f32,
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

	terrain := Terrain{tiles, size, size, 64}
	return terrain
}

draw_terrain :: proc(terrain: Terrain, tile_size: int, cam: Camera2D) {
	tiles_w := int(math.ceil(cam.width / (f32(tile_size) * cam.zoom))) + 1
	tiles_h := int(math.ceil(cam.height / (f32(tile_size) * cam.zoom))) + 1

	left := math.max(int(cam.pos.x) / int(tile_size), 0)
	top := math.max(int(cam.pos.y) / int(tile_size), 0)

	right := math.min(left + tiles_w, terrain.width)
	bottom := math.min(top + tiles_h, terrain.height)

	tile_draw_size := i32(math.ceil(f32(terrain.tile_size) * cam.zoom))

	for x in left ..< right {
		for y in top ..< bottom {
			wx := x * tile_size
			wy := y * tile_size

			sx := i32((f32(wx) - cam.pos.x) * cam.zoom)
			sy := i32((f32(wy) - cam.pos.y) * cam.zoom)

			col := rl.GREEN
			if terrain.tiles[x][y] > 0.75 {col = rl.BLUE}

			rl.DrawRectangle(sx, sy, tile_draw_size, tile_draw_size, col)
		}
	}
	return
}


main :: proc() {
	// raylib initialization
	screen_width, screen_height: f32 : 1280, 720
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
		} else if rl.IsKeyPressed(.I) {
			camera.zoom += 0.2
		} else if rl.IsKeyPressed(.K) {
			camera.zoom -= 0.2
		}

		// drawing
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		draw_terrain(terrain, tile_size, camera)

		rl.DrawText("Press Escape to close", 0.0, 0.0, FONT_SIZE, rl.BLACK)

		rl.EndDrawing()
	}
}
