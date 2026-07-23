package ray_trace

import image "../image"
import scn "../scene"

render_frame :: proc(scene: ^scn.Scene, frame_buffer: ^image.FrameBuffer) {
	width := frame_buffer.width
	height := frame_buffer.height

	for i in 0 ..< width * height {
		frame_buffer.pixels[i] = 0xff0000ff
	}
}
