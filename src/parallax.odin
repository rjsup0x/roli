package main

import rl"vendor:raylib"

Parallax :: struct {
    layer1_x: f32,
    layer2_x: f32,

    layer1_speed: f32,
    layer2_speed: f32,
}

draw_parallax :: proc(game: ^Game) {
    // get the layers for the full background
    bg1 := game.assets.background_layer1
    bg2 := game.assets.background_layer2

    // background follows cam pos
    camera_x := game.world.camera.camera.target.x

    // cam moves on movement
    x1 := -(camera_x * 0.2)
    x2 := -(camera_x * 0.5)

    // get screen size
    screen_w := f32(rl.GetScreenWidth())
    screen_h := f32(rl.GetScreenHeight())

    // 
    src1 := rl.Rectangle{0, 0, f32(bg1.width), f32(bg1.height)}
    src2 := rl.Rectangle{0, 0, f32(bg2.width), f32(bg2.height)}

    // draw bg one details
    dest := rl.Rectangle{x1, 0, screen_w, screen_h}
    rl.DrawTexturePro(bg1, src1, dest, {}, 0, rl.WHITE)
    dest.x += screen_w
    rl.DrawTexturePro(bg1, src1, dest, {}, 0, rl.WHITE)

    // draw bg two details
    dest = rl.Rectangle{x2, 0, screen_w, screen_h}
    rl.DrawTexturePro(bg2, src2, dest, {}, 0, rl.WHITE)
    dest.x += screen_w
    rl.DrawTexturePro(bg2, src2, dest, {}, 0, rl.WHITE)
}