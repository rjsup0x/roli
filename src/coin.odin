package main

import rl"vendor:raylib"

// coin has a posiion and whether its collectd
Coin_Drop :: struct {
    using entity: Entity,
    
    collected: bool,
}

init_coin :: proc(position: rl.Vector2) -> Coin_Drop 
{
    return Coin_Drop{
        entity = Entity{
            position = position,
            velocity = { 0, 0 },

            bounds = rl.Rectangle{
                width = 32,
                height = 32,
            },

            jumps_remaining = 0,
            grounded = false,
            facing_right = true,

            animation_state = .Idle_Right,
            animation = Animation{
                row = 0,
                frame = 0,
                frame_count = 9,
                frame_time = 0.12,
            },
        },
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
