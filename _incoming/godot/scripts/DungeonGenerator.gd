class_name DungeonGenerator
extends RefCounted
## Minimal procedural dungeon: scatter N rooms on a coarse cell grid, connect orthogonally
## adjacent rooms, tag a start and a far exit. Replace the room *contents* with real generation
## (tile layout, enemies, loot, gates) once the movement/combat feel is nailed down.

var rooms: Dictionary = {}      # Vector2i(cell) -> Room
var start_cell: Vector2i = Vector2i.ZERO
var start_room: Room
var exit_room: Room

func generate(rng: RandomNumberGenerator, count: int = 8) -> void:
    rooms.clear()
    var cells: Array = [Vector2i.ZERO]
    var taken := {Vector2i.ZERO: true}

    while cells.size() < count:
        var base: Vector2i = cells[rng.randi_range(0, cells.size() - 1)]
        var dir: Vector2i = Reachability.DIRS[rng.randi_range(0, Reachability.DIRS.size() - 1)]
        var nxt: Vector2i = base + dir
        if taken.has(nxt):
            continue
        taken[nxt] = true
        cells.append(nxt)

    var id := 0
    for c in cells:
        var r := Room.new(id)
        r.depth = int(c.length())                       # cheap depth proxy from the origin
        r.biome = Bestiary.biome_for_depth(r.depth)     # the run's route through the world
        rooms[c] = r
        id += 1

    # Connect every pair of orthogonally adjacent rooms (bidirectional doors).
    for c in rooms.keys():
        for d in Reachability.DIRS:
            var n: Vector2i = c + d
            if rooms.has(n):
                rooms[c].doors[d] = rooms[n]

    start_room = rooms[start_cell]
    start_room.tags.append("start")
    var far := Reachability.farthest(rooms, start_cell)
    exit_room = rooms[far]
    exit_room.tags.append("exit")

    # Hard gate: refuse to hand a broken dungeon to the player.
    assert(Reachability.all_reachable(rooms, start_cell), "generated dungeon is not fully reachable")
