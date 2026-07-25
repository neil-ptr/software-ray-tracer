package scene

import geometry "../geometry/"
import vmath "../vmath"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Scene :: struct {
	camera:    Camera,
	triangles: [dynamic]geometry.Triangle,
}

load_obj :: proc(filepath: string) -> (triangle_arr: [dynamic]geometry.Triangle, ok: bool) {
	data, err := os.read_entire_file(filepath, context.allocator)
	defer delete(data, context.allocator)

	triangles := make([dynamic]geometry.Triangle)

	if err != nil {
		return triangles, false
	}

	vecs := make([dynamic]vmath.Vec3)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if len(line) == 0 {continue}
		if line[0] == '#' {continue}

		line_components := strings.split(line, " ")
		keyword: geometry.ObjFileKeyword = geometry.keyword_from_token(line_components[0])
		component1 := line_components[1]
		component2 := line_components[2]
		component3 := line_components[3]

		switch keyword {
		case .Vertex:
			x, x_ok := strconv.parse_f32(component1)
			if !x_ok {return triangles, false}

			y, y_ok := strconv.parse_f32(component2)
			if !y_ok {return triangles, false}

			z, z_ok := strconv.parse_f32(component3)
			if !z_ok {return triangles, false}

			append(&vecs, vmath.Vec3{x, y, z})

		case .Normal:
			fmt.printfln("normal")
		case .Face:
			v0_key, v0_key_ok := strconv.parse_int(component1)
			if !v0_key_ok || v0_key < 1 || v0_key > len(vecs) {return triangles, false}

			v1_key, v1_key_ok := strconv.parse_int(component2)
			if !v1_key_ok || v1_key < 1 || v1_key > len(vecs) {return triangles, false}

			v2_key, v2_key_ok := strconv.parse_int(component3)
			if !v2_key_ok || v2_key < 1 || v2_key > len(vecs) {return triangles, false}

			v0 := vecs[v0_key - 1]
			v1 := vecs[v1_key - 1]
			v2 := vecs[v2_key - 1]

			append(&triangles, geometry.Triangle{v0, v1, v2})
		case .Invalid:
		}
	}

	return triangles, true
}
