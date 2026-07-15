package main

import rl"vendor:raylib"

MusicSystem :: struct {
    // track playing depends on cyrrent_state (which screen is being used)
    tracks:         [Screen_state]rl.Music,
    // gold the current screen state
    current_screen: Screen_state,
    // control the vol of music
    volume:         f32,
}

init_music_system :: proc() -> MusicSystem
{
    rl.InitAudioDevice()

    music_system := MusicSystem{}

    // load music
    music_system.tracks[.MENU]      = rl.LoadMusicStream("assets/music/menu_music.ogg")
    music_system.tracks[.PLAYING]   = rl.LoadMusicStream("assets/music/game_music.ogg")
    music_system.tracks[.PAUSE]     = rl.LoadMusicStream("assets/music/menu_music.ogg")
    music_system.tracks[.GAMEOVER]  = rl.LoadMusicStream("assets/music/menu_music.ogg")

    // volume
    music_system.volume = 0.5

    // apply volume for every track
    for &music in music_system.tracks {
        rl.SetMusicVolume(music, music_system.volume)
    }

    // sets current music to menu music (game loads to menu)
    music_system.current_screen = .MENU

    // so play menu music
    rl.PlayMusicStream(music_system.tracks[.MENU])

    return music_system
}

update_music_system :: proc(music_system: ^MusicSystem, screen: Screen_state)
{
    // if the music player is a screen that doesnt match the expected screen state
    if screen != music_system.current_screen {
        // stop what music system things is the correct music state
        rl.StopMusicStream(music_system.tracks[music_system.current_screen])

        // get the correct state and play it
        rl.PlayMusicStream(music_system.tracks[screen])
        
        music_system.current_screen = screen
    }
    // ensure the stream is playing the right track
    rl.UpdateMusicStream(music_system.tracks[music_system.current_screen])
}

set_music_volume :: proc(music_system: ^MusicSystem, volume: f32)
{
    // ensure volume cant be lower than 0 or higher than 1
    new_volume := volume
    
    if new_volume < 0.0 {
        new_volume = 0.0
    }

    if new_volume > 1.0 {
        new_volume = 1.0
    }

    // set the music volume to 0
    music_system.volume = new_volume

    // for every track state set music in the system to desired volume
    for &music in music_system.tracks {
        rl.SetMusicVolume(music, music_system.volume)
    }
}

get_music_volume :: proc(ms: ^MusicSystem) -> f32 {
    return ms.volume
}

pause_music :: proc(ms: ^MusicSystem) {
    rl.PauseMusicStream(ms.tracks[ms.current_screen])
}

resume_music :: proc(ms: ^MusicSystem) {
    rl.ResumeMusicStream(ms.tracks[ms.current_screen])
}

stop_music :: proc(ms: ^MusicSystem) {
    rl.StopMusicStream(ms.tracks[ms.current_screen])
}

play_current_music :: proc(ms: ^MusicSystem) {
    rl.PlayMusicStream(ms.tracks[ms.current_screen])
}

deinit_music_system :: proc(ms: ^MusicSystem) {

    for music in ms.tracks {
        rl.UnloadMusicStream(music)
    }

    rl.CloseAudioDevice()
}
