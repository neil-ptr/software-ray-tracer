package main

import "core:fmt"
import sdl "vendor:sdl3"


main :: proc() {
	fmt.println("hello world")

	width: i32 = 400
	height: i32 = 400

	window := sdl.CreateWindow("rasterizer", width, height, sdl.WindowFlags{})

	done := false
	for !done {
		event := sdl.Event{}

		for sdl.PollEvent(&event) {
			if event.type == sdl.EventType.QUIT {
				done = true
			}
		}
	}

	sdl.Quit()
}
