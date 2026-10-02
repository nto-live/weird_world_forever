class_name Spawner
extends RefCounted
## Populates a room with enemies drawn from its biome, wired to the run's seeded RNG.
## Rules from 01-bestiary.md: biome by depth, one SUMMONER max per room, boss in the exit room,
## and (depth >= 5) a rare "corrupted elite" leaking a techno enemy into any biome.

const ENEMY_SCENE := preload("res://scenes/Enemy.tscn")
const BOSS_SCENE := preload("res://scenes/Boss.tscn")

const ELITE_DEPTH := 5
const ELITE_CHANCE := 0.15

static func clear(container: Node) -> void:
    for c in container.get_children():
        c.queue_free()

static func spawn_room(container: Node, room: Room, rng: RandomNumberGenerator, depth: int,
                       is_start: bool, is_boss: bool) -> void:
    if is_start:
        return

    if is_boss:
        # ONE boss per dungeon. The ladder advances by cleared count: dungeon #1 = the dragon.
        var boss := BossRoster.for_clear(Meta.clears())
        var b := BOSS_SCENE.instantiate() as Boss
        b.setup(boss, rng.randi())
        b.room = room
        b.position = _random_pos(room, rng)
        container.add_child(b)
        return

    var count := clampi(2 + depth / 2, 1, 6)
    var used_summoner := false
    for i in count:
        var e := _pick(room.biome, rng, depth, used_summoner)
        if e.is_empty():
            continue
        if int(e.get("arch", -1)) == Bestiary.Arch.SUMMONER:
            used_summoner = true
        _spawn(container, room, e, _random_pos(room, rng), rng)

static func _pick(biome: String, rng: RandomNumberGenerator, depth: int, used_summoner: bool) -> Dictionary:
    # Rare global weirdos (e.g. the Mad Hermit) can turn up anywhere, at any depth.
    if rng.randf() < 0.06:
        return Bestiary.RARE[rng.randi_range(0, Bestiary.RARE.size() - 1)]

    # Corrupted elite leak: techno enemies can appear anywhere once you're deep enough.
    if depth >= ELITE_DEPTH and rng.randf() < ELITE_CHANCE:
        var leak := Bestiary.find("arcanum", "priest" if rng.randf() < 0.5 else "warthog")
        if not leak.is_empty():
            return leak

    var pool: Array = Bestiary.enemies_for(biome).duplicate()
    pool.append_array(Bestiary.GLOBAL)
    # Summoners are a once-per-room threat and never in the first two depths.
    pool = pool.filter(func(e): return not (int(e.get("arch", -1)) == Bestiary.Arch.SUMMONER and (used_summoner or depth < 2)))
    if pool.is_empty():
        return {}
    return pool[rng.randi_range(0, pool.size() - 1)]

static func _spawn(container: Node, room: Room, data: Dictionary, pos: Vector2, rng: RandomNumberGenerator) -> void:
    var e := ENEMY_SCENE.instantiate() as Enemy
    e.setup(data, rng.randi())
    e.room = room
    e.position = pos
    container.add_child(e)

static func _random_pos(room: Room, rng: RandomNumberGenerator) -> Vector2:
    for i in 20:
        var x := rng.randi_range(1, Room.W - 2)
        var y := rng.randi_range(1, Room.H - 2)
        if room.grid[y][x] != Room.WALL:
            return Vector2(x * Room.TILE + Room.TILE / 2.0, y * Room.TILE + Room.TILE / 2.0)
    return Vector2(Room.W * Room.TILE * 0.5, Room.H * Room.TILE * 0.5)
