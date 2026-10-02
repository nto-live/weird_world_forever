class_name Meta
extends RefCounted
## Persistent save: the Attuned unlocks AND the number of dungeons cleared.
## `clears` is what drives the boss ladder — one boss per dungeon, advancing one rung per clear.

const SAVE_PATH := "user://meta.json"

static func _load() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {"attuned": {}, "clears": 0}
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return {"attuned": {}, "clears": 0}
    var txt := f.get_as_text()
    f.close()
    var d = JSON.parse_string(txt)
    if typeof(d) != TYPE_DICTIONARY:
        return {"attuned": {}, "clears": 0}
    if not d.has("attuned"):
        # migrate the old format, where the whole dict was the attuned set
        d = {"attuned": d, "clears": 0}
    return d

static func _save(d: Dictionary) -> void:
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f == null:
        return
    f.store_string(JSON.stringify(d, "\t"))
    f.close()

static func load_attuned() -> Dictionary:
    return _load().get("attuned", {})

static func clears() -> int:
    return int(_load().get("clears", 0))

static func attune(ids: Array) -> Dictionary:
    var d := _load()
    var att: Dictionary = d.get("attuned", {})
    for id in ids:
        att[str(id)] = true
    d["attuned"] = att
    _save(d)
    return att

## Called when a dungeon is solved — advances the boss ladder by one.
static func record_clear() -> void:
    var d := _load()
    d["clears"] = int(d.get("clears", 0)) + 1
    _save(d)

static func reset() -> void:
    _save({"attuned": {}, "clears": 0})
