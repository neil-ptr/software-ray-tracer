package scene

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Triangle :: struct {
	v0, v1, v2: f32,
}

Scene :: struct {
	camera:    Camera,
	triangles: [dynamic]Triangle,
}

load_obj :: proc(filepath: string) -> (triangle_arr: [dynamic]Triangle, ok: bool) {
	data, err := os.read_entire_file(filepath, context.allocator)
	defer delete(data, context.allocator)

	triangles := make([dynamic]Triangle)

	if err != nil {
		return triangles, false
	}

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if len(line) == 0 {continue}
		if line[0] == '#' {continue}

		line_components := strings.split(line, " ")
		keyword: ObjFileKeyword = keyword_from_token(line_components[0])
		component1 := line_components[1]
		component2 := line_components[2]
		component3 := line_components[3]

		switch keyword {
		case .Vertex:
			v0, v0_ok := strconv.parse_f32(component1)
			if !v0_ok {return triangles, false}

			v1, v1_ok := strconv.parse_f32(component2)
			if !v1_ok {return triangles, false}

			v2, v2_ok := strconv.parse_f32(component3)
			if !v2_ok {return triangles, false}

			append(&triangles, Triangle{v0, v1, v2})

		case .Normal:
			fmt.printfln("normal")
		case .Face:
			fmt.printfln("face")
		case .Invalid:
		}
	}

	return triangles, true
}
