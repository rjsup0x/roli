package main

import rl "vendor:raylib"

// USING GENERICS SO BOTH PLAYER AND ENEMY CAN BE EFECTED BY THESE THINGS
apply_physics :: proc(object: ^$T, delta_time: f32) 
{
    gravity: f32 = 1500

    // gravity
    object.velocity.y += gravity * delta_time

    // move
    object.position.y += object.velocity.y * delta_time
}

// if object is of ground - stats will be different - so reset stats to same as being on the ground
land_object :: proc(object: ^$T) 
{
    // reset stats to ground level 
    // and jumps back to 2
    object.velocity.y = 0
    object.grounded = true
    object.jumps_remaining = 2
}

// check the object against the tilemap
// check if object is on collision tile
// determines if he is on the ground or nah
check_ground :: proc(object: ^$T, tile_map: ^Tile_Map) 
{
    // object rect to check overlap on ground and object
    object_rect := rl.Rectangle{
        object.position.x,
        object.position.y,
        32,
        32,
    }

    object.grounded = false

    // check the tilemap for collision tiles
    for collision in tile_map.collisions {

        // if object collides with collision tile
        if rl.CheckCollisionRecs(object_rect, collision) {
            object.position.y = collision.y - 32

            land_object(object)

            break
        }
    }
}

check_collision :: proc(player: ^Player, enemies: ^[dynamic]Enemy) -> bool 
{
    for enemy in enemies^ {
        if rl.CheckCollisionRecs(player.bounds, enemy.bounds) {
            return true
        }
    }

    return false
}