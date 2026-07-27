package ray_trace

import geometry "../geometry"
import image "../image"
import scn "../scene"
import vmath "../vmath"
import "core:math/linalg"


@(private)
INFINITY :: max(f32)

@(private)
EPSILON: f32 : 0.000001

@(private)
Intersect :: vmath.Vec3


@(private)
CLEARED_PIXEL: u32 = 0x000000FF

render_frame :: proc(scene: ^scn.Scene, frame_buffer: ^image.FrameBuffer) {
	width := frame_buffer.width
	height := frame_buffer.height

	assert(width > 0, "width is non-positive")
	assert(height > 0, "height is non-positive")

	image.clear_buffer(frame_buffer)

	for px_idx in 0 ..< width * height {
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
			(x_px_coord * scene.camera.canvas.horizontal) +
			(y_px_coord * scene.camera.canvas.vertical)

		norm_primary_ray_vec := linalg.normalize(primary_ray_vec)

		nearest_triangle_hit_point_vec := vmath.Vec3{INFINITY, 0, 0}
		nearest_triangle: ^geometry.Triangle = nil

		for &triangle in scene.triangles {
			intersection_vec, hit := intersect(
				scene.camera.position,
				norm_primary_ray_vec,
				triangle,
			)

			if hit && intersection_vec[0] < nearest_triangle_hit_point_vec[0] {
				nearest_triangle_hit_point_vec = intersection_vec
				nearest_triangle = &triangle
			}
		}

		if nearest_triangle != nil {
			r := u32(nearest_triangle_hit_point_vec[1] * 255)
			g := u32(nearest_triangle_hit_point_vec[2] * 255)
			b := u32(
				(1 - nearest_triangle_hit_point_vec[1] - nearest_triangle_hit_point_vec[2]) * 255,
			)

			frame_buffer.pixels[px_idx] = (r << 24) | (g << 16) | (b << 8) | 0xff
		}
	}
}

// moller trumbore
// https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-rendering-a-triangle/moller-trumbore-ray-triangle-intersection.html
intersect :: proc(
	position_vec: vmath.Vec3,
	ray_vec: vmath.Vec3,
	triangle: geometry.Triangle,
) -> (
	intersection_vec: vmath.Vec3,
	Hit: bool,
) {
	v0v1_vec := triangle.v1 - triangle.v0
	v0v2_vec := triangle.v2 - triangle.v0
	norm_triangle_vec := linalg.normalize(linalg.cross(v0v1_vec, v0v2_vec))

	ray_triangle_dot_product := linalg.dot(ray_vec, norm_triangle_vec)
	if ray_triangle_dot_product >= 0.0 || abs(ray_triangle_dot_product) < EPSILON {
		return vmath.Vec3{}, false
	}

	T := position_vec - triangle.v0
	P := linalg.cross(ray_vec, v0v2_vec)
	Q := linalg.cross(T, v0v1_vec)

	inv_M_determinant := 1 / linalg.dot(P, v0v1_vec)

	u := inv_M_determinant * linalg.dot(P, T)
	if u < 0.0 || u > 1.0 {
		return vmath.Vec3{}, false
	}

	v := inv_M_determinant * linalg.dot(Q, ray_vec)
	if v < 0.0 || v > 1.0 {
		return vmath.Vec3{}, false
	}


	if u + v > 1 {
		return vmath.Vec3{}, false
	}

	t := inv_M_determinant * linalg.dot(Q, v0v2_vec)
	if t <= 0.0 || abs(t) < EPSILON {
		return vmath.Vec3{}, false
	}

	return vmath.Vec3{t, u, v}, true
}
