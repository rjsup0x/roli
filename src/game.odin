package main

import rl "vendor:raylib"

// owns the applications lifetime
Game :: struct {
    assets: Assets,
    world: World,
    input: Input,
    screen: Screen_state
}

// create game state instance
init_game :: proc() -> Game 
{
    // create game instance
    game := Game{}

    // load all games assets for game instance
    game.assets = load_assets()
    // for the games player instance init the player
    game.world = init_world(&game.assets)

    // set screen state to menu
    game.screen = .MENU

    return game
}

// game is a pointer to Game (game: ^Game)

// remove game state instance
deinit_game :: proc(game: ^Game) 
{
    // unload_map(&game.map)
    deinit_world(&game.world)
    unload_assets(&game.assets)

    // remove games state
    game^ = {}
}

// remove gamestate instance and reload it back fresh
restart :: proc(game: ^Game)
{
    deinit_game(game)
    // dereference - take the Game that game points to
    // reinit the games state - back to fresh
    game^ = init_game()
}

// update screens
update_menu_screen :: proc(game: ^Game)
{
    update_menu()

    if rl.IsKeyPressed(.ENTER) {
        game.screen = .PLAYING
    }
}

update_playing_screen :: proc(game: ^Game, delta_time: f32)
{
    if rl.IsKeyPressed(.ESCAPE) {
        game.screen = .PAUSE
            return
        }
        // while playing it should also keep updating
        update_input(&game.input)
         // update all game instance logic - players, enemies, other entities etc
        update_world(&game.world, &game.input, delta_time)
}

update_pause_screen :: proc(game: ^Game)
{
    update_pause()

    if rl.IsKeyPressed(.ENTER) {
        game.screen = .PLAYING
    }

    if rl.IsKeyPressed(.ESCAPE){
        game.screen = .MENU
        restart(game)
    }
}

update_gameover_screen :: proc(game: ^Game) {
    update_gameover()

    if rl.IsKeyPressed(.ENTER) {
        restart(game)
    }
}

// game update
update_game :: proc(game: ^Game, delta_time: f32) 
{
    // TODO: ensure all the correct buttons for the screen navigations
    // TODO: acutally update the screens logic
    switch game.screen {
        // if in menu and press enter play game
        case .MENU:
            update_menu_screen(game)

        // if in playing state escape to pause
        case .PLAYING:
            update_playing_screen(game, delta_time)

        // if paused escape to continue playing
        case .PAUSE:
            update_pause_screen(game)

        case .GAMEOVER:
            update_gameover_screen(game)
    }

}

// draw game
draw_game :: proc(game: ^Game) 
{
    switch game.screen {
        // if in menu and press enter play game
        case .MENU:
            draw_menu()
            
        case .PLAYING:
            // draw all game instance objects - player, enemy, doors whatevr
            draw_world(&game.world)

        case .GAMEOVER:
            draw_gameover()

        case .PAUSE:
            draw_pause()

    }
}