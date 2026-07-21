package main

import scene "src/scene"
import sdl "vendor:sdl3"

main :: proc() {
	width: i32 = 400
	height: i32 = 400

	window := sdl.CreateWindow("ray tracer", width, height, sdl.WindowFlags{.RESIZABLE})
	surface := sdl.CreateSurface(width, height, .RGBA32)
	renderer := sdl.CreateSoftwareRenderer(surface)

	scene.load_obj("./objs/square.obj")

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
				sdl.free(surface)
			}
		}

		if surface == nil {
			surface = sdl.CreateSurface(width, height, .RGBA32)
			// sdl.SetSurfaceBlendMode(surface, sdl.BlendMode)
		}
	}

	sdl.Quit()
}
