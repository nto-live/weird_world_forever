class_name Room
extends RefCounted
## One screen-sized room: a 16x14 tile grid plus a dictionary of doors to neighbour rooms.
## Screen = 16 tiles * 16 px = 256 px wide, 14 tiles * 16 px = 224 px tall.

const W := 16
const H := 14
const TILE := 16
const FLOOR := 0
const WALL := 1

var id: int = 0
var depth: int = 0
var grid: Array = []            # grid[y][x] -> 0 floor / 1 wall
var doors: Dictionary = {}      # Vector2i(direction) -> Room
var tags: Array = []            # e.g. ["start"], ["exit"], ["key"], ["boss"]
var biome: String = "crypts"     # see Bestiary; drives floor/wall colours and the enemy pool
var gate: String = ""            # optional world obstacle here: cracked/water/gap/web/boulder/peg

func _init(_id: int = 0) -> void:
    id = _id
    grid = []
    for y in H:
        var row: Array = []
        for x in W:
            var edge := (x == 0 or y == 0 or x == W - 1 or y == H - 1)
            row.append(WALL if edge else FLOOR)
        grid.append(row)

## Cell (in tiles) where this room's door in `dir` sits.
func door_cell(dir: Vector2i) -> Vector2i:
    if dir == Vector2i.UP:
        return Vector2i(W / 2, 0)
    if dir == Vector2i.DOWN:
        return Vector2i(W / 2, H - 1)
    if dir == Vector2i.LEFT:
        return Vector2i(0, H / 2)
    return Vector2i(W - 1, H / 2)

func tile_at(world_pos: Vector2) -> Vector2i:
    return Vector2i(int(floor(world_pos.x / TILE)), int(floor(world_pos.y / TILE)))

func in_bounds(c: Vector2i) -> bool:
    return c.x >= 0 and c.y >= 0 and c.x < W and c.y < H

## True if the world position is outside the room (=> triggers a transition)
## or on a non-wall tile inside the room.
func is_world_walkable(world_pos: Vector2) -> bool:
    var c := tile_at(world_pos)
    if not in_bounds(c):
        return true     # stepping out the edge is allowed; Main handles the transition
    return grid[c.y][c.x] != WALL

func set_tile(x: int, y: int, t: int) -> void:
    if x > 0 and y > 0 and x < W - 1 and y < H - 1:
        grid[y][x] = t
