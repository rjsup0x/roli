package main

import rl "vendor:raylib"
import "core:math"

Camera_Direction :: enum {
    None,
    Left,
    Right,
}

Camera_Controller :: struct {
    camera: rl.Camera2D,

    // Actual camera position
    focus: rl.Vector2,

    // Goal position
    target: rl.Vector2,

    // Spring velocity
    velocity: rl.Vector2,

    // Current push direction
    direction: Camera_Direction,
}

init_camera :: proc(player: ^Player) -> Camera_Controller 
{
    cam := Camera_Controller{}

    cam.focus = player.position
    cam.target = player.position
    cam.direction = .None

    cam.camera = rl.Camera2D{
        target = cam.focus,
        offset = {
            f32(rl.GetScreenWidth()) / 2,
            f32(rl.GetScreenHeight()) * 0.6,
        },
        rotation = 0,
        zoom = 1,
    }

    return cam
}

update_camera :: proc(cam: ^Camera_Controller, player: ^Player, delta_time: f32)
{
    // Tunables
    PLAYER_WIDTH : f32 = 32

    INNER := PLAYER_WIDTH * 0.5
    OUTER := PLAYER_WIDTH * 2

    STIFFNESS : f32 = 220
    DAMPING   : f32 = 26

    // World size
    WORLD_WIDTH : f32 = 1600

    // Camera-relative trigger lines
    left_outer  := cam.focus.x - OUTER
    right_outer := cam.focus.x + OUTER

    // Trigger + look-ahead tracking
    switch cam.direction {

    case .None:

        if player.position.x > right_outer {
            cam.direction = .Right
            cam.target.x = player.position.x + INNER
        }

        if player.position.x < left_outer {
            cam.direction = .Left
            cam.target.x = player.position.x - INNER
        }

    case .Right:

        cam.target.x = player.position.x + INNER

        if player.position.x <= cam.focus.x {
            cam.direction = .None
        }

    case .Left:

        cam.target.x = player.position.x - INNER

        if player.position.x >= cam.focus.x {
            cam.direction = .None
        }
    }
    
    // Vertical deadzone
    VERTICAL_DEADZONE : f32 = 96

    top := cam.focus.y - VERTICAL_DEADZONE
    bottom := cam.focus.y + VERTICAL_DEADZONE

    if player.position.y < top {
        // Player jumped high enough to leave the deadzone.
        cam.target.y = player.position.y + VERTICAL_DEADZONE
    } else if player.position.y > bottom {
        // Player fell below the deadzone.
        cam.target.y = player.position.y - VERTICAL_DEADZONE
    } else {
        // Stay where we are.
        cam.target.y = cam.focus.y
    }

    // Spring
    accel := (cam.target.x - cam.focus.x) * STIFFNESS
    cam.velocity.x += accel * delta_time
    cam.velocity.x *= math.exp(-DAMPING * delta_time)
    cam.focus.x += cam.velocity.x * delta_time

    accel = (cam.target.y - cam.focus.y) * STIFFNESS
    cam.velocity.y += accel * delta_time
    cam.velocity.y *= math.exp(-DAMPING * delta_time)
    cam.focus.y += cam.velocity.y * delta_time

    // Clamp to world bounds
    half_view_width := f32(rl.GetScreenWidth()) * 0.5 / cam.camera.zoom

    min_x := half_view_width
    max_x := WORLD_WIDTH - half_view_width

    if cam.focus.x < min_x {
        cam.focus.x = min_x
        cam.velocity.x = 0
    }

    if cam.focus.x > max_x {
        cam.focus.x = max_x
        cam.velocity.x = 0
    }

    cam.camera.target = cam.focus
}

draw_camera_debug :: proc(cam: ^Camera_Controller) 
{
    PLAYER_WIDTH : f32 = 32

    INNER := PLAYER_WIDTH * 0.5
    OUTER := PLAYER_WIDTH * 2

    cx := cam.focus.x
    cy := cam.focus.y

    height : f32 = 2000 // Tall enough to span the level

    left_outer  := cx - OUTER
    left_inner  := cx - INNER
    right_inner := cx + INNER
    right_outer := cx + OUTER

    rl.DrawLineV(
        {left_outer, cy - height},
        {left_outer, cy + height},
        rl.RED,
    )

    rl.DrawLineV(
        {left_inner, cy - height},
        {left_inner, cy + height},
        rl.ORANGE,
    )

    rl.DrawLineV(
        {right_inner, cy - height},
        {right_inner, cy + height},
        rl.ORANGE,
    )

    rl.DrawLineV(
        {right_outer, cy - height},
        {right_outer, cy + height},
        rl.RED,
    )
}
