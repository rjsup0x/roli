package main

import rl"vendor:raylib"

draw_player_hearts :: proc(player: ^Player, heart: rl.Texture2D) {

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