class_name Reachability
extends RefCounted
## Graph checks over the dungeon. The gate: a generated run must be completable before it starts.

const DIRS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

## BFS over the room graph; returns { cell: distance } from `from`.
static func bfs(rooms: Dictionary, from: Vector2i) -> Dictionary:
    var dist := {from: 0}
    var q: Array = [from]
    while not q.is_empty():
        var c: Vector2i = q.pop_front()
        for d in DIRS:
            var n: Vector2i = c + d
            if rooms.has(n) and not dist.has(n):
                dist[n] = dist[c] + 1
                q.append(n)
    return dist

## Every generated room must be reachable from the start.
static func all_reachable(rooms: Dictionary, start: Vector2i) -> bool:
    return bfs(rooms, start).size() == rooms.size()

## Farthest room from `from` (used to place the exit/boss).
static func farthest(rooms: Dictionary, from: Vector2i) -> Vector2i:
    var dist := bfs(rooms, from)
    var best := from
    var best_d := -1
    for k in dist.keys():
        if dist[k] > best_d:
            best_d = dist[k]
            best = k
    return best

## gate tag -> the item id that opens it.
const GATE_ITEMS := {
    "cracked": "bombs", "water": "flippers", "gap": "hookshot",
    "web": "fire_rod", "boulder": "titans_mitt", "peg": "hammer",
}

## Whether `exit` is reachable from `start` given the items in `have_ids`.
## A gated room may not be entered unless its opener is held. (The generator must place each
## gate's opener BEFORE the gate; this is the check that catches a broken dungeon.)
static func completable(rooms: Dictionary, start: Vector2i, exit: Vector2i, have_ids: Array) -> bool:
    var have := {}
    for id in have_ids:
        have[id] = true
    var seen := {start: true}
    var q: Array = [start]
    while not q.is_empty():
        var c: Vector2i = q.pop_front()
        for d in DIRS:
            var n: Vector2i = c + d
            if not rooms.has(n) or seen.has(n):
                continue
            var gate: String = rooms[n].gate
            if gate != "" and not have.has(GATE_ITEMS.get(gate, "")):
                continue
            seen[n] = true
            q.append(n)
    return seen.has(exit)
