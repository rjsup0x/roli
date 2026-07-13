package main

import "core:fmt"
import rl "vendor:raylib"

Assets :: struct {
	player_texture: rl.Texture2D,
	enemy_texture:  rl.Texture2D,
	heart_texture: rl.Texture2D,
	coin_texture: rl.Texture2D,
	background_layer1: rl.Texture2D,
	background_layer2: rl.Texture2D,
	// terrain: rl.Texture2D,
	// enemy etc
}

load_assets :: proc() -> Assets 
{
	return Assets {
		player_texture = rl.LoadTexture("assets/textures/level1/Player.png"),
		enemy_texture  = rl.LoadTexture("assets/textures/level1/Player.png"),
		heart_texture = rl.LoadTexture("assets/textures/common/icon_heart.png"),
		coin_texture = rl.LoadTexture("assets/textures/common/Coin.png"),
		background_layer1 = rl.LoadTexture("assets/textures/common/Background1.png"),
		background_layer2 = rl.LoadTexture("assets/textures/common/Background2.png"),
		// load other asset textures
	}
}

unload_assets :: proc(assets: ^Assets) 
{
	// unload after use
	rl.UnloadTexture(assets.player_texture)
	rl.UnloadTexture(assets.enemy_texture)
	rl.UnloadTexture(assets.heart_texture)
	rl.UnloadTexture(assets.coin_texture)
	rl.UnloadTexture(assets.background_layer1)
	rl.UnloadTexture(assets.background_layer2)
}
