package ray_trace

import image "../image"
import scn "../scene"
import vmath "../vmath"
import "core:fmt"

@(private)
INFINITY :: max(f32)

render_frame :: proc(scene: ^scn.Scene, frame_buffer: ^image.FrameBuffer) {
	width := frame_buffer.width
	height := frame_buffer.height

	assert(width > 0, "width is non-positive")
	assert(height > 0, "height is non-positive")

	for px_idx in 0 ..< width * height {
		frame_buffer.pixels[px_idx] = 0xff0000ff

		pixel_row_idx := px_idx % width
		pixel_col_idx := px_idx / height

		// transform pixel coords within camera plane to [-1, 1] range
		x_px_coord := (2 * (f32(pixel_row_idx) / f32(scene.camera.width))) - 1
		y_px_coord := (2 * (f32(pixel_col_idx) / f32(scene.camera.height))) - 1

		primary_ray_vec :=
			scene.camera.direction +
			(x_px_coord * f32(scene.camera.width)) +
			(y_px_coord * f32(scene.camera.height))

		for triangle in scene.triangles {
			fmt.println("triangle")
		}
	}
}

intersect_ray_triangle :: proc(
	position: vmath.Vec3,
	ray_vec: vmath.Vec3,
	triangle: scn.Triangle,
) -> scn.Triangle {
	return scn.Triangle{0, 0, 0}
}
