package main

import rl"vendor:raylib"

// shared data for anything that moves, animates, and collides with the
// world (Player, Enemy, Coin_Drop all embed this via `using entity: Entity`)
Entity :: struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    bounds: rl.Rectangle,
    grounded: bool,
    facing_right: bool,
    jumps_remaining: i32,
    animation_state: Animation_State,
    animation: Animation,
}
