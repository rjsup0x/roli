package main

import rl"vendor:raylib"

// has position and whether it was collected
Health_Drop :: struct {
    // object uses entity physics
    using entity:   Entity,
    collected:      bool,
}

init_health_drop :: proc( position: rl.Vector2) -> Health_Drop
{
    return Health_Drop{
        entity = Entity{
            position = position,
            velocity = { 0, 0 },

            bounds = rl.Rectangle{
                width = 32,
                height = 32,
            },
        }

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