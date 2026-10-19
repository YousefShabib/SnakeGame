# Snake Game

A Snake game built with Lua and LÖVE, featuring a menu, keyboard controls, scoring, persistent high scores, and an event system.

## Run
Install [LÖVE](https://love2d.org), then run `love .` from the project folder.

## Controls
- **Enter / Space:** Start or restart
- **Arrow keys / WASD:** Move
- **P:** Pause
- **Esc:** Return to menu or quit

## Tests
Run `lua tests/run.lua`. All 11 tests passed on Lua 5.1 and 5.4; rendering was verified with LÖVE 11.5.

High scores use `love.filesystem` in LÖVE and Lua 5.4's `<close>` feature when running with Lua 5.4.
