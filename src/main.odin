package main

import "core:fmt"
import "core:mem"
import "core:os"
import rl "vendor:raylib"

main :: proc() {
	// set path to be consistent
	//os.set_working_directory("..")

	// create a tracking allocator
	// track all memory allocations and deallocations
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, context.allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)

	//
	reset_tracking_alloc :: proc(alloc: ^mem.Tracking_Allocator) -> bool {
		leaks := false
		for key, value in alloc.allocation_map {
			fmt.printf("%v: leaked %v bytes\n", value.location, value.size)
			leaks = true
		}

		mem.tracking_allocator_clear(alloc)
		return leaks
	}

	// raylib init
	SCREEN_WIDTH :: 800.0
	SCREEN_HEIGHT :: 600.0
	TITLE :: "ROLI"

	// window size and title
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, TITLE)
	defer rl.CloseWindow()

    // window and taskbar icon
    icon: rl.Image = rl.LoadImage("Z:/code/ghsh/assets/textures/icon_heart.png")
    rl.SetWindowIcon(icon)
    defer rl.UnloadImage(icon)

    rl.SetExitKey(.KP_ADD)

	rl.SetTargetFPS(60)

	// start a game instance
	game := init_game()

	// on close
	defer {
		// get rid of game instance (safely remove memory)
		deinit_game(&game)

		// check the tracking allocator for leaks - if true - leaks exist and have been printed
		if reset_tracking_alloc(&tracking_allocator) {
			fmt.println("MEMORY INFO: Memory leaks detected!")
		} else {
			fmt.println("MEMORY INFO: No memory leaks detected!")
		}
	}

	// game loop
	for !rl.WindowShouldClose() {
		delta_time := rl.GetFrameTime()

		// update world
		update_game(&game, delta_time)

		rl.BeginDrawing()

		rl.ClearBackground({160, 200, 255, 255})

		// draw world
		draw_game(&game)

		rl.EndDrawing()
	}
}
