package main

import "core:encoding/json"
import "core:os"
import rl "vendor:raylib"
import "core:strings"
import "core:mem"

// whether the tiles have certain properties (ie: collidable)
Tile_Property :: struct {
    name: string,
    property_type: string `json:"type"`,
    value: bool,
}

// data for each layer of a possible tilemap
Tile_Layer :: struct {
    data: []int,
    width: int,
    height: int,
    id: int,
    name: string,
    layer_type: string `json:"type"`,
    visible: bool,
    properties: []Tile_Property,
}

// for each tile - whihc texture its using for the set etc
Tileset :: struct {
    firstgid: int,
    columns: int,
    image: string,
    imagewidth: int,
    imageheight: int,
    tilewidth: int,
    tileheight: int,
    tilecount: int,
    texture: rl.Texture2D,
}

// the whole tilemap - world data
Tile_Map :: struct {
    // use an arena allocator to store the tilemap
    arena: mem.Arena,
    arena_memory: []byte,
    width: int,
    height: int,
    tilewidth: int,
    tileheight: int,
    layers: []Tile_Layer,
    tilesets: []Tileset,
    collisions: [dynamic]rl.Rectangle,
    player_spawn: rl.Vector2,
}

MAP_ARENA_SIZE :: 8 * 1024 * 1024

// laod the .tmj file and handle the data
load_map :: proc(map_path: string) -> (Tile_Map, bool) 
{
    tile_map: Tile_Map

    // memory to store tilemap
    tile_map.arena_memory = make([]byte, MAP_ARENA_SIZE)
    mem.arena_init(&tile_map.arena, tile_map.arena_memory)

    // transfer the allocator from old to arena
    old_allocator := context.allocator
    context.allocator = mem.arena_allocator(&tile_map.arena)

    // on close game give back to old allocator
    defer context.allocator = old_allocator

    // read the tilemap
    bytes, file_err := os.read_entire_file_from_path(
        map_path,
        context.allocator,
    )

    if file_err != nil {
        mem.arena_free_all(&tile_map.arena)
        return Tile_Map{}, false
    }

    json_err := json.unmarshal(bytes, &tile_map)

    if json_err != nil {
        mem.arena_free_all(&tile_map.arena)
        return Tile_Map{}, false
    }

    // for all tiles in tilemap draw them
    for i in 0..<len(tile_map.tilesets) {
        image_path := strings.clone_to_cstring(tile_map.tilesets[i].image)

        tile_map.tilesets[i].texture = rl.LoadTexture(image_path)
    }

    // for all collision objects in the tilemap
    // give them rects and build them as collidable
    build_map_collision(&tile_map)

    // wehre is the tilemap the player spawns
    tile_map.player_spawn = rl.Vector2{200, 300}

    return tile_map, true
}

// getting rid of the data which used memory allocation
unload_map :: proc(tile_map: ^Tile_Map) 
{
    // GPU memory is NOT in the arena
    for &tileset in tile_map.tilesets {
        rl.UnloadTexture(tileset.texture)
    }

    // Free all CPU memory owned by this map
    mem.arena_free_all(&tile_map.arena)

    delete(tile_map.arena_memory)

    tile_map^ = {}
}

// find the tiles from the tilemap using collision and 
// build them using an array of rectangles
build_map_collision :: proc(tile_map: ^Tile_Map) 
{
    // array of rectangles representing collison objects
    tile_map.collisions = make([dynamic]rl.Rectangle)

    // check each layer of the tilemap
    for &layer in tile_map.layers {
        collidable := false

        // check if properties of a layer are collidable
        for property in layer.properties {
            if property.name == "collidable" {
                collidable = property.value
            }
        }

        if !collidable {
            continue
        }

        // check all layers which are collidable and add a collidable rect
        for y in 0..<layer.height {

            for x in 0..<layer.width {

                index := y * layer.width + x

                gid := layer.data[index]

                if gid == 0 {
                    continue
                }

                rect := rl.Rectangle{
                    f32(x * tile_map.tilewidth),
                    f32(y * tile_map.tileheight),
                    f32(tile_map.tilewidth),
                    f32(tile_map.tileheight),
                }

                append(&tile_map.collisions, rect)
            }
        }
    }
}