package main

import rl "vendor:raylib"

Input :: struct {
    // movement on x
    move_x: f32,

    // actions
    jump_pressed: bool,
    attack_pressed: bool,

    // optional held states
    jump_down: bool,
    attack_down: bool,
}

update_input :: proc(input: ^Input) 
{
    input^ = {}

    // Keyboard movement
    if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) {
        input.move_x -= 1
    }

    if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) {
        input.move_x += 1
    }

    // Controller movement
    if rl.IsGamepadAvailable(0) {

        stick_x := rl.GetGamepadAxisMovement(
            0,
            .LEFT_X,
        )

        // deadzone
        if abs(stick_x) > 0.2 {
            input.move_x = stick_x
        }
    }

    // Jump
    input.jump_pressed =
        rl.IsKeyPressed(.SPACE) ||
        rl.IsKeyPressed(.W) ||
        rl.IsGamepadButtonPressed(
            0,
            .RIGHT_FACE_DOWN,
        )

    input.jump_down = rl.IsKeyDown(.SPACE)

    // Attack
    input.attack_pressed =
        rl.IsMouseButtonPressed(.LEFT) ||
        rl.IsGamepadButtonPressed(
            0,
            .RIGHT_FACE_RIGHT,
        )
}

update_jump :: proc(player: ^Player, input: ^Input) 
{
    // if jump pressed
    if input.jump_pressed {
        // if has jumps remaning (player has 2 jumps)
        if player.jumps_remaining > 0 {

            // move the player on the y scale
            player.velocity.y = -600

            // reduce jumps
            player.jumps_remaining -= 1
            // player no longer on the ground
            player.grounded = false
        }
    }
}