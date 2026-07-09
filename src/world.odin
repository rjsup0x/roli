package main

import "core:fmt"

import rl "vendor:raylib"

World :: struct {
    tile_map: Tile_Map,
    player: Player,
    enemies: [dynamic]Enemy,
    camera: Camera_Controller,
}

// init the world data
init_world :: proc(assets: ^Assets) -> World
{
    // init the world - with enemies array
    world := World{
        enemies = make([dynamic]Enemy,0,64),
    }

    // load the level tilemap
    tile_map, ok := load_map("Z:/code/ghsh/assets/map/Map.tmj")
    if !ok { 
        panic("Couldn't load map") 
    }

    // give the tilemap to the world
    world.tile_map = tile_map

    // init a player inside the world - texture
    world.player = init_player(assets.player_texture)
    // init the position of the player within the world
    world.player.position = world.tile_map.player_spawn

    // spawn some enemies intot he world - add enemies to the enemy array
    spawn_enemy(&world, assets.enemy_texture, {800, 450})

    spawn_enemy(&world, assets.enemy_texture, {1550, 415})

    // init a camera to the world
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

// from the tilemap data draw the map using the righ ttiles etc
draw_map :: proc(tile_map: ^Tile_Map) 
{
    // do nothing if no tiles
    if len(tile_map.tilesets) == 0 {
        return
    }

    // get the tilesets
    tileset := tile_map.tilesets[0]

    // get all layers ensure they exist
    for &layer in tile_map.layers {

        if layer.layer_type != "tilelayer" {
            continue
        }

        // for all tiles get the texture needed and make them usable rects with the texture
        for y in 0..<layer.height {

            for x in 0..<layer.width {

                index := y * layer.width + x

                gid := layer.data[index]

                if gid == 0 {
                    continue
                }

                tile := gid - tileset.firstgid

                source := rl.Rectangle{
                    f32((tile % tileset.columns) * tileset.tilewidth),
                    f32((tile / tileset.columns) * tileset.tileheight),
                    f32(tileset.tilewidth),
                    f32(tileset.tileheight),
                }

                destination := rl.Vector2{
                    f32(x * tile_map.tilewidth),
                    f32(y * tile_map.tileheight),
                }

                rl.DrawTextureRec(tileset.texture, source, destination, rl.WHITE)
            }
        }
    }
}

// update things that happen in the world like (player, enemies)
update_world :: proc(world: ^World, input: ^Input, delta_time: f32) 
{
    // update the players pos in world - howand when input has been done and tilemappos
    update_player(&world.player, input, delta_time, &world.tile_map)

    // for all enemies in the enemy array
    for i in 0..<len(world.enemies) {
        // update each one
        update_enemy(&world.enemies[i], delta_time, &world.tile_map)
    }

    // if player and an enemy collide - handle that
    if check_collision(&world.player, &world.enemies) {
        // Handle collision
        fmt.println("player and enemy colided")
    }

    // update camera in world pos, player to track and delta time
    update_camera(&world.camera, &world.player, delta_time)
}

// draw all assets and things happening in the world
draw_world :: proc(world: ^World) 
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
        draw_enemy(&enemy)
    }

    rl.EndMode2D()
}