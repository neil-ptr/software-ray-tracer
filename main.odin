package main

import "core:fmt"
import scene "src/scene"
import sdl "vendor:sdl3"

main :: proc() {
	width: i32 = 400
	height: i32 = 400

	window := sdl.CreateWindow("ray tracer", width, height, sdl.WindowFlags{.RESIZABLE})
	defer sdl.DestroyWindow(window)

	surface := sdl.CreateSurface(width, height, .RGBA32)
	defer sdl.DestroySurface(surface)

	renderer := sdl.CreateSoftwareRenderer(surface)
	defer sdl.DestroyRenderer(renderer)

	triangles, ok := scene.load_obj("./objs/square.obj")
	if !ok {
		panic("error loading obj file")
	}

	done := false
	for !done {
		event := sdl.Event{}

		for sdl.PollEvent(&event) {
			#partial switch event.type {
			case .QUIT:
				done = true
			case .WINDOW_RESIZED:
				width = event.window.data1
				height = event.window.data2
				sdl.DestroySurface(surface)
				surface = sdl.CreateSurface(width, height, .RGBA32)
			}
		}

		rect := sdl.Rect {
			x = 0,
			y = 0,
			w = width,
			h = height,
		}

		sdl.BlitSurface(surface, &rect, sdl.GetWindowSurface(window), &rect)

		i: i32 = 0
		for i < width * height {
			pixels := cast([^]u32)surface.pixels
			pixels[i] = 0xff0000ff
			i += 1
		}

		sdl.UpdateWindowSurface(window)

	}

	sdl.Quit()
}
