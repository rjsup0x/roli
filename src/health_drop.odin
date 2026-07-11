package main

import rl"vendor:raylib"

// has position and whether it was collected
Health_Drop :: struct {
    position: rl.Vector2,
    collected: bool,
}