package main

import rl "vendor:raylib"
import "core:fmt"

Assets :: struct {
    player_texture: rl.Texture2D,
    enemy_texture: rl.Texture2D,
    // terrain: rl.Texture2D,
    // enemy etc
}

load_assets :: proc() -> Assets 
{
    return Assets{
        player_texture = rl.LoadTexture("Z:/code/ghsh/assets/textures/Player.png"),
        enemy_texture = rl.LoadTexture("Z:/code/ghsh/assets/textures/Player.png"),
        // terrain = rl.LoadTexture("assets/textures/Terrain.png"),
        // load other asset textures
    }
}

unload_assets :: proc(assets: ^Assets) 
{
    // unload after use
    rl.UnloadTexture(assets.player_texture)
    rl.UnloadTexture(assets.enemy_texture)
}