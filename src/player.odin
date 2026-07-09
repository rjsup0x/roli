package main

import rl "vendor:raylib"

// things the player can be or use
Player :: struct {
    active: bool,
    position: rl.Vector2,
    velocity: rl.Vector2,
    bounds: rl.Rectangle,
    scale: f32,
    radius: f32,
    rotation: f32,
    speed: f32,
    health: i32,
    max_health: i32,
    jumps_remaining: i32,
    grounded: bool,
    facing_right: bool,
    animation_state: Animation_State,
    animation: Animation,
    texture: rl.Texture2D,
}

// init a player - into a world etc
// giving the player its stats
init_player :: proc(texture: rl.Texture2D) -> Player 
{
    player := Player{
        active = true,
        position = {200, 300},
        velocity = {0, 0},

        bounds = rl.Rectangle{
            width = 32,
            height = 32,
        },

        scale = 1.0,
        radius = 0.0,
        rotation = 0.0,
        speed = 300,

        health = 100,
        max_health = 100,

        jumps_remaining = 2,
        grounded = true,
        facing_right = true,

        animation_state = .Idle_Right,
        animation = Animation{
            row = 0,
            frame = 0,
            frame_count = 4,
            frame_time = 0.15,
        },

        texture = texture,
    }

    return player
}

// allow the player to update its stats and do things
update_player :: proc(player: ^Player, input: ^Input, delta_time: f32, tile_map: ^Tile_Map) 
{
    update_player_movement(player, input, delta_time)

    // update thje player bounds
    player.bounds.x = player.position.x
    player.bounds.y = player.position.y

    update_jump(player, input)

    apply_physics(player, delta_time)

    check_ground(player, tile_map)

    update_animation(player, delta_time)

    // update_combat(player, input)
}

// player movement subject to input device
update_player_movement :: proc(player: ^Player, input: ^Input, delta_time: f32) 
{
    // players velocity is updated by input type on the x axis * players speed
    // left right movement
    player.velocity.x = input.move_x * player.speed

    // whether the player is facing right or left
    if input.move_x > 0 {
        player.facing_right = true
    }

    if input.move_x < 0 {
        player.facing_right = false
    }

    // player pyhiscs chnage
    player.position.x += player.velocity.x * delta_time
}

// draw the player entity
draw_player :: proc(player: ^Player) 
{
    frame_width: f32 = 32
    frame_height: f32 = 32

    source := rl.Rectangle{
        x = f32(player.animation.frame) * frame_width,
        y = f32(player.animation.row) * frame_height,

        width = frame_width,
        height = frame_height,
    }

    rl.DrawTextureRec(
        player.texture,
        source,
        player.position,
        rl.WHITE,
    )
}