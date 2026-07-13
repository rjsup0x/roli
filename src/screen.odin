package main

import rl"vendor:raylib"

Screen_state :: enum {
    MENU,
    PLAYING,
    GAMEOVER,
    PAUSE
}

Button :: struct {
    text: cstring,
    rect: rl.Rectangle,
}

menu_buttons := [3]Button {
    { "Play",     {} },
    { "Settings", {} },
    { "Quit",     {} },
}

pause_buttons := [3]Button {
    { "Continue playing", {} },
    { "Settings", {} },
    { "Menu", {} }
}

gameover_buttons := [2]Button {
    { "Retry", {} },
    { "Menu", {} },
}

init_menus :: proc()
{
    button_width : f32 = 300
    x := f32(rl.GetScreenWidth()) / 2 - button_width / 2

    // menu screen buttons
    menu_buttons[0].rect = {x, 280, button_width, 60}
    menu_buttons[1].rect = {x, 360, button_width, 60}
    menu_buttons[2].rect = {x, 440, button_width, 60}

    // pause screen buttons
    pause_buttons[0].rect = {x, 280, button_width, 60}
    pause_buttons[1].rect = {x, 360, button_width, 60}
    pause_buttons[2].rect = {x, 440, button_width, 60}

    // gameover screen buttons
    gameover_buttons[0].rect = {x, 280, button_width, 60}
    gameover_buttons[1].rect = {x, 360, button_width, 60}
}

//
selected_menu := 0
selected_pause := 0
selected_gameover := 0

// DRAW and UPDATE - MENU SCREEN
draw_menu :: proc()
{
    FONT_SIZE :: 72
    Y_CORD :: 150
    title: cstring = "ROLI"
    text_size := rl.MeasureText(title, FONT_SIZE)
    half_screen := (rl.GetScreenWidth() / 2) - (text_size / 2)

    rl.DrawText(title, half_screen, Y_CORD, FONT_SIZE, rl.RAYWHITE)

    // for object and index in menu_buttons
    for button, i in menu_buttons {

        // buttons starst gray
        colour := rl.DARKGRAY

        // current selected bnutton is blue
        if i == selected_menu {
            colour = rl.BLUE
        }

        // draw each button outlines
        rl.DrawRectangleRec(button.rect, colour)
        rl.DrawRectangleLinesEx(button.rect, 2, rl.RAYWHITE)

        // draw each buttons text
        rl.DrawText(
            button.text,
            i32(button.rect.x + 20),
            i32(button.rect.y + 15),
            30,
            rl.RAYWHITE,
        )
    }
}

select_menu_option :: proc(game: ^Game)
{
    // which menu option
    switch selected_menu {

    // play
    case 0:
        game.screen = .PLAYING

    // settings
    case 1:
        // settings later

    // QUIT
    case 2:
        game.should_quit = true
    }
}

select_pause_option :: proc(game: ^Game)
{
    switch selected_pause {
        case 0:
            game.screen = .PLAYING

        case 1:
            //settings
        
        case 2:
            restart(game)
            game.screen = .MENU
    }
}

select_gameover_option :: proc(game: ^Game)
{
    switch selected_gameover {
        case 0:
            game.screen = .PLAYING
            restart(game)

        
        case 1:
            game.screen = .MENU
            restart(game)
    }
}

update_menu_screen :: proc(game: ^Game)
{
    // keyboard navigation
    if rl.IsKeyPressed(.DOWN) {
        selected_menu += 1

        // navigate throgh menu options - if you get to the end go back to start
        if selected_menu >= len(menu_buttons) {
            selected_menu = 0
        }
    }

    // same but backwards
    if rl.IsKeyPressed(.UP) {
        selected_menu -= 1

        if selected_menu < 0 {
            selected_menu = len(menu_buttons) - 1
        }
    }

    // mouse hover
    mouse := rl.GetMousePosition()

    // for all buttons in menu_buttons
    for button, i in menu_buttons {
        // check if mouse and button collide
        if rl.CheckCollisionPointRec(mouse, button.rect) {
            // the index of the button pressed
            selected_menu = i

            // if press button go to button action
            if rl.IsMouseButtonPressed(.LEFT) {
                select_menu_option(game)
            }
        }
    }

    // enter key
    if rl.IsKeyPressed(.ENTER) {
        select_menu_option(game)
    }
}

// UPDATE PLAYING SCREEN
update_playing_screen :: proc(game: ^Game, delta_time: f32)
{
    if rl.IsKeyPressed(.ESCAPE) {
        selected_pause = 0
        game.screen = .PAUSE
            return
        }
        // while playing it should also keep updating
        update_input(&game.input)
         // update all game instance logic - players, enemies, other entities etc
        update_world(&game.world, &game.input, delta_time, &game.assets)

        // if the player has no more lives its gameover
        if !game.world.player.is_alive {
            game.screen = .GAMEOVER
        }
}

// DRAW and UPDATE GAMEOVER SCREEN
draw_gameover :: proc()
{
    FONT_SIZE :: 72
    Y_CORD :: 150
    title: cstring = "GAME OVER"
    text_size := rl.MeasureText(title, FONT_SIZE)
    half_screen := (rl.GetScreenWidth() / 2) - (text_size / 2)

    rl.DrawText(title, half_screen, Y_CORD, FONT_SIZE, rl.RAYWHITE)

    // for object and index in menu_buttons
    for button, i in gameover_buttons {

        // buttons starst gray
        colour := rl.DARKGRAY

        // current selected bnutton is blue
        if i == selected_gameover {
            colour = rl.BLUE
        }

        // draw each button outlines
        rl.DrawRectangleRec(button.rect, colour)
        rl.DrawRectangleLinesEx(button.rect, 2, rl.RAYWHITE)

        // draw each buttons text
        rl.DrawText(
            button.text,
            i32(button.rect.x + 20),
            i32(button.rect.y + 15),
            30,
            rl.RAYWHITE,
        )
    }
}

update_gameover_screen :: proc(game: ^Game) {
    // keyboard navigation
    if rl.IsKeyPressed(.DOWN) {
        selected_gameover += 1

        // navigate throgh menu options - if you get to the end go back to start
        if selected_gameover >= len(gameover_buttons) {
            selected_gameover = 0
        }
    }

    // same but backwards
    if rl.IsKeyPressed(.UP) {
        selected_gameover -= 1

        if selected_gameover < 0 {
            selected_gameover = len(gameover_buttons) - 1
        }
    }

    // mouse hover
    mouse := rl.GetMousePosition()

    // for all buttons in menu_buttons
    for button, i in gameover_buttons {
        // check if mouse and button collide
        if rl.CheckCollisionPointRec(mouse, button.rect) {
            // the index of the button pressed
            selected_gameover = i

            // if press button go to button action
            if rl.IsMouseButtonPressed(.LEFT) {
                select_gameover_option(game)
            }
        }
    }

    // enter key
    if rl.IsKeyPressed(.ENTER) {
        select_gameover_option(game)
    }
}

// DRAW and UPDATE PAUSE SCREEN
draw_pause :: proc()
{
    FONT_SIZE :: 72
    Y_CORD :: 150
    title: cstring = "PAUSED"
    text_size := rl.MeasureText(title, FONT_SIZE)
    half_screen := (rl.GetScreenWidth() / 2) - (text_size / 2)

    rl.DrawText(title, half_screen, Y_CORD, FONT_SIZE, rl.RAYWHITE)

    // for object and index in menu_buttons
    for button, i in pause_buttons {

        // buttons starst gray
        colour := rl.DARKGRAY

        // current selected bnutton is blue
        if i == selected_pause {
            colour = rl.BLUE
        }

        // draw each button outlines
        rl.DrawRectangleRec(button.rect, colour)
        rl.DrawRectangleLinesEx(button.rect, 2, rl.RAYWHITE)

        // draw each buttons text
        rl.DrawText(
            button.text,
            i32(button.rect.x + 20),
            i32(button.rect.y + 15),
            30,
            rl.RAYWHITE,
        )
    }
}

update_pause_screen :: proc(game: ^Game)
{
    // keyboard navigation
    if rl.IsKeyPressed(.DOWN) {
        selected_pause += 1

        // navigate throgh menu options - if you get to the end go back to start
        if selected_pause >= len(pause_buttons) {
            selected_pause = 0
        }
    }

    // same but backwards
    if rl.IsKeyPressed(.UP) {
        selected_pause -= 1

        if selected_pause < 0 {
            selected_pause = len(pause_buttons) - 1
        }
    }

    // mouse hover
    mouse := rl.GetMousePosition()

    // for all buttons in menu_buttons
    for button, i in pause_buttons {
        // check if mouse and button collide
        if rl.CheckCollisionPointRec(mouse, button.rect) {
            // the index of the button pressed
            selected_pause = i

            // if press button go to button action
            if rl.IsMouseButtonPressed(.LEFT) {
                select_pause_option(game)
            }
        }
    }
    // enter key
    if rl.IsKeyPressed(.ENTER) {
        select_pause_option(game)
    }
}