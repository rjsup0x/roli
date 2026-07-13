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

// joystick axis moves at the frametime
menu_axis_timer: f32 = rl.GetFrameTime()

menu_up_pressed :: proc() -> bool 
{
    if rl.IsKeyPressed(.UP) {
        return true
    }

    if rl.IsGamepadAvailable(0) &&
       menu_axis_timer <= 0 {

        if rl.GetGamepadAxisMovement(0, .LEFT_Y) < -0.5 {
            menu_axis_timer = 0.2
            return true
        }
    }

    return false
}

menu_down_pressed :: proc() -> bool 
{
    if rl.IsKeyPressed(.DOWN) {
        return true
    }

    if rl.IsGamepadAvailable(0) &&
       menu_axis_timer <= 0 {

        if rl.GetGamepadAxisMovement(0, .LEFT_Y) > 0.5 {
            menu_axis_timer = 0.2
            return true
        }
    }

    return false
}

menu_select_pressed :: proc() -> bool 
{
    if rl.IsKeyPressed(.ENTER) {
        return true
    }

    if rl.IsGamepadAvailable(0) {
        return rl.IsGamepadButtonPressed(
            0,
            .RIGHT_FACE_DOWN,
        )
    }

    return false
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

update_menu_screen :: proc(game: ^Game)
{
    // allow axis on jaystick to refresh to allow another movement
    menu_axis_timer -= rl.GetFrameTime()
    if menu_axis_timer < 0 {
        menu_axis_timer = 0
    }

    // keyboard navigation
    if menu_down_pressed() {
        selected_menu += 1

        // navigate throgh menu options - if you get to the end go back to start
        if selected_menu >= len(menu_buttons) {
            selected_menu = 0
        }
    }

    // same but backwards
    if menu_up_pressed() {
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
    if menu_select_pressed() {
        select_menu_option(game)
    }
}

// UPDATE PLAYING SCREEN
update_playing_screen :: proc(game: ^Game, delta_time: f32)
{
    // update parallax - it follows cam
    game.parallax.layer1_x -= game.parallax.layer1_speed * delta_time
    game.parallax.layer2_x -= game.parallax.layer2_speed * delta_time

    tex1_width := f32(game.assets.background_layer1.width)

    if game.parallax.layer1_x <= -tex1_width {
        game.parallax.layer1_x += tex1_width
    }

    tex2_width := f32(game.assets.background_layer2.width)

    if game.parallax.layer2_x <= -tex2_width {
        game.parallax.layer2_x += tex2_width
    }

    if rl.IsKeyPressed(.ESCAPE) ||
       rl.IsGamepadButtonPressed(0, .MIDDLE_RIGHT) {

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
    if menu_down_pressed() {
        selected_gameover += 1

        // navigate throgh menu options - if you get to the end go back to start
        if selected_gameover >= len(gameover_buttons) {
            selected_gameover = 0
        }
    }

    // same but backwards
    if menu_up_pressed() {
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
    if menu_select_pressed() {
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
    if menu_down_pressed() {
        selected_pause += 1

        // navigate throgh menu options - if you get to the end go back to start
        if selected_pause >= len(pause_buttons) {
            selected_pause = 0
        }
    }

    // same but backwards
    if menu_up_pressed() {
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
    if menu_select_pressed() {
        select_pause_option(game)
    }
}