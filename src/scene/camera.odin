package scene

import vmath "../vmath"

Camera :: struct {
	position:  vmath.Vec3,
	direction: vmath.Vec3,
	width:     i32,
	height:    i32,
}
