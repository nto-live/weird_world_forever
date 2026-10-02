class_name Enemy
extends CharacterBody2D
## Base enemy. Behaviour is chosen by archetype (Bestiary.Arch); every enemy also shares the
## LTTP contract: contact damage, a readable tell, knockback, and i-frames.
##
## Special tags handled here: armored, splits, revives_once, shatters_on_death, on_death_poison.

signal died(enemy)

var data: Dictionary = {}
var arch: int = Bestiary.Arch.PATROL
var hp: int = 2
var dmg: int = 2
var speed: float = 40.0
var aggro: float = 140.0
var is_boss: bool = false
var room: Room = null
var player: Player = null

var rng := RandomNumberGenerator.new()

var _iframes: float = 0.0
var _dir: Vector2 = Vector2.RIGHT
var _t: float = 0.0
var _repath: float = 0.0
var _fire_t: float = 0.0
var _ring_t: float = 0.0
var _summon_t: float = 0.0
var _state: String = "idle"     # charger sub-state
var _state_t: float = 0.0
var _charge_dir: Vector2 = Vector2.RIGHT
var _phased: bool = false
var _phase_t: float = 0.0
var _hop_t: float = 0.0
var _revived: bool = false
var _split: bool = false
var _knock: Vector2 = Vector2.ZERO
var _shielded: bool = false

var max_hp: int = 1              # for phase math + the boss HP bar
var loot: Array = []             # item ids a boss drops on death
var use_patterns: bool = false   # Boss subclass drives its own attacks

@onready var body: Polygon2D = $Body

func setup(d: Dictionary, seed_value: int = 0) -> void:
    data = d
    arch = d.get("arch", Bestiary.Arch.PATROL)
    hp = d.get("hp", 2)
    dmg = d.get("dmg", 2)
    speed = d.get("speed", 40.0)
    aggro = d.get("aggro", 140.0)
    is_boss = d.get("boss", false)
    max_hp = hp
    loot = d.get("loot", [])
    rng.seed = seed_value

func _ready() -> void:
    add_to_group("enemies")
    if body != null:
        body.color = data.get("color", Color.WHITE)
        if is_boss:
            body.scale = Vector2(1.7, 1.7)
    _dir = Reachability.DIRS[rng.randi_range(0, Reachability.DIRS.size() - 1)]
    if is_boss and data.get("shield", false):
        _shielded = true

func _physics_process(delta: float) -> void:
    _t += delta
    if _iframes > 0.0:
        _iframes = max(0.0, _iframes - delta)
    if player == null:
        player = get_tree().get_first_node_in_group("player")

    _think(delta)
    if not use_patterns:
        _maybe_fire(delta)
        _maybe_ring(delta)
        _maybe_summon(delta)
    _contact_damage()
    _check_player_hit()
    _tint()

# ---------------------------------------------------------------- behaviour
func _think(delta: float) -> void:
    if player == null:
        return

    if is_boss and data.get("shield", false):
        _shield_cycle(delta)
        if _shielded:
            return

    match arch:
        Bestiary.Arch.PATROL:  _patrol(delta)
        Bestiary.Arch.CHASE:   _chase(delta, false)
        Bestiary.Arch.SWARM:   _chase(delta, true)
        Bestiary.Arch.CHARGER: _charger(delta)
        Bestiary.Arch.TURRET:  pass                      # stationary
        Bestiary.Arch.LOBBER:  pass                      # stationary
        Bestiary.Arch.JUMPER:  _jumper(delta)
        Bestiary.Arch.PHASE:   _phase_blink(delta)
        Bestiary.Arch.SUMMONER: pass                     # stationary, summons

func _patrol(delta: float) -> void:
    _repath -= delta
    var want := global_position + _dir * speed * delta
    if _repath <= 0.0 or (room != null and not room.is_world_walkable(want)):
        _dir = Reachability.DIRS[rng.randi_range(0, Reachability.DIRS.size() - 1)]
        _repath = rng.randf_range(0.8, 2.4)
    _step(_dir * speed * delta)

func _chase(delta: float, swarm: bool) -> void:
    var to := player.global_position - global_position
    if to.length() < aggro:
        var wobble := Vector2(sin(_t * 6.0), cos(_t * 6.0)) * (8.0 if swarm else 0.0)
        _step((to.normalized() * speed * delta) + wobble * delta)
    else:
        _patrol(delta)

func _charger(delta: float) -> void:
    _state_t += delta
    match _state:
        "idle":
            var to := player.global_position - global_position
            if to.length() < aggro * 1.6 and to.length() > 20.0:
                _charge_dir = to.normalized()
                _set_state("windup")
            else:
                _patrol(delta)
        "windup":
            if _state_t >= 0.5:                       # the tell
                _set_state("charge")
        "charge":
            _step(_charge_dir * speed * 1.7 * delta)
            var ahead := global_position + _charge_dir * 10.0
            if _state_t >= 0.85 or (room != null and not room.is_world_walkable(ahead)):
                _set_state("recover")
        "recover":
            if _state_t >= 0.4:
                _set_state("idle")

func _jumper(delta: float) -> void:
    _hop_t -= delta
    if _hop_t <= 0.0:
        var to := player.global_position - global_position
        _dir = to.normalized() if to.length() > 1.0 else _dir
        _hop_t = rng.randf_range(0.6, 1.0)
        _apply_move(_dir * speed * 0.35)               # a short lunge
    else:
        _step(_dir * speed * delta * 0.2)

func _phase_blink(delta: float) -> void:
    _phase_t -= delta
    if _phase_t <= 0.0:
        _phased = not _phased
        _phase_t = rng.randf_range(0.7, 1.3)
        if _phased:
            global_position = _random_room_pos()
    if not _phased:
        var to := player.global_position - global_position
        if to.length() < aggro:
            _step(to.normalized() * speed * delta)

func _shield_cycle(delta: float) -> void:
    _state_t += delta
    if _state_t >= float(data.get("summon_interval", 3.5)):
        _shielded = false                            # exposed window -> summon happens in _maybe_summon
    elif _shielded == false and _state_t >= float(data.get("summon_interval", 3.5)) + 1.5:
        _shielded = true
        _state_t = 0.0

# ---------------------------------------------------------------- shared actions
func _maybe_fire(delta: float) -> void:
    if not data.has("ranged") or player == null:
        return
    var r: Dictionary = data["ranged"]
    if global_position.distance_to(player.global_position) > aggro:
        return
    _fire_t -= delta
    if _fire_t > 0.0:
        return
    _fire_t = float(r.get("interval", 2.0))
    var dir := (player.global_position - global_position).normalized()
    if str(r.get("kind", "straight")) == "spread":
        var n := int(r.get("count", 5))
        var arc := float(r.get("spread", 0.5))
        var base := dir.angle()
        for i in n:
            var frac := 0.0 if n <= 1 else (float(i) / float(n - 1) - 0.5)
            var a := base + frac * arc
            _shoot(Vector2(cos(a), sin(a)), r)
    else:
        _shoot(dir, r)

func _shoot(dir: Vector2, r: Dictionary) -> void:
    var proj := Projectile.new()
    proj.setup(global_position, dir, float(r.get("pspeed", 100.0)), int(r.get("pdmg", 2)),
               r.get("pcolor", Color.WHITE), str(r.get("kind", "straight")), bool(r.get("freeze", false)))
    proj.room = room
    proj.target = player
    var host := get_parent()
    if host != null:
        host.add_child(proj)

## Radial "bass drop": fires a ring of shots in all directions (raver techno punks).
func _maybe_ring(delta: float) -> void:
    if not data.has("ring") or player == null:
        return
    var r: Dictionary = data["ring"]
    if global_position.distance_to(player.global_position) > aggro * 1.2:
        return
    _ring_t -= delta
    if _ring_t > 0.0:
        return
    _ring_t = float(r.get("interval", 2.5))
    var count := int(r.get("count", 8))
    for i in count:
        var a := TAU * float(i) / float(count)
        var proj := Projectile.new()
        proj.setup(global_position, Vector2(cos(a), sin(a)), float(r.get("speed", 110.0)),
                   int(r.get("dmg", 2)), r.get("color", Color(0.5, 1.0, 0.5)), "straight", false)
        proj.room = room
        proj.target = player
        var host := get_parent()
        if host != null:
            host.add_child(proj)

func _maybe_summon(delta: float) -> void:
    if not data.has("summon_id") or player == null:
        return
    if is_boss and _shielded:
        return
    _summon_t -= delta
    if _summon_t > 0.0:
        return
    _summon_t = float(data.get("summon_interval", 4.0))
    var count := int(data.get("summon_count", 1))
    var minion := Bestiary.find(room.biome, str(data["summon_id"]))
    if minion.is_empty():
        return
    for i in count:
        var e := (load("res://scenes/Enemy.tscn") as PackedScene).instantiate() as Enemy
        e.setup(minion, rng.randi())
        e.room = room
        e.position = global_position + Vector2(rng.randf_range(-28, 28), rng.randf_range(-28, 28))
        var host := get_parent()
        if host != null:
            host.add_child(e)

func _contact_damage() -> void:
    if player == null or _phased:
        return
    if global_position.distance_to(player.global_position) < 12.0 and dmg > 0:
        player.take_damage(dmg, global_position)

func _check_player_hit() -> void:
    if player == null or _phased or _iframes > 0.0:
        return
    if is_boss and _shielded:
        return
    if player.is_attacking() and player.attack_box().has_point(global_position):
        _take_hit(player.attack_damage())

func _take_hit(amount: int) -> void:
    hp -= amount
    _iframes = 0.35
    _knock = (global_position - player.global_position).normalized() * 160.0
    _apply_move(_knock * 0.05)
    if hp <= 0:
        _die()

func _die() -> void:
    var tags: Array = data.get("tags", [])
    if "revives_once" in tags and not _revived:
        _revived = true
        hp = 1
        return
    if "splits" in tags and not _split:
        _split_spawn()
    died.emit(self)
    queue_free()

func _split_spawn() -> void:
    var child := data.duplicate()
    child["hp"] = max(1, hp)
    child["tags"] = []
    child["scale"] = 0.7
    for i in 2:
        var e := (load("res://scenes/Enemy.tscn") as PackedScene).instantiate() as Enemy
        e.setup(child, rng.randi())
        e.room = room
        e.position = global_position + Vector2(rng.randf_range(-14, 14), rng.randf_range(-14, 14))
        var host := get_parent()
        if host != null:
            host.add_child(e)

# ---------------------------------------------------------------- helpers
func _set_state(s: String) -> void:
    _state = s
    _state_t = 0.0

## Wall-aware step (axis-separated so enemies slide along walls).
func _step(motion: Vector2) -> void:
    if room == null:
        return
    var target := global_position + motion
    if room.is_world_walkable(target):
        global_position = target
        return
    var tx := global_position + Vector2(motion.x, 0.0)
    if room.is_world_walkable(tx):
        global_position.x = tx.x
    var ty := global_position + Vector2(0.0, motion.y)
    if room.is_world_walkable(ty):
        global_position.y = ty.y

## Ignore walls (used for one-frame knockback nudges / teleports).
func _apply_move(motion: Vector2) -> void:
    global_position += motion

func _random_room_pos() -> Vector2:
    if room == null:
        return global_position
    for i in 12:
        var x := rng.randi_range(1, Room.W - 2)
        var y := rng.randi_range(1, Room.H - 2)
        if room.grid[y][x] != Room.WALL:
            return Vector2(x * Room.TILE + Room.TILE / 2.0, y * Room.TILE + Room.TILE / 2.0)
    return global_position

func _tint() -> void:
    if body == null:
        return
    if _phased:
        body.modulate.a = 0.35
    elif _iframes > 0.0:
        body.modulate.a = 0.5
    elif _state == "windup":
        body.modulate = Color(1.6, 1.2, 1.2)          # telegraph flash
    else:
        body.modulate = Color.WHITE
