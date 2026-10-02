extends Node2D
## Bootstraps a run: generate the dungeon, spawn the player, draw the room + its biome, populate
## enemies, drop item pedestals, and — on a clear — attune the run's unlocks and start the next run.

const TILE := 16
const PLAYER_SCENE := preload("res://scenes/Player.tscn")

var dungeon: DungeonGenerator
var current: Room
var player: Player
var enemies_root: Node2D
var items_root: Node2D
var boss: Boss = null
var _cleared: bool = false

func _ready() -> void:
    enemies_root = Node2D.new()
    enemies_root.name = "Enemies"
    add_child(enemies_root)
    items_root = Node2D.new()
    items_root.name = "Items"
    add_child(items_root)

    _new_run()

func _new_run() -> void:
    Game.start_run(0)
    dungeon = DungeonGenerator.new()
    dungeon.generate(Game.rng, 8)
    if player == null:
        player = PLAYER_SCENE.instantiate()
        add_child(player)
    current = dungeon.start_room
    player.room = current
    player.global_position = _room_center()
    _enter_room(current, true)

func _process(_delta: float) -> void:
    _check_transition()
    _check_clear()

func _enter_room(room: Room, is_start: bool) -> void:
    Spawner.clear(enemies_root)
    _clear_items()
    _cleared = false
    boss = null
    var is_boss: bool = room.tags.has("exit")
    Spawner.spawn_room(enemies_root, room, Game.rng, room.depth, is_start, is_boss)
    for c in enemies_root.get_children():
        if c.has_signal("died"):
            c.died.connect(_on_enemy_died)
        if c is Boss:
            boss = c
    if not is_boss and not is_start and Game.rng.randf() < 0.55:
        var id := _pedestal_item()
        if id != "":
            _drop_item(id, _room_center_off(0, 0))
    Game.depth = room.depth
    queue_redraw()

## A boss drops its loot on death; you must claim it to finish the dungeon.
func _on_enemy_died(e) -> void:
    if not (e is Enemy):
        return
    if e.is_boss:
        boss = null
        var dropped: Array = e.loot
        if dropped.is_empty():
            var fb := _reward_item()
            if fb != "":
                dropped = [fb]
        for id in dropped:
            _drop_item(id, e.global_position + Vector2(Game.rng.randf_range(-12, 12), Game.rng.randf_range(-12, 12)))

## A clear = boss room, no enemies left, and the reward claimed (pickups gone).
func _check_clear() -> void:
    if _cleared or current == null:
        return
    if current.tags.has("exit") and enemies_root.get_child_count() == 0 and items_root.get_child_count() == 0:
        _cleared = true
        Game.complete_run()
        _new_run()

func _check_transition() -> void:
    var p := player.global_position
    var dir := Vector2i.ZERO
    if p.x < 0.0:
        dir = Vector2i.LEFT
    elif p.x > Room.W * TILE:
        dir = Vector2i.RIGHT
    elif p.y < 0.0:
        dir = Vector2i.UP
    elif p.y > Room.H * TILE:
        dir = Vector2i.DOWN
    if dir == Vector2i.ZERO or not current.doors.has(dir):
        return
    current = current.doors[dir]
    player.room = current
    match dir:
        Vector2i.LEFT:
            player.global_position = Vector2(Room.W * TILE - 8, p.y)
        Vector2i.RIGHT:
            player.global_position = Vector2(8, p.y)
        Vector2i.UP:
            player.global_position = Vector2(p.x, Room.H * TILE - 8)
        Vector2i.DOWN:
            player.global_position = Vector2(p.x, 8)
    _enter_room(current, false)

# --- item drops -------------------------------------------------------------------
func _unowned_pool(include_passive: bool) -> Array:
    var out: Array = []
    for id in Items.ITEMS.keys():
        if Game.has(id):
            continue
        var k := Items.kind_of(id)
        if k == Items.Kind.ATTACK or k == Items.Kind.UTILITY or (include_passive and k == Items.Kind.PASSIVE):
            out.append(id)
    return out

## The boss reward is always an unlockable attack/utility you don't already have.
func _reward_item() -> String:
    var pool := _unowned_pool(false)
    if pool.is_empty():
        return ""
    return pool[Game.rng.randi_range(0, pool.size() - 1)]

## Pedestals can also carry passives.
func _pedestal_item() -> String:
    var pool := _unowned_pool(true)
    if pool.is_empty():
        return ""
    return pool[Game.rng.randi_range(0, pool.size() - 1)]

func _drop_item(id: String, pos: Vector2) -> void:
    if id == "":
        return
    var pk := Pickup.new()
    pk.setup(id)
    pk.position = pos
    items_root.add_child(pk)

func _clear_items() -> void:
    for c in items_root.get_children():
        c.queue_free()

func _room_center() -> Vector2:
    return Vector2(Room.W * TILE * 0.5, Room.H * TILE * 0.5)

func _room_center_off(dx: float, dy: float) -> Vector2:
    return _room_center() + Vector2(dx, dy)

func _draw() -> void:
    if current == null:
        return
    var b: Dictionary = Bestiary.BIOMES.get(current.biome, {})
    var floor_col: Color = b.get("floor", Color(0.20, 0.18, 0.16))
    var wall_col: Color = b.get("wall", Color(0.10, 0.09, 0.08))
    for y in Room.H:
        for x in Room.W:
            var t: int = current.grid[y][x]
            draw_rect(Rect2(x * TILE, y * TILE, TILE, TILE), wall_col if t == Room.WALL else floor_col)
    for d in current.doors.keys():
        var cell := current.door_cell(d)
        draw_rect(Rect2(cell.x * TILE + 4, cell.y * TILE + 4, TILE - 8, TILE - 8), Color(0.85, 0.5, 0.2))
    if current.tags.has("exit"):
        draw_string(ThemeDB.fallback_font, Vector2(8, 16), "BOSS: " + str(b.get("name", "")),
                    HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 0.6, 0.3))
    if boss != null and is_instance_valid(boss):
        var frac := clampf(float(boss.hp) / float(max(1, boss.max_hp)), 0.0, 1.0)
        draw_rect(Rect2(28, 26, 200, 6), Color(0, 0, 0, 0.6))
        draw_rect(Rect2(28, 26, 200 * frac, 6), Color(0.9, 0.3, 0.3))
        draw_string(ThemeDB.fallback_font, Vector2(28, 22), str(boss.data.get("name", "")),
                    HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1, 0.7, 0.5))

func _unhandled_input(e: InputEvent) -> void:
    if e.is_action_pressed("debug_unlock"):
        Game.debug_unlock_all()
    if e.is_action_pressed("inventory"):
        print("[hud] seed=%d depth=%d hearts=%d biome=%s attuned=%d run_items=%d enemies=%d" %
              [Game.seed_value, Game.depth, Game.hearts, current.biome,
               Game.inventory.attuned.size(), Game.inventory.run_items.size(),
               enemies_root.get_child_count()])
