class_name Inventory
extends RefCounted
## What the player has. Two layers:
##   attuned  — PERMANENT (carried over from cleared dungeons)
##   run_items — this run only (lost on death)
## `has()` sees both; `attunable_now()` is what a clear would make permanent.

var attuned: Dictionary = {}
var run_items: Dictionary = {}

func set_attuned(d: Dictionary) -> void:
    attuned = d.duplicate()

func clear_run() -> void:
    run_items.clear()

func acquire(id: String) -> bool:
    if has(id):
        return false
    run_items[id] = true
    return true

func has(id: String) -> bool:
    return attuned.has(id) or run_items.has(id)

func has_verb(verb: String) -> bool:
    for id in Items.ITEMS.keys():
        if Items.verb_of(id) == verb and has(id):
            return true
    return false

## ATTACK + UTILITY items held this run that aren't already attuned — the clear reward.
func attunable_now() -> Array:
    var out: Array = []
    for id in run_items.keys():
        if Items.can_attune(id) and not attuned.has(id):
            out.append(id)
    return out
