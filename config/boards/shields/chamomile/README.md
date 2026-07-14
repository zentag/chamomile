# Chamomile ZMK shield

Generated from the ergogen source for the "chamomile" split board (Xiao BLE, 6-column
column-staggered matrix + 4-key thumb cluster per half, choc v1 hotswap).

## Pin mapping assumption — verify before flashing

The ergogen file uses net names `P0`..`P10` for `column_net` / `row_net`. There are
exactly 11 of these, matching the Xiao BLE's 11 broken-out GPIO pins `D0`..`D10`.
This shield assumes a direct mapping: net `Pn` -> `&xiao_d n`. If your actual
schematic routed these nets to different physical MCU pins, edit the
`row-gpios` / `col-gpios` in `chamomile.dtsi` to match your board — the net
*names* in ergogen don't guarantee a particular physical pin, only your KiCad
schematic does.

Wiring per the ergogen config (diode from `colrow` to `row_net` — columns
driven, rows sensed — hence `diode-direction = "col2row"`):

| Net | Function            | Xiao pin (assumed) |
|-----|----------------------|---------------------|
| P0  | col: outer           | D0 |
| P1  | col: pinky           | D1 |
| P2  | col: ring            | D2 |
| P3  | col: middle          | D3 |
| P4  | col: index            | D4 |
| P5  | col: inner            | D5 |
| P9  | col: thumb-right      | D9 |
| P10 | col: thumb-left       | D10 |
| P6  | row: top              | D6 |
| P8  | row: home             | D8 |
| P7  | row: bottom           | D7 |

## Assumptions to double check

- **Right half mirrors the left electrically.** Since the ergogen `pcbs` section
  only defines a `left` PCB, I've assumed the right half is the same design
  mirrored, with the same net-to-pin mapping. `chamomile_right.overlay` reuses
  the same `row-gpios`/`col-gpios` as the left and just applies a
  `col-offset = <8>` so its key events land in the right half of the combined
  keymap. If the right PCB is wired differently, its `col-gpios`/`row-gpios`
  need their own override in `chamomile_right.overlay`.
- **Thumb key reading order.** The exact left-to-right physical order of the
  thumb keys (especially which one sits closer to the center of the board)
  wasn't derivable from the ergogen point data alone since it depends on the
  -20° rotation and exact key placement. The matrix transform in
  `chamomile.dtsi` picks a reasonable order (thumb-left, then thumb-right,
  mirrored on the right half) — if it doesn't match your physical board, swap
  the `RC(...)` order in the thumb rows of the `map` in `chamomile.dtsi` and
  the corresponding keymap bindings.

## Using this shield

1. Copy `boards/shields/chamomile/` into a ZMK module or your `zmk-config`'s
   `config/boards/shields/` directory.
2. Add to your `build.yaml`:

   ```yaml
   include:
     - board: xiao_ble
       shield: chamomile_left
     - board: xiao_ble
       shield: chamomile_right
   ```

3. Build/flash as usual. Left half is the BLE central (holds the keymap and
   pairs with your host); right half is the peripheral.

## Layout

44 keys total (22 per half): 6 columns x 3 rows main matrix + 4-key thumb
cluster, per side. Default keymap has 4 layers: base (QWERTY), lower
(numbers/nav), raise (symbols), adjust (Bluetooth/reset).
