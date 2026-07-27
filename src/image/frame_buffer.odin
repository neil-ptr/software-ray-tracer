package image

FrameBuffer :: struct {
	width:  i32,
	height: i32,
	pixels: [dynamic]u32,
}

clear_buffer :: proc(frame_buffer: ^FrameBuffer) {
	CLEARED_PIXEL: u32 = 0x000000FF
	for i in 0 ..< int(frame_buffer.width * frame_buffer.height) {
		frame_buffer.pixels[i] = CLEARED_PIXEL
	}
}
