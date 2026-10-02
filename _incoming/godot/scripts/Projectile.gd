class_name Projectile
extends Node2D
## Minimal ranged attack. Kinds: straight, lob (approximated), laser (fast + lingering).
## Self-manages movement, damage, and lifetime; frees itself.

var room: Room
var target: Player
var vel: Vector2 = Vector2.ZERO
var dmg: int = 2
var color: Color = Color.WHITE
var kind: String = "straight"
var freeze: bool = false
var friendly: bool = false      # true = damages enemies (player shots); false = damages the player

var _life: float = 2.0
var _gravity: float = 0.0

func setup(origin: Vector2, dir: Vector2, speed: float, damage: int, col: Color, k: String, does_freeze: bool) -> void:
    global_position = origin
    vel = dir.normalized() * speed
    dmg = damage
    color = col
    kind = k
    freeze = does_freeze
    match kind:
        "lob":
            _gravity = 260.0
            _life = 1.4
        "laser":
            _life = 0.9
        _:
            _life = 2.0
    z_index = 5

func _process(delta: float) -> void:
    _life -= delta
    if _life <= 0.0:
        queue_free()
        return
    ground(delta)
    var next := global_position + vel * delta
    # straight/laser stop at walls; lob is treated as passing over cover until it lands
    if kind != "lob" and room != null and not room.is_world_walkable(next):
        queue_free()
        return
    global_position = next
    if friendly:
        for e in get_tree().get_nodes_in_group("enemies"):
            if global_position.distance_to(e.global_position) < 10.0:
                e._take_hit(dmg)
                queue_free()
                return
    elif target != null and global_position.distance_to(target.global_position) < 10.0:
        if freeze:
            target.apply_freeze(1.0)
        else:
            target.take_damage(dmg, global_position)
        queue_free()
    queue_redraw()

func ground(delta: float) -> void:
    if kind == "lob":
        vel.y += _gravity * delta

func _draw() -> void:
    if kind == "laser":
        draw_line(Vector2.ZERO, -vel.normalized() * 14.0, color, 3.0)
        draw_circle(Vector2.ZERO, 4.0, color)
    else:
        draw_circle(Vector2.ZERO, 4.0, color)
        if kind == "lob":
            draw_circle(Vector2(0, 10), 2.0, Color(0, 0, 0, 0.4))
