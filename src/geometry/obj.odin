package geometry

ObjFileKeyword :: enum {
	Vertex,
	Face,
	Normal,
	Invalid,
	MaterialLib,
}


keyword_from_token :: proc(keyword: string) -> ObjFileKeyword {
	switch keyword {
	case "v":
		return .Vertex
	case "f":
		return .Face
	case "vn":
		return .Normal
	case "mtllib":
		return .MaterialLib
	}
	return .Invalid
}
