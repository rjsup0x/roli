package main

import rl"vendor:raylib"

// coin has a posiion and whether its collectd
Coin_Drop :: struct {
    position: rl.Vector2,
    collected: bool,
    animation: Animation,
    animation_state: Animation_State,
    grounded: bool,
    velocity: rl.Vector2,
    facing_right: bool,
    jumps_remaining: int,
}

init_coin :: proc(position: rl.Vector2) -> Coin_Drop 
{
    return Coin_Drop{
        animation_state = .Idle_Right,
        animation = Animation{
            row = 0,
            frame = 0,
            frame_count = 9,
            frame_time = 0.12,
        },
        jumps_remaining = 0,
        position = position,
        grounded = false,
        velocity = { 0, 0 },
        facing_right = true,
    }
}

update_coin :: proc(coin: ^Coin_Drop, delta_time: f32, tile_map: ^Tile_Map)
{
    apply_physics(coin, delta_time)
    check_ground(coin, tile_map)
    update_coin_animation(coin, delta_time)

}

draw_coin :: proc(coin: ^Coin_Drop, texture: rl.Texture2D)
{
    frame_width := texture.width / coin.animation.frame_count

    source := rl.Rectangle{
        f32(coin.animation.frame * frame_width),
        0,
        f32(frame_width),
        f32(texture.height),
    }

    rl.DrawTextureRec(
        texture,
        source,
        coin.position,
        rl.WHITE,
    )
}