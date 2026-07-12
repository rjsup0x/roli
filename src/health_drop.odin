package main

import rl"vendor:raylib"

// has position and whether it was collected
Health_Drop :: struct {
    position: rl.Vector2,
    collected: bool,
}

init_health_drop :: proc( position: rl.Vector2) -> Health_Drop
{
    return Health_Drop{
        position = position,
    }
}

draw_health_drop :: proc(health_drop: ^Health_Drop, texture: rl.Texture2D)
{
    rl.DrawTexture(
		texture,
		i32(health_drop.position.x),
		i32(health_drop.position.y),
		rl.WHITE,
	)
}