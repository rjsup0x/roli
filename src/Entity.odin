package main

import rl"vendor:raylib"

Entity :: struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    gounded: bool,
    facing_right: bool,
    animation: Animation,
}