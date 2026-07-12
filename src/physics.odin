package main

import rl "vendor:raylib"

// gravity + vertical movement only
apply_physics :: proc(object: ^$T, delta_time: f32)
{
    gravity: f32 = 1500

    object.velocity.y += gravity * delta_time

    object.position.y += object.velocity.y * delta_time
}

// reset when standing on ground
land_object :: proc(object: ^$T)
{
    object.velocity.y = 0
    object.grounded = true
    object.jumps_remaining = 2
}


// vertical collision check
check_ground :: proc(object: ^$T, tile_map: ^Tile_Map)
{
    object_rect := rl.Rectangle{
        object.position.x,
        object.position.y,
        object.bounds.width,
        object.bounds.height,
    }

    object.grounded = false

    for collision in tile_map.collisions {

        if rl.CheckCollisionRecs(object_rect, collision) {
            // falling onto floor
            if object.velocity.y > 0 {

                object.position.y = collision.y - object.bounds.height

                land_object(object)
            }

            // jumping into ceiling
            if object.velocity.y < 0 {

                object.position.y = collision.y + collision.height

                object.velocity.y = 0
            }

            break
        }
    }
}
