class_name Player
extends CharacterBody2D
## LTTP-style player: a small state machine + 8-direction tile-grid movement + contact-damage feel
## (knockback + i-frames + passive shield). Movement is checked against the current Room directly,
## so no physics bodies are needed for a generated grid.

enum State { IDLE, WALK, CHARGE, ATTACK, SPIN, HURT }

var state: int = State.IDLE
var facing: Vector2 = Vector2.DOWN
var room: Room = null

var _state_time: float = 0.0
var _iframes: float = 0.0
var _knock: Vector2 = Vector2.ZERO
var _frozen: float = 0.0

@onready var body: Polygon2D = $Body

func _ready() -> void:
    add_to_group("player")

func _physics_process(delta: float) -> void:
    _tick_iframes(delta)
    if _frozen > 0.0:
        _frozen = max(0.0, _frozen - delta)
        return
    _state_time += delta

    match state:
        State.HURT:
            _move(_knock * delta)
            if _state_time >= Feel.HURT_STUN:
                _set_state(State.IDLE)
        State.ATTACK:
            if _state_time >= Feel.SWING_TIME:
                _set_state(State.IDLE)
        State.SPIN:
            if _state_time >= Feel.SPIN_DURATION:
                _set_state(State.IDLE)
        State.CHARGE:
            _walk(delta)                        # you can still move while charging
            if not Input.is_action_pressed("attack"):
                if Game.attack_unlocked("spin") and _state_time >= Feel.SPIN_CHARGE_TIME:
                    _set_state(State.SPIN)      # held ~2 s AND the Knights' Crest is known
                else:
                    _set_state(State.ATTACK)    # released early, or no Crest yet
        _:
            _handle_input(delta)

func _handle_input(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        _set_state(State.CHARGE)
        return
    if Input.is_action_just_pressed("interact"):
        _interact()
    _walk(delta)

func _walk(delta: float) -> void:
    var dir := _input_dir()
    if dir == Vector2.ZERO:
        if state == State.WALK:
            _set_state(State.IDLE)
        return
    facing = _snap_facing(dir)
    if state == State.IDLE:
        _set_state(State.WALK)
    _move(dir * Feel.WALK_SPEED * delta)

## Reads the 8-direction input. Normalizes unless we deliberately keep LTTP's faster diagonals.
func _input_dir() -> Vector2:
    var dir := Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
    if dir == Vector2.ZERO:
        return dir
    if not Feel.DIAGONAL_IS_FASTER:
        dir = dir.normalized()
    return dir

## Attack/sprites use one of 4 cardinal facings even when moving diagonally.
func _snap_facing(dir: Vector2) -> Vector2:
    if absf(dir.x) > absf(dir.y):
        return Vector2(signf(dir.x), 0.0)
    return Vector2(0.0, signf(dir.y))

## Move with per-axis wall sliding against the room's tile grid; edges are handled by Main.
func _move(motion: Vector2) -> void:
    if room == null:
        global_position += motion
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

func _set_state(s: int) -> void:
    var entering_attack := (s == State.ATTACK and state != State.ATTACK)
    state = s
    _state_time = 0.0
    if entering_attack:
        _maybe_fire_beam()

## Sword beam: only with the Master Sword (or better) AND at full health.
func _maybe_fire_beam() -> void:
    if not Game.has("master_sword"):
        return
    if Game.hearts < Feel.MAX_HEARTS * Feel.DAMAGE_UNIT_PER_HEART:
        return
    var proj := Projectile.new()
    proj.setup(global_position, facing, 220.0, 1, Color(0.85, 0.9, 1.0), "straight", false)
    proj.room = room
    proj.target = null
    proj.friendly = true
    get_parent().add_child(proj)

func _tick_iframes(delta: float) -> void:
    if _iframes > 0.0:
        _iframes = max(0.0, _iframes - delta)
        body.modulate.a = 0.35 if int(_iframes * 20.0) % 2 == 0 else 1.0
    else:
        body.modulate.a = 1.0

# --- Damage API: enemies / hazards call this -------------------------------------
func take_damage(hp: int, from_pos: Vector2) -> void:
    if _iframes > 0.0:
        return
    if _is_blocked(from_pos):
        return
    Game.damage_player(hp)
    _iframes = Feel.IFRAME_TIME
    _knock = (global_position - from_pos).normalized() * Feel.KNOCKBACK_SPEED
    _set_state(State.HURT)

## Passive shield: blocked if the source is roughly in the direction we face.
func _is_blocked(from_pos: Vector2) -> bool:
    var to := (from_pos - global_position).normalized()
    return to.dot(facing) > Feel.BLOCK_DOT

# --- Interaction (LTTP "A"). Context-resolved; stubbed for now. -------------------
func _interact() -> void:
    print("[interact] STUB — resolve by context (lift/throw/pull/push, talk, chest, swim, dash)")
    # TODO: query the tile/entity in front of `facing` and dispatch to the right verb.

## The attack footprint in front of the player; enemies test against this.
func attack_box() -> Rect2:
    var size := Vector2(Feel.SWORD_WIDTH, Feel.SWORD_WIDTH)
    if state == State.SPIN:
        size = Vector2(Feel.TILE * 2, Feel.TILE * 2)
    var center := global_position + facing * (Feel.SWORD_REACH * 0.5)
    return Rect2(center - size * 0.5, size)

# --- Queries used by enemies ------------------------------------------------------
func is_attacking() -> bool:
    return state == State.ATTACK or state == State.SPIN

func attack_damage() -> int:
    return 2 if state == State.SPIN else 1

## Ice/control effect (e.g. Ice Basilisk gaze). I-frames do NOT protect against control effects.
func apply_freeze(seconds: float) -> void:
    _frozen = max(_frozen, seconds)
