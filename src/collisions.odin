package main

import rl"vendor:raylib"
import "core:math/rand"

check_player_enemy_collisions :: proc(world: ^World, player: ^Player, enemies: ^[dynamic]Enemy) -> bool 
{

    // for all enemies in the array
    for &enemy in enemies^ {

        // if not alive do nothgin
        if !enemy.is_alive {
            continue
        }

        // if enemy and player arent colliding do nothing
        if !rl.CheckCollisionRecs(player.bounds, enemy.bounds) {
            continue
        }

        // when a player lands on the enemies head
        stomp := player.velocity.y > 0 && (player.position.y + player.bounds.height) <= (enemy.position.y + 10)

        // if player lands on enemy head
        if stomp {
            player.velocity.y = -500
            damage_enemy(&enemy, world)
        } else {
            // if player collides with enemy normally - player takes damage
            damage_player(player)
        }
        // collision happened
        return true
    }
    return false
}

check_horizontal_collision :: proc(object: ^$T, tile_map: ^Tile_Map)
{
    object_rect := rl.Rectangle{
        object.position.x,
        object.position.y,
        32,
        32,
    }

    for collision in tile_map.collisions {
        if rl.CheckCollisionRecs(object_rect, collision) {
            // moving right into wall
            if object.velocity.x > 0 {

                object.position.x = collision.x - 32
            }

            // moving left into wall
            if object.velocity.x < 0 {

                object.position.x = collision.x + collision.width
            }
            object.velocity.x = 0

            break
        }
    }
}

damage_player :: proc(player: ^Player) 
{
    DAMAGE_COOLDOWN :: 1.0
    
    // player not alive do nothing
    if !player.is_alive {
        return
    }

    // if player is on cooldown - do nothing - take no damage
    if player.damage_cooldown > 0 {
        return
    }

    // otherwise player takes damage; -1 live
    player.lives -= 1

    // damage cooldown active for 1 min
    player.damage_cooldown = DAMAGE_COOLDOWN // 1 second invincibility

    // if player has no more lives
    if player.lives <= 0 {
        player.lives = 0
        // player is dead
        player.is_alive = false
    }
}

damage_enemy :: proc(enemy: ^Enemy, world: ^World) 
{
    // kill enemy 
    if !enemy.is_alive {
        return
    }

    enemy.health -= 1

    if enemy.health <= 0 {
        enemy.is_alive = false

        // random coin drop 50% chance
        if rand_chance(50) {
            spawn_coin(world, enemy.position)
        }

        // random life drop 30 % chance
        if rand_chance(30) {
            spawn_life(world, enemy.position)
        }
    }
}

rand_chance :: proc(percent: i32) -> bool 
{
    // Generate range [0, 100) -> values 0 to 99 (100 distinct outcomes)
    random_num := rand.int32_range(0, 100)
    
    // Check if strictly less than percent
    // 1% chance: needs 1 outcome (0). 0 < 1 is true.
    // 100% chance: needs 100 outcomes. 0..99 < 100 is true.
    return random_num < percent
}   