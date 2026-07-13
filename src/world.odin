package main

import "core:fmt"

import rl "vendor:raylib"

World :: struct {
	tile_map: Tile_Map,
	// player
	player:   Player,
	//
	camera:   Camera_Controller,
	//
	enemies:  [dynamic]Enemy,
	// objects
	coins: [dynamic]Coin_Drop,
	health_drops: [dynamic]Health_Drop,
	// levels
	level: int,
	changing_level: bool,
}

// init the world data
init_world :: proc(assets: ^Assets) -> World 
{	
    world := World {
        enemies = make([dynamic]Enemy, 0, 64),
        level = 1,
		coins = make([dynamic]Coin_Drop, 0, 128),
		health_drops = make([dynamic]Health_Drop, 0, 64),
    }

    tile_map, ok := load_map("assets/maps/Level1.tmj")

    if !ok {
        panic("Couldn't load map")
    }

    world.tile_map = tile_map

    world.player = init_player(assets.player_texture)

    world.player.position = world.tile_map.player_spawn

    load_world_objects(&world, assets)

    world.camera = init_camera(&world.player)

    return world
}

// remove any data or allocations to data in the world
deinit_world :: proc(world: ^World) 
{
	// unload the tilemap
	unload_map(&world.tile_map)

	// delete the array of enemies
	delete(world.enemies)
	delete(world.coins)
	delete(world.health_drops)

	// deinit the world to nothing
	world^ = {}
}

// update every enemy's movement/physics/animation
update_enemies :: proc(world: ^World, delta_time: f32)
{
	for i in 0 ..< len(world.enemies) {
		update_enemy(&world.enemies[i], delta_time, &world.tile_map)
	}
}

// update things that happen in the world like (player, enemies)
update_world :: proc(world: ^World, input: ^Input, delta_time: f32, assets: ^Assets) 
{
	// update the players pos in world - howand when input has been done and tilemappos
	update_player(&world.player, input, delta_time, &world.tile_map)

	// for all enemies in the enemy array, update each one
	update_enemies(world, delta_time)

	// if player and an enemy collide - handle that
	if check_player_enemy_collisions(world, &world.player, &world.enemies) {
		// Handle collision
		fmt.println("player and enemy colided")
	}

	// coins + health drops: update them, then collect any the player is touching
	update_pickups(world, delta_time)

	// update camera in world pos, player to track, delta time, and the
	// current level's tilemap (so it clamps to the real level width)
	update_camera(&world.camera, &world.player, delta_time, &world.tile_map)

	// check if it needs to change the level or nah
	if check_exit(world) && !world.changing_level {
		world.changing_level = true

		load_next_level(world, assets)

		world.changing_level = false

    	// load_next_level(world)
		fmt.println("Going to next level")
	}
}

// draw all assets and things happening in the world
draw_world :: proc(world: ^World, assets: ^Assets) 
{
	rl.BeginMode2D(world.camera.camera)

	// debug checks
	if rl.IsKeyDown(.F) {
		// shwo player and enemy bounds
		rl.DrawRectangleLinesEx(world.player.bounds, 1, rl.GREEN)

		for enemy in world.enemies {
			rl.DrawRectangleLinesEx(enemy.bounds, 1, rl.RED)
		}

		// draw debug camera
		draw_camera_debug(&world.camera)
	}

	// draw the tilemap level
	draw_map(&world.tile_map)


	// draw player into the world
	draw_player(&world.player)

	// draw each enemy in the enemy array
	for &enemy in world.enemies {
		if enemy.is_alive {
			draw_enemy(&enemy)
		}
	}

	// draw coins into the world
	for &coin in world.coins {

		if coin.collected {
			continue
		}

		draw_coin(&coin, assets.coin_texture)
	}

	// draw health drops into the worl
	for &drop in world.health_drops {
		if drop.collected {
			continue
		}

		draw_health_drop(&drop, assets.heart_texture)
	}

	rl.EndMode2D()

	// hud space

	// hud space - outside cam
	draw_player_hearts(&world.player, assets.heart_texture)

	// put coins on screen too - when enemy dies - enemy picks em up
	draw_player_coins(&world.player, assets.coin_texture)
}
