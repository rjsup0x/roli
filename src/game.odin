package main

// owns the applications lifetime
Game :: struct {
    assets: Assets,
    world: World,
    input: Input
}

init_game :: proc() -> Game 
{
    // create game instance
    game := Game{}

    // load all games assets for game instance
    game.assets = load_assets()
    // for the games player instance init the player
    game.world = init_world(&game.assets)

    return game
}

deinit_game :: proc(game: ^Game) 
{
    // unload_map(&game.map)
    deinit_world(&game.world)
    unload_assets(&game.assets)

    game^ = {}
}

update_game :: proc(game: ^Game, delta_time: f32) 
{
    update_input(&game.input)
    // update all game instance logic - players, enemies, other entities etc
    update_world(&game.world, &game.input, delta_time)
}

draw_game :: proc(game: ^Game) 
{
    // draw all game instance objects - player, enemy, doors whatevr
    draw_world(&game.world)
}