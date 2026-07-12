package main

import rl"vendor:raylib"

import "core:strings"
import "core:fmt"

draw_player_hearts :: proc(player: ^Player, heart: rl.Texture2D) 
{
    heart_size: f32 = 16
    spacing: f32 = 20

    // Calculate HUD box size
    box_width := f32(player.max_lives) * spacing + 12
    box_height: f32 = 36

    // HUD background
    rl.DrawRectangle(
        10,
        10,
        i32(box_width),
        i32(box_height),
        rl.BLACK,
    )

    // HUD border
    rl.DrawRectangleLinesEx(
        rl.Rectangle{
            10,
            10,
            box_width,
            box_height,
        },
        2,
        rl.WHITE,
    )

    // Draw hearts - the amounf o hearts player has
    for i := 0; i < player.max_lives; i += 1 {

        tint := rl.GRAY

        if i < player.lives {
            tint = rl.WHITE
        }

        rl.DrawTexture(
            heart,
            i32(16 + i * 20),
            18,
            tint,
        )
    }
}

draw_player_coins :: proc(player: ^Player, coin: rl.Texture2D)
{
    COIN_FRAMES :: 9

    spacing: f32 = 20

    box_width := f32(player.coins) * spacing + 12
    if box_width < 40 {
        box_width = 40
    }

    box_height: f32 = 36

    margin: f32 = 10

    box_x := f32(rl.GetScreenWidth()) - box_width - margin
    box_y := 56.0

    // Background
    rl.DrawRectangle(
        i32(box_x),
        i32(box_y),
        i32(box_width),
        i32(box_height),
        rl.BLACK,
    )

    // Border
    rl.DrawRectangleLinesEx(
        rl.Rectangle{
            box_x,
            f32(box_y),
            box_width,
            box_height,
        },
        2,
        rl.WHITE,
    )

    frame_width := coin.width / COIN_FRAMES

    source := rl.Rectangle{
        x = 0,
        y = 0,
        width = f32(frame_width),
        height = f32(coin.height),
    }

    // Draw one coin icon per collected coin
    for i := 0; i < player.coins; i += 1 {

        rl.DrawTextureRec(
            coin,
            source,
            rl.Vector2{
                box_x + 6 + f32(i) * spacing,
                f32(box_y + 8),
            },
            rl.WHITE,
        )
    }
}