package ray_trace

import geometry "../geometry"
import image "../image"
import scn "../scene"
import vmath "../vmath"
import "core:fmt"
import "core:math/linalg"

@(private)
INFINITY :: max(f32)

@(private)
EPSILON: f32 : 0.000001

render_frame :: proc(scene: ^scn.Scene, frame_buffer: ^image.FrameBuffer) {
	width := frame_buffer.width
	height := frame_buffer.height

	assert(width > 0, "width is non-positive")
	assert(height > 0, "height is non-positive")

	for px_idx in 0 ..< width * height {
		frame_buffer.pixels[px_idx] = 0xff0000ff

		pixel_row_idx := px_idx % width
		pixel_col_idx := px_idx / height

		pixel_ndc_x := f32(pixel_row_idx) / f32(scene.camera.width)
		pixel_ndc_y := f32(pixel_col_idx) / f32(scene.camera.height)

		// transform pixel coords within camera plane to [-1, 1] range
		x_px_coord := (2 * (pixel_ndc_x)) - 1 // range [left, right] -> [-1, 1]
		// 1 - (...) to make the top of the frame be 1 and bottom be -1
		y_px_coord := 1 - (2 * (pixel_ndc_y)) // range [top, bottom] -> [1, -1]

		primary_ray_vec :=
			scene.camera.direction +
			(x_px_coord * f32(scene.camera.width)) +
			(y_px_coord * f32(scene.camera.height))

		norm_primary_ray_vec := linalg.normalize(primary_ray_vec)

		for triangle in scene.triangles {
			distance := compute_distance(norm_primary_ray_vec, triangle)
			fmt.println("%d", distance)
		}
	}
}

does_intersect :: proc(ray: vmath.Vec3, triangle: geometry.Triangle) -> bool {
	return false
}

compute_distance :: proc(ray: vmath.Vec3, triangle: geometry.Triangle) -> f32 {
	return 0.0
}
