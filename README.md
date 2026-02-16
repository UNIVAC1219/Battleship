# Battleship Game - C Port

Cross-platform Battleship game implementation in C with Intermediate Adversary AI.

## Features

- **Intermediate Adversary AI**: Hunt & Target algorithm
  - Hunt mode: Fires at checkerboard pattern for efficiency
  - Target mode: When a ship is hit, fires at adjacent squares
  - Adaptive strategy that switches between modes

- **Cross-Platform Random Number Generation**
  - XorShift32 algorithm seeded with `time(0)`
  - Works consistently across all platforms including UNIVAC 1219
  - No dependency on platform-specific RNG functions

- **Platform-Specific Optimizations**
  - Uses `strcpy_s` on MSVC for safety
  - Uses `strncpy` on GCC and UNIVAC for compatibility
  - Conditional compilation with `#ifdef` preprocessor directives

## Building

### Quick Build

Simply run the batch file and select your platform:

```batch
build_battleship.bat
```

## File Structure

- `battleship.h` - Main header with cross-platform definitions
- `main.c` - Game main loop and user interaction
- `battlefield.c` - Battlefield management and validation
- `ship.c` - Ship data structure and operations
- `player.c` - Player management
- `ai_engine.c` - Intermediate Adversary AI implementation
- `utils.c` - Utility functions (RNG, screen clearing, input)
- `build_battleship.bat` - Unified build script

## How to Play

1. Run the executable for your platform
2. Enter your name
3. Place your 5 ships:
   - Aircraft Carrier (5 squares)
   - Battleship (4 squares)
   - Cruiser (3 squares)
   - Submarine (3 squares)
   - Destroyer (2 squares)
4. Take turns firing at coordinates (e.g., "B5")
5. First to sink all enemy ships wins!

Seeded with `time(0)` XOR'd with a constant for UNIVAC compatibility.

## AI Algorithm

The Intermediate Adversary uses a Hunt & Target strategy:

1. **Hunt Mode**: Fires at squares in a checkerboard pattern (even parity)
   - More efficient than random firing
   - Guarantees hitting any ship of length 2 or more

2. **Target Mode**: When a ship is hit:
   - Calculates adjacent squares (North, South, East, West)
   - Fires at valid adjacent positions
   - Continues until ship is sunk
   - Returns to Hunt mode when ship is destroyed

3. **State Management**:
   - Maintains list of all possible targets (0-99 encoded coordinates)
   - Maintains hunt list (checkerboard pattern)
   - Tracks fired positions to avoid duplicates