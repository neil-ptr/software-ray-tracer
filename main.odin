package main

import image "src/image"
import ray_trace "src/ray_trace"
import scn "src/scene"
import vmath "src/vmath"
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

	triangles, ok := scn.load_obj("./objs/square.obj")
	if !ok {
		panic("error loading obj file")
	}

	scene := scn.Scene{}
	scene.camera = scn.Camera{vmath.Vec3{0, 0, 0}, vmath.Vec3{0, 0, 1}, width, height}

	pixels := make([dynamic]u32, width * height)
	frame_buffer := image.FrameBuffer{width, height, pixels}

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

		ray_trace.render_frame(&scene, &frame_buffer)

		dst := make([dynamic]u32, width * height)
		for i in 0 ..< int(width * height) {
			dst[i] = frame_buffer.pixels[i]
		}

		surface.pixels = raw_data(dst)

		sdl.BlitSurface(surface, &rect, sdl.GetWindowSurface(window), &rect)

		sdl.UpdateWindowSurface(window)

	}

	sdl.Quit()
}
