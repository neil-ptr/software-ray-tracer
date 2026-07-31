package worker

import image "../image"
import ray_trace "../ray_trace"
import scene "../scene"
import "core:sync"
import "core:thread"
import "core:time"

ResizeDimensions :: struct {
	width:  i32,
	height: i32,
}

SharedState :: struct {
	mu:                sync.Mutex,
	resize_dimensions: Maybe(ResizeDimensions),
	scene:             ^scene.Scene,
	front:             ^image.FrameBuffer,
	back:              ^image.FrameBuffer,
	stop:              bool,
}

renderer :: proc(t: ^thread.Thread) {
	shared_state := (cast(^SharedState)t.data)

	for !shared_state.stop {
		resize_dimensions, has_resize := shared_state.resize_dimensions.?
		if has_resize {
			sync.mutex_lock(&shared_state.mu)
			width, height := resize_dimensions.width, resize_dimensions.height
			sync.mutex_unlock(&shared_state.mu)

			shared_state.front.width = width
			shared_state.front.height = height
			delete(shared_state.front.pixels)
			shared_state.front.pixels = make([dynamic]u32, width * height)

			shared_state.back.width = width
			shared_state.back.height = height
			delete(shared_state.back.pixels)
			shared_state.back.pixels = make([dynamic]u32, width * height)

			shared_state.scene.camera.width = width
			shared_state.scene.camera.height = height

			shared_state.resize_dimensions = nil
		}

		start := time.tick_now()
		ray_trace.render_frame(shared_state.scene, shared_state.back)
		duration := time.tick_since(start)

		{
			sync.mutex_lock(&shared_state.mu)
			defer sync.mutex_unlock(&shared_state.mu)

			// swap pointers
			temp := shared_state.front
			shared_state.front = shared_state.back
			shared_state.back = temp
		}
	}
}
