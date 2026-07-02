# Chicken Invader 🐔🚀

A bare-metal x86 space-shooter game that runs directly on real hardware with no operating system.
Written entirely in 16-bit x86 NASM assembly.

---

## Overview

Chicken Invader is a Space Invaders-style game running in BIOS real mode (16-bit).
You pilot a ship at the bottom of the screen, shoot bullets upward, and destroy five
chickens marching across the top. The chickens fire eggs downward; if one hits your
ship, it's game over. The game runs as a raw bootable disk image — no OS, no runtime,
just the CPU and BIOS.

---

## Files

| File              | Description                                                      |
|-------------------|--------------------------------------------------------------------|
| `bootloader.asm`  | Stage 1 bootloader — loaded by BIOS at `0x7C00`, loads game      |
| `spacegame.asm`   | Main game — loaded to `0x9000`, runs the full game loop          |

---

## How It Works

### Bootloader (`bootloader.asm`)

- Loaded by the BIOS at physical address `0x7C00`
- Saves the boot drive ID from `DL`
- Tries **LBA mode** first (`INT 13h`/`AH=0x41` to detect extensions, then `AH=0x42` to
  read via the disk packet structure)
- Falls back to **CHS mode** (`INT 13h`/`AH=0x02`) if LBA extensions aren't supported
  (reads 5 sectors, cylinder 0, head 0, starting at sector 2)
- Both paths load the game to the same place: `0x0000:0x9000`, then jump there
  - **LBA path** — the disk packet's buffer offset/segment fields point to `0x9000:0x0000`
  - **CHS path** — `ES:BX` is set to `0x0000:0x9000` before the read
- On disk error, prints **`m@l`** (LBA read failure) or **`m@c`** (CHS read failure) to
  the screen and halts

### Game (`spacegame.asm`)

- Executes from `0x9000` in 16-bit real mode
- Uses **BIOS INT 10h** (TTY video output, cursor positioning) and **INT 16h** (keyboard)
- All rendering is character-based (ASCII art on the text-mode terminal)
- Uses a software busy-wait double-counter timer (`bx_time` / `dx_time`) to pace animation

---

## Building

Requirements: **NASM**

```bash
nasm bootloader.asm -f bin -o bootloader.bin
nasm spacegame.asm  -f bin -o spacegame.bin
cat bootloader.bin spacegame.bin > chicken_invader.img
```

> The image is padded with zeros inside `spacegame.asm` to reach **1,437,952 bytes**
> (~1.37 MB), which is required by Ventoy to recognise the image as a valid bootable disk.
> This is handled by the line near the bottom of the file:
> ```asm
> TIMES 1437952-($-$$) DB 0
> ```

---

## Running on Real Hardware (Ventoy / USB)

1. Build the image as above.
2. Copy `chicken_invader.img` to the Ventoy USB drive partition.
3. Boot the machine from the USB drive and select the image in the Ventoy menu.
4. The bootloader detects whether the drive supports LBA or falls back to CHS automatically.

> Tested on Intel x86 hardware. The default timer values in `spacegame.asm` are tuned
> for real hardware clock speeds. Both the LBA and CHS load paths now land the game at
> the same address (`0x9000`), so the fallback works correctly on drives/BIOSes without
> INT 13h extensions support.

---

## Running with QEMU

QEMU's busy-wait loop runs slower than on real hardware, so with the default
timer values (tuned for real hardware) the game runs extremely slow under QEMU.
You must lower the timer values before building if you want the game to run at a
normal pace under QEMU.

```bash
qemu-system-x86_64 -drive format=raw,file=chicken_invader.img
```

### Timer Tuning for QEMU (2 GHz CPU, Linux)

The game uses two countdown variables, `bx_time` and `dx_time`, to pace every
animated event. Each function checks whether the timer has reached a specific
threshold before firing. For QEMU, replace the default values with the ones below.

#### `dx_time` (outer / slow counter)

| Default value | QEMU value  | Purpose                           |
|---------------|-------------|-----------------------------------|
| `DW 0x001e`   | `DW 0x000a` | Global outer animation tick rate  |

#### `bx_time` thresholds (inner / fast counter)

Each function compares `bx_time` against a threshold constant. Change the
`CMP WORD [bx_time], ...` value inside the relevant function:

| Function                      | Default threshold | QEMU threshold | Notes                          |
|--------------------------------|-------------------|----------------|---------------------------------|
| `flames_anime` (draw)          | `0x00de`          | `0x010a`       | Draw `*` or `+` flame sprite   |
| `flames_anime` (clear)         | `0x0008`          | `0x000a`       | Clear flame sprite             |
| `chk_ship_destroy_by_egg`      | `0x0001`          | `0x0001`       | No change needed               |
| `check_weapons_clash`          | `0x0001`          | `0x0001`       | No change needed               |
| `init_egg_trojectory`          | `0x0001`          | `0x0001`       | No change needed               |
| `bullet_trogectry_drawer`      | `0x031e`          | `0x010a`       | Advance bullet position        |
| `cls_bullet_trogectry_drawer`  | `0x001e`          | `0x000a`       | Clear previous bullet position |
| `displayhex`                   | active by default | `0x0080`       | Debug: shows timer values in top-left corner (see Known Limitations) |

#### `dx_time` thresholds (outer counter comparisons inside functions)

| Function                      | Default threshold | QEMU threshold | Notes                        |
|--------------------------------|-------------------|----------------|-------------------------------|
| `egg_trojectory_drawer`        | `0x0015`          | `0x0007`       | Move egg downward            |
| `cls_egg_trojectory_drawer`    | `0x0009`          | `0x0003`       | Clear previous egg position  |

> **Tip:** The main game loop reload values at `startsp` copy `bx_time` and `dx_time`
> into `bx_time_bak` / `dx_time_bak` once at startup. The backup values are what
> the timer resets to on every cycle, so changing the `DW` declarations is all that
> is needed — no other code paths need touching for the baseline tick rate.

---

## Controls

| Key         | Scan code | Action                    |
|-------------|-----------|----------------------------|
| ← Left      | `0x4B`    | Move ship left            |
| → Right     | `0x4D`    | Move ship right           |
| ↑ Up        | `0x48`    | Move ship up              |
| ↓ Down      | `0x50`    | Move ship down            |
| Space       | `0x20`    | Fire bullet               |
| Delete      | `0x53`    | Restart (triggers a keyboard-controller system reset via port `0x64`, not just a soft game reset) |

---

## Game Elements

| Element       | ASCII Art                       | Description                                    |
|---------------|----------------------------------|--------------------------------------------------|
| Player ship   | `**\|\|*_/\_*\|___/\___\|\|__\|\|__\|` | Your ship; moves freely on screen |
| Chicken       | `/-(o_o)-\V`                    | 5 enemies, march and descend over time         |
| Bullet        | `....`                          | Fired upward from the ship tip                 |
| Egg           | `0`                              | Dropped downward by chickens                   |
| Flame (`+`)   | `+--+++--+++-++`                | Engine flame, alternates with `*` variant      |
| Flame (`*`)   | `*--***--***-**`                | Engine flame alternate frame                   |

---

## Collision Detection

- **Bullet vs Chicken** (`cmp_and` / `check_collision`) — pixel-accurate multi-point check
  across the bullet's three character positions against each chicken's 8-wide bounding box.
- **Bullet vs Egg** (`check_weapons_clash`) — direct coordinate comparison; both are
  cleared on impact.
- **Egg vs Ship** (`checking_ship_crash`) — checks the egg's position against the ship's
  full hitbox (two overlapping rectangular areas covering the body and fin). Triggers the
  `DEAD` game-over message on hit.

---

## Chicken Movement

Chickens move as a formation, driven by `change_chicken_state`. Their animation state
machine cycles through:
1. **Horizontal oscillation** — left/right with wing-flap offsets
2. **Diagonal upwards** — the whole formation moves diagonally upwards
3. **Reset** — formation resets to starting positions once all are destroyed (`chick_bak`)
4. **Descend downwards** — every 16 animation cycles (`chick_down_count`), the entire
   formation moves down one row (`chick_down`).

Egg launch timing is randomised using a simple byte counter (`randomkey`) that
increments by 2 on every ship movement, cycling 0 → 10 → 0.

---

## Memory Layout

| Address Range      | Contents                              |
|---------------------|----------------------------------------|
| `0x7C00–0x7DFF`     | Bootloader (`bootloader.bin`, 512 bytes) |
| `0x7C00`            | Stack pointer (grows downward)        |
| `0x9000+`           | Game code and data (`spacegame.bin`), loaded here on both the LBA and CHS paths |

---

## Known Limitations

- Single-frame character rendering (no double-buffering); fast CPUs may show flicker.
- Ship boundary checking is not enforced — the ship can be moved off screen.
- `DEAD` text is displayed but the game loop continues running; press **Delete** to restart
  (this triggers a full keyboard-controller reset, not a soft in-game reset).
- The debug `displayhex` routine (shows `dx_time` / `bx_time` in the top-left corner)
  is active by default, called unconditionally from the main loop (`startspc`). To
  disable it, comment out `CALL displayhex` in that loop.# Chicken Invader 🐔🚀

A bare-metal x86 space-shooter game that runs directly on real hardware with no operating system.
Written entirely in 16-bit x86 NASM assembly.

---

## Overview

Chicken Invader is a Space Invaders-style game running in BIOS real mode (16-bit).
You pilot a ship at the bottom of the screen, shoot bullets upward, and destroy five
chickens marching across the top. The chickens fire eggs downward; if one hits your
ship, it's game over. The game runs as a raw bootable disk image — no OS, no runtime,
just the CPU and BIOS.

---

## Files

| File             | Description                                                      |
|------------------|------------------------------------------------------------------|
| `bt.asm`         | Stage 1 bootloader — loaded by BIOS at `0x7C00`, loads game      |
| `spacegame.asm`  | Main game — loaded to `0x9000`, runs the full game loop          |

---

## How It Works

### Bootloader (`bt.asm`)

- Loaded by the BIOS at physical address `0x7C00`
- Saves the boot drive ID from `DL`
- Tries **LBA mode** first (INT 13h / AH=42h) using the disk packet structure
- Falls back to **CHS mode** if LBA is unsupported (reads 5 sectors, cylinder 0, head 0, starting at sector 2)
- Loads the game to `0x0000:0x9000` then jumps to it
- On disk/load error, prints `m@c` (LBA) or `m@l` (CHS) to the screen and halts

### Game (`spacegame.asm`)

- Executes from `0x9000` in 16-bit real mode
- Uses **BIOS INT 10h** (TTY video output, cursor positioning) and **INT 16h** (keyboard)
- All rendering is character-based (ASCII art on the text-mode terminal)
- Uses a software busy-wait double-counter timer (`bx_time` / `dx_time`) to pace animation

---

## Building

Requirements: **NASM**

```bash
nasm bt.asm        -f bin -o bt.bin
nasm spacegame.asm -f bin -o spacegame.bin
cat bt.bin spacegame.bin > chicken_invader.img
```

> The image is padded with zeros inside `spacegame.asm` to reach at least **1 MB**,
> which is required by Ventoy to recognise the image as a valid bootable disk.
> This is handled by the line near the bottom of the file:
> ```asm
> TIMES 1437952-($-$$) DB 0
> ```

---

## Running on Real Hardware (Ventoy / USB)

1. Build the image as above.
2. Copy `chicken_invader.img` to the Ventoy USB drive partition.
3. Boot the machine from the USB drive and select the image in the Ventoy menu.
4. The bootloader detects whether the drive supports LBA or falls back to CHS automatically.

> Tested on Intel x86 hardware. The default timer values in `spacegame.asm` are tuned
> for real hardware clock speeds.

---

## Running with QEMU

QEMU emulates a fast CPU (approximately 2 GHz on Linux), which makes the software
timer count down much faster than on real hardware. You must lower the timer values
before building if you want to run under QEMU.

```bash
qemu-system-x86_64 -drive format=raw,file=chicken_invader.img
```

### Timer Tuning for QEMU (2 GHz CPU, Linux)

The game uses two countdown variables, `bx_time` and `dx_time`, to pace every
animated event. Each function checks whether the timer has reached a specific
threshold before firing. For QEMU, replace the default values with the ones below.

#### `dx_time` (outer / slow counter)

| Default value | QEMU value  | Purpose                           |
|---------------|-------------|-----------------------------------|
| `DW 0x001e`   | `DW 0x000a` | Global outer animation tick rate  |

#### `bx_time` thresholds (inner / fast counter)

Each function compares `bx_time` against a threshold constant. Change the
`CMP WORD [bx_time], ...` value inside the relevant function:

| Function                    | Default threshold | QEMU threshold | Notes                          |
|-----------------------------|-------------------|----------------|--------------------------------|
| `flames_anime` (draw)       | `0x00de`          | `0x010a`       | Draw `*` or `+` flame sprite   |
| `flames_anime` (clear)      | `0x0008`          | `0x000a`       | Clear flame sprite             |
| `chk_ship_destroy_by_egg`   | `0x0001`          | `0x0001`       | No change needed               |
| `check_weapons_clash`       | `0x0001`          | `0x0001`       | No change needed               |
| `init_egg_trojectory`       | `0x0001`          | `0x0001`       | No change needed               |
| `bullet_trogectry_drawer`   | `0x031e`          | `0x010a`       | Advance bullet position        |
| `cls_bullet_trogectry_drawer` | `0x001e`        | `0x000a`       | Clear previous bullet position |
| `displayhex` *(optional)*   | commented out     | `0x0080`       | Debug: show timer values       |

#### `dx_time` thresholds (outer counter comparisons inside functions)

| Function                    | Default threshold | QEMU threshold | Notes                        |
|-----------------------------|-------------------|----------------|------------------------------|
| `egg_trojectory_drawer`     | `0x0015`          | `0x0007`       | Move egg downward            |
| `cls_egg_trojectory_drawer` | `0x0009`          | `0x0003`       | Clear previous egg position  |

> **Tip:** The main game loop reload values at `startsp` copy `bx_time` and `dx_time`
> into `bx_time_bak` / `dx_time_bak` once at startup. The backup values are what
> the timer resets to on every cycle, so changing the `DW` declarations is all that
> is needed — no other code paths need touching for the baseline tick rate.

---

## Controls

| Key         | Action                    |
|-------------|---------------------------|
| ← Left      | Move ship left            |
| → Right     | Move ship right           |
| ↑ Up        | Move ship up              |
| ↓ Down      | Move ship down            |
| Space       | Fire bullet               |
| delete      | Restart (keyboard reset)  |

---

## Game Elements

| Element       | ASCII Art                       | Description                                    |
|---------------|---------------------------------|------------------------------------------------|
| Player ship   | `**\|\|*_/\_*\|___/\___\|\|__\|\|__\|` | Your ship; moves freely on screen |
| Chicken       | `/-(o_o)-\V`                    | 5 enemies, march and descend over time         |
| Bullet        | `....`                          | Fired upward from the ship tip                 |
| Egg           | `0`                             | Dropped downward by chickens                   |
| Flame (`+`)   | `+--+++--+++-++`                | Engine flame, alternates with `*` variant      |
| Flame (`*`)   | `*--***--***-**`                | Engine flame alternate frame                   |

---

## Collision Detection

- **Bullet vs Chicken** — pixel-accurate multi-point check across the bullet's
  three character positions against each chicken's 8-wide bounding box.
- **Bullet vs Egg** — direct coordinate comparison; both are cleared on impact.
- **Egg vs Ship** — checks the egg's position against the ship's full hitbox
  (two overlapping rectangular areas covering the body and fin). Triggers the
  `DEAD` game-over message on hit.

---

## Chicken Movement

Chickens move as a formation. Their animation state machine cycles through:
1. **Horizontal oscillation** — left/right with wing-flap offsets
2. **Diagonal upwards** — the whole formation moves diagonally upwards
3. **Reset** — formation resets to starting positions once all are destroyed
4. **Descend downwards** - every 16 animation cycles, the entire formation moves down one row.

Egg launch timing is randomised using a simple byte counter (`randomkey`) that
increments by 2 on every ship movement, cycling 0 → 10 → 0.

---

## Memory Layout

| Address Range     | Contents                          |
|-------------------|-----------------------------------|
| `0x7C00–0x7DFF`   | Bootloader (`bt.bin`, 512 bytes)  |
| `0x7C00`          | Stack pointer (grows downward)    |
| `0x9000+`         | Game code and data (`spacegame.bin`) |

---

## Known Limitations

- Single-frame character rendering (no double-buffering); fast CPUs may show flicker.
- Ship boundary checking is not enforced — the ship can be moved off screen.
- `DEAD` text is displayed but the game loop continues running; press **DELETE KEY** to restart.
- The debug `displayhex` routine (shows `dx_time` / `bx_time` in the top-left corner)
  is active by default. To disable it, comment out `CALL displayhex` in the `startspc` loop.
