package scene

ObjFileKeyword :: enum {
	Vertex,
	Face,
	Normal,
	Invalid,
}


keyword_from_token :: proc(keyword: string) -> ObjFileKeyword {
	switch keyword {
	case "v":
		return .Vertex
	case "f":
		return .Face
	case "vn":
		return .Normal
	}
	return .Invalid
}
