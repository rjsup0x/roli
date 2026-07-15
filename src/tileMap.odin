package main

import "core:encoding/json"
import "core:os"
import rl "vendor:raylib"
import "core:strings"
import "core:mem"

Tile_Property :: struct {
    name:           string,
    property_type:  string `json:"type"`,
    value:          bool,
}

Tile_Layer :: struct {
    // arrays of objects
    objects:    []Map_Object,
    properties: []Tile_Property,
    data:       []int,
    // object dimensions
    width:      int,
    height:     int,
    id:         int,
    // object values
    name:       string,
    layer_type: string `json:"type"`,
    // object visable
    visible:    bool,
}

Tileset :: struct {
    texture:        rl.Texture2D,
    // tileset data
    firstgid:       int,
    columns:        int,
    imagewidth:     int,
    imageheight:    int,
    tilewidth:      int,
    tileheight:     int,
    tilecount:      int,
    // tileset image data
    image:          string,
}

Tile_Map :: struct {
    // tilemap layers
    layers:         []Tile_Layer,
    // tilesets
    tilesets:       []Tileset,
    // collision tiles
    collisions:     [dynamic]rl.Rectangle,
    // tilemap objects
    player_spawn:   rl.Vector2,
    exits:          [dynamic]rl.Vector2,
    // allocated mem
    arena:          mem.Arena,
    // tilemap dimensions
    width:          int,
    height:         int,
    tilewidth:      int,
    tileheight:     int,
    // alloc mem
    arena_memory:   []byte,
}

Map_Object :: struct {
    // object id
    id:             int,
    // object positions
    x:              f32,
    y:              f32,
    // object data
    name:           string,
    object_type:    string `json:"type"`,
    // object points
    point:          bool,
}

// allocate the size of the memory arena used to create tilemap
MAP_ARENA_SIZE :: 8 * 1024 * 1024

load_map :: proc(map_path: string) -> (Tile_Map, bool)
{
    // load a tilemap instance
    tile_map: Tile_Map
    // give it memory arena
    tile_map.arena_memory = make([]byte, MAP_ARENA_SIZE)

    // init the memory arena for tilemap
    mem.arena_init(&tile_map.arena, tile_map.arena_memory)

    // swap old aloocastor for arena
    old_allocator := context.allocator
    context.allocator = mem.arena_allocator(&tile_map.arena)
    defer context.allocator = old_allocator

    // read the tilemap - store in arena
    bytes, file_err := os.read_entire_file_from_path(map_path, context.allocator)
    // if problems free the memory - return empty tilemap
    if file_err != nil {
        mem.arena_free_all(&tile_map.arena)
        delete(tile_map.arena_memory)
        return Tile_Map{}, false
    }

    json_err := json.unmarshal(bytes, &tile_map)
    if json_err != nil {
        mem.arena_free_all(&tile_map.arena)
        delete(tile_map.arena_memory)
        return Tile_Map{}, false
    }

    // Load EVERY tileset
    for i in 0..<len(tile_map.tilesets) {
        // load all the textures for tilesets
        image_path := strings.clone_to_cstring(tile_map.tilesets[i].image)
        tile_map.tilesets[i].texture = rl.LoadTexture(image_path)

        if !rl.IsTextureReady(tile_map.tilesets[i].texture) {
            // unload anything already loaded
            for j in 0..<i {
                rl.UnloadTexture(tile_map.tilesets[j].texture)
            }

            // free all allocations
            mem.arena_free_all(&tile_map.arena)
            delete(tile_map.arena_memory)

            return Tile_Map{}, false
        }
    }

    build_map_collision(&tile_map)

    // player spawn location
    load_map_objects(&tile_map)

    return tile_map,true
}

unload_map :: proc(tile_map: ^Tile_Map)
{
    // Gunload tilesets from GPU memory
    for &tileset in tile_map.tilesets {
        if rl.IsTextureReady(tileset.texture) {
            rl.UnloadTexture(tileset.texture)
        }
    }

    // unload all mmeory from CPU memory
    mem.arena_free_all(&tile_map.arena)

    delete(tile_map.arena_memory)

    // reset the tilemap to empty
    tile_map^ = {}
}

// Finds the correct tileset for ANY gid
get_tileset :: proc(tile_map: ^Tile_Map, gid:int) -> ^Tileset
{
    // hold the selected tileset
    selected: ^Tileset = nil

    // for all tilesets in the tilemap
    for i in 0..<len(tile_map.tilesets) {
        // get all textures one at a time and make them selected
        if gid >= tile_map.tilesets[i].firstgid {
            selected = &tile_map.tilesets[i]
        }
    }

    return selected
}

// Converts global gid into local tile index
get_local_tile_id :: proc(tileset:^Tileset, gid:int) -> int
{
    return gid - tileset.firstgid
}

build_map_collision :: proc(tile_map:^Tile_Map)
{
    // collidable tiles on the tilemap need memory and a shape (rectangle)
    tile_map.collisions = make([dynamic]rl.Rectangle)

    // for every layer in the tilemap
    for &layer in tile_map.layers {
        collidable := false
        
        // check for collidable propery
        for property in layer.properties {
            if property.name == "collidable" {
                // add the property value to the tile
                collidable = property.value
            }
        }

        // if not collidable tile then continue
        if !collidable {
            continue
        }

        // for size of tilemap
        for y in 0..<layer.height {
            for x in 0..<layer.width {
                index := y * layer.width + x
                gid := layer.data[index]

                if gid == 0 {
                    continue
                }

                // draw the tile on the tilemap
                rect := rl.Rectangle{
                    f32(x * tile_map.tilewidth),
                    f32(y * tile_map.tileheight),
                    f32(tile_map.tilewidth),
                    f32(tile_map.tileheight),
                }

                // add the collision property to the tilemap
                append(&tile_map.collisions, rect)
            }
        }
    }
}

load_map_objects :: proc(tile_map: ^Tile_Map)
{
    tile_map.exits = make([dynamic]rl.Vector2)

    for layer in tile_map.layers {

        if layer.layer_type != "objectgroup" {
            continue
        }


        for object in layer.objects {

            position := rl.Vector2{
                object.x,
                object.y,
            }


            switch object.name {

            case "PlayerSpawn":
                tile_map.player_spawn = position


            case "Exit":
                append(&tile_map.exits, position)
            }
        }
    }
}