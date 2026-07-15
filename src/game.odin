package main

import rl "vendor:raylib"

// owns the applications lifetime
Game :: struct {
    // game controls lifetime of things meccesary to exist as a game
    world:          World,
    assets:         Assets,
    input:          Input,
    screen:         Screen_state,
    should_quit:    bool,
    parallax:       Parallax,
    music_system:   MusicSystem,
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

    game.music_system = init_music_system()

    game.parallax = Parallax{
        layer1_speed = 20,
        layer2_speed = 60,
    }

    return game
}

// game is a pointer to Game (game: ^Game)

// remove game state instance
deinit_game :: proc(game: ^Game) 
{
    // unload_map(&game.map)
    deinit_world(&game.world)
    deinit_music_system(&game.music_system)
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

// game update
update_game :: proc(game: ^Game, delta_time: f32) 
{
    update_music_system(&game.music_system, game.screen)
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
        
        case .SETTINGS:
            update_settings_screen(game)
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
            draw_parallax(game)
            draw_world(&game.world, &game.assets)

        case .GAMEOVER:
            draw_gameover()

        case .PAUSE:
            draw_pause()

        case .SETTINGS:
            draw_settings_screen()
    }
}