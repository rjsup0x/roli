package main

import "core:fmt"
import "core:math/rand"

import rl "vendor:raylib"

World :: struct {
	tile_map: Tile_Map,
	// entities
	player:   Player,
	enemies:  [dynamic]Enemy,
	// objects
	coins: [dynamic]Coin_Drop,
	health_drops: [dynamic]Health_Drop,
	//
	camera:   Camera_Controller,
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

// helper to create enemies and add them to an array of enemies
spawn_enemy :: proc(world: ^World, texture: rl.Texture2D, position: rl.Vector2) 
{
	// init an enemy with texture and position
	enemy := init_enemy(texture, position)
	enemy.start_position = enemy.position

	// apopend to the enemies array
	append(&world.enemies, enemy)
}

// when enemy dies random chance for spawn coin into world
spawn_coin :: proc(world: ^World, position: rl.Vector2) 
{
	coin := init_coin(position)
	coin.position = position

	coin.velocity = {
    	0,
   	 	-250,
	}

	fmt.printfln("Spawned coin")
    append(&world.coins, coin)
}

// when enemy dies random chance for spawn life into world
spawn_life :: proc(world: ^World, position: rl.Vector2) 
{
	life := init_health_drop(position)
	life.position = position

	fmt.printfln("Spawned health")
    append(&world.health_drops, life)
}

// from the tilemap spawn all objects into the world
load_world_objects :: proc(world: ^World, assets: ^Assets)
{
    for layer in world.tile_map.layers {

        if layer.layer_type != "objectgroup" {
            continue
        }

        for object in layer.objects {

            position := rl.Vector2{
                object.x,
                object.y,
            }

            switch object.name {
			// TODO: add more objects to the tilemap - in tiled
            case "Enemy":
                spawn_enemy(
                    world,
                    assets.enemy_texture,
                    position,
                )

            }
        }
    }
}

// from the tilemap data draw the map using the righ ttiles etc
draw_map :: proc(tile_map: ^Tile_Map) 
{
	// no tilesets loaded
	if len(tile_map.tilesets) == 0 {
		return
	}

	// draw every layer
	for &layer in tile_map.layers {
		if layer.layer_type != "tilelayer" {
			continue
		}

		// skip invisible layers
		if !layer.visible {
			continue
		}

		for y in 0..<layer.height {
			for x in 0..<layer.width {
				index := y * layer.width + x

				gid := layer.data[index]

				// empty tile
				if gid == 0 {
					continue
				}

				// find which tileset owns this gid
				tileset := get_tileset(tile_map, gid)

				if tileset == nil {
					continue
				}

				// convert global tile id to tileset local id
				local_id :=
					get_local_tile_id(
						tileset,
						gid,
					)

				source := rl.Rectangle {
					f32((local_id % tileset.columns) * tileset.tilewidth),
					f32((local_id / tileset.columns) * tileset.tileheight),
					f32(tileset.tilewidth),
					f32(tileset.tileheight),
				}

				destination := rl.Vector2 {
					f32(x * tile_map.tilewidth),
					f32(y * tile_map.tileheight),
				}

				rl.DrawTextureRec(
					tileset.texture,
					source,
					destination,
					rl.WHITE,
				)
			}
		}
	}
}

// check for exits in  the tilemap and whether the player has collided with it
check_exit :: proc(world: ^World) -> bool
{
    for exit in world.tile_map.exits {

        if rl.CheckCollisionCircles(
            world.player.position,
            16,
            exit,
            16,
        ){
            return true
        }

    }

    return false
}

// clear assets and memory from old level and restart new with new level data
load_next_level :: proc(world: ^World, assets: ^Assets)
{
    unload_map(&world.tile_map)

    clear(&world.enemies)
	clear(&world.coins)
	clear(&world.health_drops)

    world.level += 1

    map_path: string

    switch world.level {

		// testing by loading level1 again
    case 2:
        map_path = "assets/maps/Level1.tmj"

    // case 3:
    //     map_path = "assets/maps/Level3.tmj"

    case:
        fmt.println("Game completed!")
        return
    }

    tile_map, ok := load_map(map_path)

    if !ok {
        panic("Couldn't load next level")
    }

    world.tile_map = tile_map

    world.player.position = world.tile_map.player_spawn

    load_world_objects(world, assets)
}

// update things that happen in the world like (player, enemies)
update_world :: proc(world: ^World, input: ^Input, delta_time: f32, assets: ^Assets) 
{
	// update the players pos in world - howand when input has been done and tilemappos
	update_player(&world.player, input, delta_time, &world.tile_map)

	// for all enemies in the enemy array
	for i in 0 ..< len(world.enemies) {
		// update each one
		update_enemy(&world.enemies[i], delta_time, &world.tile_map)
	}

	// if player and an enemy collide - handle that
	if check_player_enemy_collisions(world, &world.player, &world.enemies) {
		// Handle collision
		fmt.println("player and enemy colided")
	}

	// Collect coins
    for i := 0; i < len(world.coins); i += 1 {

        coin := &world.coins[i]

		update_coin(coin, delta_time, &world.tile_map)

        if coin.collected {
            continue
        }

		// if player collides with coin collect it
        if rl.CheckCollisionCircles(
            world.player.position,
            16,
            coin.position,
            8,
        ) {
            coin.collected = true
            world.player.coins += 1
        }
    }

	// collect health drops
	for i := 0; i < len(world.health_drops); i += 1 {

		drop := &world.health_drops[i]

		if drop.collected {
			continue
		}

		// player collided with health drop collect it
		if rl.CheckCollisionCircles(
			world.player.position,
			16,
			drop.position,
			8,
		) {
			// only heal if not already full
			if world.player.lives < world.player.max_lives {

				world.player.lives += 1

				drop.collected = true
			}
		}
	}

	// update camera in world pos, player to track and delta time
	update_camera(&world.camera, &world.player, delta_time)

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
