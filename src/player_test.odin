package main

import "core:testing"

@(test)
test_player_takes_damage :: proc(t: ^testing.T) {
    player := Player{
        lives = 3,
        is_alive = true,
        damage_cooldown = 0,
    }

    damage_player(&player)

    testing.expect(t, player.lives == 2)
    testing.expect(t, player.damage_cooldown == 1.0)
    testing.expect(t, player.is_alive == true)
}

@(test)
test_player_cannot_take_damage_during_cooldown :: proc(t: ^testing.T) {
    player := Player{
        lives = 3,
        is_alive = true,
        damage_cooldown = 0.5,
    }

    damage_player(&player)

    testing.expect(t, player.lives == 3)
}