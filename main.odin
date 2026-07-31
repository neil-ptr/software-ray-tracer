package main

import "core:fmt"
import "core:sync"
import "core:thread"
import geometry "src/geometry"
import image "src/image"
import ray_trace "src/ray_trace"
import scn "src/scene"
import vmath "src/vmath"
import worker "src/worker"
import sdl "vendor:sdl3"

main :: proc() {
	width: i32 = 512
	height: i32 = 512

	window := sdl.CreateWindow("ray tracer", width, height, sdl.WindowFlags{.RESIZABLE})
	defer sdl.DestroyWindow(window)

	surface_pixels := make([dynamic]u32, width * height)
	surface := sdl.CreateSurfaceFrom(width, height, .RGBA32, raw_data(surface_pixels), width * 4)
	defer sdl.DestroySurface(surface)

	renderer := sdl.CreateSoftwareRenderer(surface)
	defer sdl.DestroyRenderer(renderer)

	triangles, err := scn.load_obj("./objs/cornell.obj")
	defer delete(triangles)
	if err != .None {
		fmt.println("parse error:", err)
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
			direction = vmath.Vec3{0, 0, -1},
			width = width,
			height = height,
			canvas = scn.Plane {
				vmath.Vec3{normalized_width, 0, 0},
				vmath.Vec3{0, normalized_height, 0},
			},
		},
	}

	front_buffer := new_clone(
		image.FrameBuffer {
			width = width,
			height = height,
			pixels = make([dynamic]u32, width * height),
		},
	)
	back_buffer := new_clone(
		image.FrameBuffer {
			width = width,
			height = height,
			pixels = make([dynamic]u32, width * height),
		},
	)

	shared_state := new_clone(
		worker.SharedState {
			resize_dimensions = worker.ResizeDimensions{width, height},
			scene = &scene,
			front = front_buffer,
			back = back_buffer,
			stop = false,
		},
	)

	render_thread := thread.create(worker.renderer)
	render_thread.init_context = context
	render_thread.data = shared_state
	thread.start(render_thread)
	defer thread.join(render_thread)
	defer thread.destroy(render_thread)

	done := false
	for !done {
		event := sdl.Event{}

		for sdl.PollEvent(&event) {
			#partial switch event.type {
			case .QUIT:
				shared_state.stop = true
				done = true
			case .WINDOW_RESIZED:
				width = event.window.data1
				height = event.window.data2

				sync.mutex_lock(&shared_state.mu)
				shared_state.resize_dimensions = worker.ResizeDimensions{width, height}
				sync.mutex_unlock(&shared_state.mu)

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
			}
		}

		{
			sync.mutex_lock(&shared_state.mu)
			defer sync.mutex_unlock(&shared_state.mu)

			if shared_state.front.width != width || shared_state.front.height != height {
				// skip until worker is synced with main thread window dimensions
				continue
			}

			for i in 0 ..< int(width * height) {
				// macos is little endian, swap to big endian
				// macos: 0xAABBGGRR -> 0xRRGGBBAA
				be_rgba := sdl.Swap32BE(shared_state.front.pixels[i])
				surface_pixels[i] = be_rgba
			}
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
