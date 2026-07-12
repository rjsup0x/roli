package main

import "core:fmt"
import rl "vendor:raylib"

// when enemy dies random chance for spawn coin into world
spawn_coin :: proc(world: ^World, position: rl.Vector2) 
{
	coin := init_coin(position)
	coin.position = position

	coin.velocity = {
    	0,
   	 	-250,
	}

	fmt.printfln("Spawned coin")
    append(&world.coins, coin)
}

// when enemy dies random chance for spawn life into world
spawn_life :: proc(world: ^World, position: rl.Vector2) 
{
	life := init_health_drop(position)
	life.position = position

	fmt.printfln("Spawned health")
    append(&world.health_drops, life)
}

// update coins + health drops out in the world, and collect any the player
// is touching
update_pickups :: proc(world: ^World, delta_time: f32)
{
	// Collect coins
    for i := 0; i < len(world.coins); i += 1 {

        coin := &world.coins[i]

		update_coin(coin, delta_time, &world.tile_map)

        if coin.collected {
            continue
        }

		// if player collides with coin collect it
        if rl.CheckCollisionCircles(
            world.player.position,
            16,
            coin.position,
            8,
        ) {
            coin.collected = true
            world.player.coins += 1
        }
    }

	// collect health drops
	for i := 0; i < len(world.health_drops); i += 1 {

		drop := &world.health_drops[i]

		if drop.collected {
			continue
		}

		// player collided with health drop collect it
		if rl.CheckCollisionCircles(
			world.player.position,
			16,
			drop.position,
			8,
		) {
			// only heal if not already full
			if world.player.lives < world.player.max_lives {

				world.player.lives += 1

				drop.collected = true
			}
		}
	}
}
