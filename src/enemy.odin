package main

import rl "vendor:raylib"

Enemy :: struct {
    start_position: rl.Vector2,
    patrol_distance: f32,
    moving_left: bool,
    velocity: rl.Vector2,
    facing_right: bool,
    animation_state: Animation_State,
    animation: Animation,
    position: rl.Vector2,
    bounds: rl.Rectangle,
    texture: rl.Texture2D,
    grounded: bool,
    jumps_remaining: i32, 
}

init_enemy :: proc(texture: rl.Texture2D, position: rl.Vector2) -> Enemy 
{
    enemy := Enemy{
        patrol_distance = 150,
        moving_left = true,

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
        position = position,
        texture = texture,
    }

    return enemy
}

update_enemy :: proc(enemy: ^Enemy, delta_time: f32, tile_map: ^Tile_Map) 
{
    update_enemy_movement(enemy, delta_time)

    enemy.bounds.x = enemy.position.x
    enemy.bounds.y = enemy.position.y

    apply_physics(enemy, delta_time)

    check_ground(enemy, tile_map)

    update_animation(enemy, delta_time)
}

// enemy movement ai
update_enemy_movement :: proc(enemy: ^Enemy, delta_time: f32) 
{
    speed: f32 = 100

    if enemy.moving_left {
        enemy.velocity.x = -speed
        enemy.facing_right = false

        if enemy.position.x <= enemy.start_position.x - enemy.patrol_distance {
            enemy.moving_left = false
        }
    } else {
        enemy.velocity.x = speed
        enemy.facing_right = true

        if enemy.position.x >= enemy.start_position.x {
            enemy.moving_left = true
        }
    }

    enemy.position.x += enemy.velocity.x * delta_time
}

draw_enemy :: proc(enemy: ^Enemy) 
{
    frame_width: f32 = 32
    frame_height: f32 = 32

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