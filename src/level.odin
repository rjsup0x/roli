package main

import "core:fmt"
import rl "vendor:raylib"

// helper to create enemies and add them to an array of enemies
spawn_enemy :: proc(world: ^World, texture: rl.Texture2D, position: rl.Vector2) 
{
	// init an enemy with texture and position
	enemy := init_enemy(texture, position)
	enemy.start_position = enemy.position

	// apopend to the enemies array
	append(&world.enemies, enemy)
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
