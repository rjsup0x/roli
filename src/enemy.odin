package main

import rl "vendor:raylib"

Enemy :: struct {
    // using entity physics
    using entity:       Entity,
    // store how enemy moves
    start_position:     rl.Vector2,
    previous_position:  rl.Vector2,
    // enemy tex
    texture:            rl.Texture2D,
    // hwo far enemy patrol ai can move
    patrol_distance:    f32,
    // damage enemy can give
    damage:             i32,
    // health enemy has
    health:             int,
    // store enemy lifetime
    is_alive:           bool,
    moving_left:        bool,
}

init_enemy :: proc(texture: rl.Texture2D, position: rl.Vector2) -> Enemy 
{
    enemy := Enemy{
        patrol_distance = 150,
        moving_left = true,
        previous_position = position,

        entity = Entity{
            position = position,
            velocity = { 0, 0 },

            bounds = rl.Rectangle{
                width = 32,
                height = 32,
            },
            jumps_remaining = 0,
            grounded = true,
            facing_right = true,
            animation_state = .Idle_Left,
            animation = Animation{
                row = 0,
                frame = 0,
                frame_count = 4,
                frame_time = 0.15,
            },
        },

        damage = 1,
        is_alive = true,
        texture = texture,
        health = 1,
    }

    return enemy
}

update_enemy :: proc(enemy: ^Enemy, delta_time: f32, tile_map: ^Tile_Map) 
{
    enemy.previous_position = enemy.position

    update_enemy_movement(enemy, delta_time)

    apply_physics(enemy, delta_time)

    check_ground(enemy, tile_map)

    enemy.bounds.x = enemy.position.x
    enemy.bounds.y = enemy.position.y

    update_animation(enemy, delta_time)
}

// enemy movement ai
update_enemy_movement :: proc(enemy: ^Enemy, delta_time: f32) 
{
    // speed in which enemy moves
    speed: f32 = 100

    // move left - change facing dfirection left
    if enemy.moving_left {
        enemy.velocity.x = -speed
        enemy.facing_right = false

        // when its moved left the patrol distance amount
        if enemy.position.x <= enemy.start_position.x - enemy.patrol_distance {
            enemy.moving_left = false
        }
    } else {
        // move right
        enemy.velocity.x = speed
        enemy.facing_right = true

        // moved right the patrol distance amount
        if enemy.position.x >= enemy.start_position.x {
            enemy.moving_left = true
        }
    }

    // add movement to velocity of x
    enemy.position.x += enemy.velocity.x * delta_time
}

draw_enemy :: proc(enemy: ^Enemy) 
{
    // texture sprite size
    frame_width: f32 = 32
    frame_height: f32 = 32

    // rectangle surrounding the player
    source := rl.Rectangle{
        x = f32(enemy.animation.frame) * frame_width,
        y = f32(enemy.animation.row) * frame_height,

        width = frame_width,
        height = frame_height,
    }

    rl.DrawTextureRec(
        enemy.texture,
        source,
        enemy.position,
        rl.WHITE,
    )
}
