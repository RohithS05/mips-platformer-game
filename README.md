# MIPS Platformer 🎮

A 2D platformer game written entirely in **MIPS Assembly**, featuring multiple levels, power-ups, diagonal jumps, and full win/lose conditions.

## Features
- **3 Levels**: progressively harder stages with unique platforms, coins, and pickups.  
- **Platforming mechanics**: move, jump, double-jump, and diagonal jumps.  
- **Power-ups**: hearts, red mushrooms, and cyan mushrooms.  
- **Lives system**: you start with 3 hearts — hitting the floor costs 1 heart.  
- **Win/Lose conditions**: collect all coins to advance, or lose when hearts run out.  
- **Bitmap rendering**: runs on a 256×256 pixel display using the MARS Bitmap Display tool.  

## Gameplay
- **Objective**: Collect **all coins 🪙** in a level to unlock the next one.  
- **Hearts ❤️**: You start with **3 hearts**. If you touch the floor, you lose 1 heart.  
- **Death**: If your hearts reach 0, the game ends.  
- **Victory**: Clear all **3 levels** by collecting every coin.  

### Power-Ups
- ❤️ **Heart** → Restores 1 heart (up to max health).  
- 🍄 **Red Mushroom** → Permanently increases player height.  
- 🍄 **Cyan Mushroom** → Permanently increases jump power and turns the player cyan.  

## Controls
- `A` → Move left  
- `D` → Move right  
- `W` → Jump / Double jump  
- `Q` → Diagonal jump left  
- `E` → Diagonal jump right  
- `R` → Restart game  
- `Z` → Quit game  

## File
- `game.asm` → Main Assembly source code for the platformer.  

## How to Run
1. Open `game.asm` in the [MARS MIPS Simulator](http://courses.missouristate.edu/kenvollmar/mars/).  
2. Enable the **Bitmap Display Tool**:  
   - Unit width: `4`  
   - Unit height: `4`  
   - Display width: `256`  
   - Display height: `256`  
   - Base address: `0x10008000 ($gp)`  
3. Assemble and run the program.  

## Requirements
- **MARS MIPS Simulator** (tested on version 4.5).  
- **Java Runtime Environment (JRE)** installed to run MARS.  

## Development Notes
- **Physics**: gravity, jumping, diagonal jumps, and collision detection are manually implemented.  
- **Rendering**: sprites (player, coins, mushrooms, hearts, platforms) are drawn pixel by pixel.  
- **Game loop**: input handling → physics updates → collision checks → rendering cycle.  

## Future Improvements
- Background music and sound effects.  
- Enemy AI and moving hazards.  
- Additional levels with unique mechanics.  
- Animated sprites.  

## Demo
A full gameplay demo is available here:  
[YouTube Video](https://youtu.be/9eYF6T4EQ9s)  

## Acknowledgements
- **CSCB58 Teaching Team** for project guidance.  
- Developers of MARS for providing the simulator and bitmap display tool.  
- Inspiration from classic platformers such as *Mario* and *Celeste*.  
