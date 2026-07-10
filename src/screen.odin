package main

import rl"vendor:raylib"

Screen_state :: enum {
    MENU,
    PLAYING,
    GAMEOVER,
    PAUSE
}

// draw procedures draw how the screen will look (buttons etc)
draw_menu :: proc()
{
    //rl.ClearBackground(rl.BLACK)

    rl.DrawText("ROLI", 420, 220, 72, rl.RAYWHITE)
    rl.DrawText("Press ENTER to play", 470, 360, 26, rl.RAYWHITE);
}

//  update procedures update things like mouse pos for a button to press on a screen
update_menu :: proc()
{

}

draw_gameover :: proc()
{
    rl.DrawText("Gameover screen", 200, 200, 20, rl.BLACK)
}

update_gameover :: proc()
{
    
}

draw_pause :: proc()
{
    // rl.DrawRectangle(0, 0, 1280, 720, rl.RAYWHITE)
    rl.DrawText("PAUSED", 530, 310, 52, rl.RAYWHITE);
    rl.DrawText("Press ESC for menu", 490, 385, 24, rl.RAYWHITE);
    rl.DrawText("Press ENTER to resume", 490, 485, 24, rl.RAYWHITE);
}

update_pause :: proc()
{
    
}