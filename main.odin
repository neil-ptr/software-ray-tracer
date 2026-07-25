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

	render_pixels := make([dynamic]u32, width * height)
	frame_buffer := image.FrameBuffer{width, height, render_pixels}

	surface_pixels := make([dynamic]u32, width * height)
	surface := sdl.CreateSurfaceFrom(width, height, .RGBA32, raw_data(surface_pixels), width * 4)
	defer sdl.DestroySurface(surface)

	renderer := sdl.CreateSoftwareRenderer(surface)
	defer sdl.DestroyRenderer(renderer)

	triangles, ok := scn.load_obj("./objs/square.obj")
	defer delete(triangles)
	if !ok {
		panic("error loading obj file")
	}

	normalized_width := f32(width) / f32(height)
	normalized_height := f32(1.0)
	if width > height {
		normalized_width = f32(1.0)
		normalized_height = f32(height) / f32(width)
	}

	scene := scn.Scene {
		triangles = triangles,
		camera = scn.Camera {
			position = vmath.Vec3{0, 0, 0},
			direction = vmath.Vec3{0, 0, 1},
			width = width,
			height = height,
			canvas = scn.Plane {
				vmath.Vec3{normalized_width, 0, 0},
				vmath.Vec3{0, normalized_height, 0},
			},
		},
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

				delete(render_pixels)
				render_pixels = make([dynamic]u32, width * height)
				frame_buffer.width = width
				frame_buffer.height = height
				frame_buffer.pixels = render_pixels

				delete(surface_pixels)
				surface_pixels = make([dynamic]u32, width * height)
				sdl.DestroySurface(surface)
				surface = sdl.CreateSurfaceFrom(
					width,
					height,
					.RGBA32,
					raw_data(surface_pixels),
					width * 4,
				)

				normalized_width := f32(width) / f32(height)
				normalized_height := f32(1.0)
				if width > height {
					normalized_width = f32(1.0)
					normalized_height = f32(height) / f32(width)
				}

				scene.camera = scn.Camera {
					position  = vmath.Vec3{0, 0, 0},
					direction = vmath.Vec3{0, 0, -1},
					width     = width,
					height    = height,
					canvas    = scn.Plane {
						vmath.Vec3{normalized_width, 0, 0},
						vmath.Vec3{0, normalized_height, 0},
					},
				}
			}
		}

		ray_trace.render_frame(&scene, &frame_buffer)

		for i in 0 ..< int(width * height) {
			surface_pixels[i] = frame_buffer.pixels[i]
		}

		rect := sdl.Rect {
			x = 0,
			y = 0,
			w = width,
			h = height,
		}
		sdl.BlitSurface(surface, &rect, sdl.GetWindowSurface(window), &rect)

		sdl.UpdateWindowSurface(window)

	}

	sdl.Quit()
}
