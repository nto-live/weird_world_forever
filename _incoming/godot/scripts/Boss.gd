class_name Boss
extends Enemy
## Boss behaviour: a phase machine cycling through telegraphed attack patterns.
## ONE boss per dungeon — the dungeon's exit room holds exactly one, chosen by BossRoster.for_clear().
## Data (phases, loot) comes from BossRoster; patterns are the seven implemented below.

var phases: Array = []
var phase_idx: int = 0
var _pattern_seq: int = 0
var _current: String = ""
var _pstate: String = "idle"
var _pstate_t: float = 0.0
var _act_time: float = 0.5
var _tick: float = 0.0
var _winded: float = 0.0
var _pdir: Vector2 = Vector2.RIGHT

func setup(d: Dictionary, seed_value: int = 0) -> void:
    super.setup(d, seed_value)
    phases = d.get("phases", [])
    use_patterns = true          # Boss drives its own attacks; suppress Enemy's base ranged/ring/summon

func _think(delta: float) -> void:
    if player == null:
        return
    if _winded > 0.0:
        _winded = max(0.0, _winded - delta)
    _apply_phase()
    _pstate_t += delta
    match _pstate:
        "idle":
            if _pstate_t >= 0.9:
                _set_pstate("telegraph")
        "telegraph":
            if _pstate_t >= 0.6:
                _begin_pattern()
                _set_pstate("act")
        "act":
            _tick_pattern(delta)
            if _pstate_t >= _act_time:
                _set_pstate("recover")
        "recover":
            if _pstate_t >= 0.7:
                _set_pstate("idle")

# ---------------------------------------------------------------- phases
func _apply_phase() -> void:
    if phases.is_empty():
        return
    var frac := float(hp) / float(max(1, max_hp))
    var idx := 0
    for i in phases.size():
        if frac <= float(phases[i].get("at", 1.0)):
            idx = i
    if idx != phase_idx:
        phase_idx = idx
        speed = float(phases[phase_idx].get("speed", speed))

func _next_pattern() -> String:
    if phases.is_empty():
        return "stomp"
    var pats: Array = phases[phase_idx].get("patterns", ["stomp"])
    var p: String = pats[_pattern_seq % pats.size()]
    _pattern_seq += 1
    return p

# ---------------------------------------------------------------- patterns
func _begin_pattern() -> void:
    _current = _next_pattern()
    _tick = 0.0
    match _current:
        "breath": _act_time = 1.2
        "volley": _act_time = 1.4
        "laser":  _act_time = 1.0
        "summon": _act_time = 0.8
        "charge": _act_time = 0.9
        _:        _act_time = 0.5
    if _current == "charge":
        _pdir = (player.global_position - global_position).normalized()
    if _current == "stomp":
        _ring_burst(6)
    elif _current == "ring":
        _ring_burst(8)

func _tick_pattern(delta: float) -> void:
    _tick += delta
    match _current:
        "charge":
            _step(_pdir * speed * 1.8 * delta)
        "breath":
            if fmod(_tick, 0.18) < delta:
                _spray_cone(3, 0.5, 150.0, Color(1.0, 0.5, 0.2))
        "volley":
            if fmod(_tick, 0.42) < delta:
                _lob_at_player()
        "laser":
            if fmod(_tick, 0.34) < delta:
                _shoot((player.global_position - global_position).normalized(),
                       {"pspeed": 260.0, "pdmg": dmg / 2, "pcolor": Color(1, 0.3, 0.4), "kind": "laser"})
        "summon":
            _summon_burst()

func _set_pstate(s: String) -> void:
    _pstate = s
    _pstate_t = 0.0
    # The weak window: after a big breath the boss is winded and takes double damage.
    if s == "recover" and _current == "breath":
        _winded = 1.5

func _take_hit(amount: int) -> void:
    var a := amount
    if _winded > 0.0:
        a *= 2
    super._take_hit(a)
    _tint()

# ---------------------------------------------------------------- helpers
func _spray_cone(n: int, arc: float, spd: float, col: Color) -> void:
    var base := (player.global_position - global_position).normalized().angle()
    for i in n:
        var frac := 0.0 if n <= 1 else (float(i) / float(n - 1) - 0.5)
        var a := base + frac * arc
        _shoot(Vector2(cos(a), sin(a)), {"pspeed": spd, "pdmg": dmg, "pcolor": col, "kind": "straight"})

func _ring_burst(n: int) -> void:
    for i in n:
        var a := TAU * float(i) / float(n)
        _shoot(Vector2(cos(a), sin(a)), {"pspeed": 120.0, "pdmg": max(2, dmg / 2), "pcolor": Color(1.0, 0.6, 0.3), "kind": "straight"})

func _lob_at_player() -> void:
    var d := player.global_position - global_position
    _shoot(d.normalized(), {"pspeed": 80.0, "pdmg": max(2, dmg / 2), "pcolor": Color(1.0, 0.6, 0.25), "kind": "lob"})

func _summon_burst() -> void:
    if not data.has("summon_id"):
        return
    var minion := Bestiary.find(room.biome, str(data["summon_id"]))
    if minion.is_empty():
        return
    for i in int(data.get("summon_count", 2)):
        var e := (load("res://scenes/Enemy.tscn") as PackedScene).instantiate() as Enemy
        e.setup(minion, rng.randi())
        e.room = room
        e.position = global_position + Vector2(rng.randf_range(-28, 28), rng.randf_range(-28, 28))
        if get_parent() != null:
            get_parent().add_child(e)
