package main

import rl "vendor:raylib"
import "core:fmt"

Animation :: struct {
    row: i32,
    frame: i32,
    frame_count: i32,
    
    frame_time: f32,
    timer: f32,

    loop: bool,
}

// spritesheet should match this
Animation_State :: enum {
    Idle_Right,
    Idle_Left,
    Run_Right,
    Run_Left,
    Jump_Left,
    Jump_Right,
}

update_animation :: proc(object: ^$T, delta_time: f32) 
{
        // Choose animation
        // if object not on ground (hes jumping) so play jumping animations per direction
        if !object.grounded {

            if object.facing_right {
                set_animation(object, .Jump_Right)
            } else {
                set_animation(object, .Jump_Left)
            }

        // if object on ground but moving - play running animation per direction
        } else if abs(object.velocity.x) > 0 {

            if object.facing_right {
                set_animation(object, .Run_Right)
            } else {
                set_animation(object, .Run_Left)
            }
        // object on ground but not moving - play idle animation per direction
        } else {

            if object.facing_right {
                set_animation(object, .Idle_Right)
            } else {
                set_animation(object, .Idle_Left)
            }
        }

    // Advance frames
    object.animation.timer += delta_time

    if object.animation.timer >= object.animation.frame_time {

        object.animation.timer = 0

        object.animation.frame += 1

        if object.animation.frame >= object.animation.frame_count {
            object.animation.frame = 0
        }
    }
}

update_coin_animation :: proc(coin: ^Coin_Drop, delta_time: f32)
{
    coin.animation.timer += delta_time

    if coin.animation.timer >= coin.animation.frame_time {
        coin.animation.timer = 0

        coin.animation.frame += 1

        if coin.animation.frame >= coin.animation.frame_count {
            coin.animation.frame = 0
        }
    }
}

// TODO: possibly change this to set player animations 
// and add a set enemy animations procedure too
set_animation :: proc(object: ^$T, state: Animation_State) 
{
    if object.animation_state == state {
        return
    }

    object.animation_state = state

    switch state {

    // ensure right row for animation
    // ensure right animation length for row
    // ensure right time for anims
    case .Idle_Right:
        object.animation.row = 0
        object.animation.frame_count = 11
        object.animation.frame_time = 0.15

    case .Idle_Left:
        object.animation.row = 1
        object.animation.frame_count = 11
        object.animation.frame_time = 0.15

    case .Run_Right:
        object.animation.row = 2
        object.animation.frame_count = 12
        object.animation.frame_time = 0.08

    case .Run_Left:
        object.animation.row = 3
        object.animation.frame_count = 12
        object.animation.frame_time = 0.08

    case .Jump_Left:
        object.animation.row = 4
        object.animation.frame_count = 1
        object.animation.frame_time = 999

    case .Jump_Right:
        object.animation.row = 5
        object.animation.frame_count = 1
        object.animation.frame_time = 999
    }

    object.animation.frame = 0
}