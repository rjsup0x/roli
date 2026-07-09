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

update_camera :: proc(cam: ^Camera_Controller, player: ^Player, dt: f32) 
{
    //--------------------------------------------------
    // Tunables
    //--------------------------------------------------

    PLAYER_WIDTH : f32 = 32

    // Layout:
    //
    // |   outer   |inner|inner|   outer   |
    //
    // The idle deadzone (inner to inner) is exactly PLAYER_WIDTH
    // wide — INNER is a half-width offset from focus, and doubles
    // as the look-ahead resting offset once a direction is active.
    INNER := PLAYER_WIDTH * 0.5
    OUTER := PLAYER_WIDTH * 2

    STIFFNESS : f32 = 220
    DAMPING   : f32 = 26

    //--------------------------------------------------
    // Camera-relative trigger lines
    //--------------------------------------------------
    // Only the OUTER lines matter for triggering — the player is
    // free to roam the whole outer|inner|centre|inner|outer span
    // untouched. Inner lines only exist as the resting positions
    // the spring settles into once a direction is committed to.

    left_outer  := cam.focus.x - OUTER
    right_outer := cam.focus.x + OUTER

    //--------------------------------------------------
    // Trigger + look-ahead tracking
    //--------------------------------------------------

    switch cam.direction {

    case .None:

        if player.position.x > right_outer {
            cam.direction = .Right

            // Look-ahead: push the goal PAST the player, in the
            // direction of travel. Once the spring settles here,
            // player.x == focus.x - INNER, i.e. the player rests
            // on the *opposite* (left) inner line while running
            // right — more world visible ahead of them.
            cam.target.x = player.position.x + INNER
        }

        if player.position.x < left_outer {
            cam.direction = .Left

            cam.target.x = player.position.x - INNER
        }

    case .Right:

        // Keep the look-ahead goal glued to the player for as
        // long as they keep committing to this direction.
        cam.target.x = player.position.x + INNER

        // Player has crossed back through centre — release the
        // camera and let the deadzone re-form around wherever
        // it currently rests.
        if player.position.x <= cam.focus.x {
            cam.direction = .None
        }

    case .Left:

        cam.target.x = player.position.x - INNER

        if player.position.x >= cam.focus.x {
            cam.direction = .None
        }
    }

    //--------------------------------------------------
    // Vertical
    //--------------------------------------------------

    cam.target.y = player.position.y

    //--------------------------------------------------
    // Spring
    //--------------------------------------------------

    accel := (cam.target.x - cam.focus.x) * STIFFNESS
    cam.velocity.x += accel * dt
    cam.velocity.x *= math.exp(-DAMPING * dt)
    cam.focus.x += cam.velocity.x * dt

    accel = (cam.target.y - cam.focus.y) * STIFFNESS
    cam.velocity.y += accel * dt
    cam.velocity.y *= math.exp(-DAMPING * dt)
    cam.focus.y += cam.velocity.y * dt

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
