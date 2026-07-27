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

VertexTextureNormal :: struct {
	vertex: int,
	face:   int,
	normal: int,
}

ParseError :: enum {
	None,
	UnableToReadFile,
	InvalidVertex,
	InvalidFaceComponent,
	InvalidVertexKey,
	InvalidNormalKey,
	InvalidComponent,
	InvalidVertexComponent,
}

@(private)
parse_face_component :: proc(component: string) -> (vtn: VertexTextureNormal, ok: bool) {
	parts := strings.split(component, "/")
	switch len(parts) {
	case 1:
		vertex_key, vertex_key_ok := strconv.parse_int(parts[0])
		if !vertex_key_ok {
			return VertexTextureNormal{0, 0, 0}, false
		}
		return VertexTextureNormal{vertex_key, 0, 0}, true
	case 3:
		vertex_key, vertex_key_ok := strconv.parse_int(parts[0])
		if !vertex_key_ok {
			return VertexTextureNormal{0, 0, 0}, false
		}

		texture_key, texture_key_ok := strconv.parse_int(parts[1])
		if !texture_key_ok {
			return VertexTextureNormal{0, 0, 0}, false
		}

		normal_key, normal_key_ok := strconv.parse_int(parts[2])
		if !normal_key_ok {
			return VertexTextureNormal{0, 0, 0}, false
		}

		return VertexTextureNormal{vertex_key, texture_key, normal_key}, true

	case:
		return VertexTextureNormal{0, 0, 0}, false
	}
}

load_obj :: proc(filepath: string) -> (triangle_arr: [dynamic]geometry.Triangle, err: ParseError) {
	data, read_err := os.read_entire_file(filepath, context.allocator)
	defer delete(data, context.allocator)

	triangles := make([dynamic]geometry.Triangle)

	if read_err != nil {
		return triangles, .UnableToReadFile
	}

	vecs := make([dynamic]vmath.Vec3)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if len(line) == 0 {continue}
		if line[0] == '#' {continue}

		line_components := strings.split(line, " ")
		keyword: geometry.ObjFileKeyword = geometry.keyword_from_token(line_components[0])

		switch keyword {
		case .Vertex:
			component1 := line_components[1]
			component2 := line_components[2]
			component3 := line_components[3]

			x, x_ok := strconv.parse_f32(component1)
			if !x_ok {return triangles, .InvalidVertexComponent}

			y, y_ok := strconv.parse_f32(component2)
			if !y_ok {return triangles, .InvalidVertexComponent}

			z, z_ok := strconv.parse_f32(component3)
			if !z_ok {return triangles, .InvalidVertexComponent}

			append(&vecs, vmath.Vec3{x, y, z})

		case .Normal:
			fmt.printfln("TODO: normal")
		case .MaterialLib:
			fmt.printfln("TODO: materiallib")
		case .Face:
			component1 := line_components[1]
			component2 := line_components[2]
			component3 := line_components[3]

			vtn0, vtn0_ok := parse_face_component(component1)
			if !vtn0_ok {
				return triangles, .InvalidFaceComponent
			}

			vtn1, vtn1_ok := parse_face_component(component2)
			if !vtn1_ok {
				return triangles, .InvalidFaceComponent
			}

			vtn2, vtn2_ok := parse_face_component(component3)
			if !vtn2_ok {
				return triangles, .InvalidFaceComponent
			}


			v0 := vecs[vtn0.vertex - 1]
			v1 := vecs[vtn1.vertex - 1]
			v2 := vecs[vtn2.vertex - 1]

			append(&triangles, geometry.Triangle{v0, v1, v2})
		case .Invalid:
		}
	}

	return triangles, .None
}
