class_name Pickup
extends Node2D
## An item on a pedestal. Walk into it to acquire. Non-blocking; draws its own little icon.

var item_id: String = ""
var player: Player = null
var _t: float = 0.0

func setup(id: String) -> void:
    item_id = id

func _ready() -> void:
    add_to_group("pickups")

func _process(delta: float) -> void:
    _t += delta
    if player == null:
        player = get_tree().get_first_node_in_group("player")
    if player != null and global_position.distance_to(player.global_position) < 10.0:
        if Game.acquire(item_id):
            print("[item] picked up %s (%s)" % [item_id, Items.get_item(item_id).get("name", "?")])
        queue_free()
        return
    queue_redraw()

func _draw() -> void:
    var c: Color = Items.get_item(item_id).get("color", Color(0.95, 0.85, 0.40))
    var bob := sin(_t * 3.0) * 2.0
    draw_rect(Rect2(-5, -5 + bob, 10, 10), c)
    draw_rect(Rect2(-5, -5 + bob, 10, 10), Color(1, 1, 1, 0.6), false, 1.0)
