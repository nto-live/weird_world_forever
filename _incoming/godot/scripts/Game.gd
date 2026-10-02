extends Node
## Autoload singleton: seeded RNG, run state, the inventory, and the Attunement save.
##
## Attacks are UNLOCKS: you start with only `sword`; everything else is found. Clear the dungeon
## carrying an ATTACK/UTILITY item and it becomes Attuned (permanent). See 02-items-and-powerups.md.

signal run_started(seed_value: int)
signal run_ended(won: bool)
signal hearts_changed(hearts: int)
signal item_acquired(id: String)

var seed_value: int = 0
var rng := RandomNumberGenerator.new()
var depth: int = 0
var hearts: int = 0
var inventory := Inventory.new()

func _ready() -> void:
    _setup_input_map()
    inventory.set_attuned(Meta.load_attuned())
    start_run(0)

func start_run(s: int = 0) -> void:
    seed_value = s if s != 0 else randi()
    rng.seed = seed_value
    depth = 0
    hearts = Feel.MAX_HEARTS * Feel.DAMAGE_UNIT_PER_HEART
    inventory.clear_run()                       # run-scoped finds are lost; attuned stays
    for id in Items.STARTING:
        inventory.run_items[id] = true
    run_started.emit(seed_value)
    print("[run] seed=%d hearts=%d attuned=%d" % [seed_value, hearts, inventory.attuned.size()])

# --- inventory API used across the game ---
func has(id: String) -> bool:
    return inventory.has(id)

func acquire(id: String) -> bool:
    if not inventory.acquire(id):
        return false
    if id == "heart_container":
        hearts += Feel.DAMAGE_UNIT_PER_HEART
        hearts_changed.emit(hearts)
    item_acquired.emit(id)
    return true

## Is an attack verb unlocked? (spin, beam, arrow, bomb, ...) — see Items.gd
func attack_unlocked(verb: String) -> bool:
    return inventory.has_verb(verb)

## Debug sandbox (F1): unlock every item for THIS run. Never persists / never Attunes.
func debug_unlock_all() -> void:
    for id in Items.ITEMS.keys():
        inventory.run_items[id] = true
    print("[debug] all items unlocked for this run")

# --- run lifecycle ---
func damage_player(hp: int) -> void:
    hearts = max(0, hearts - hp)
    hearts_changed.emit(hearts)
    if hearts <= 0:
        end_run(false)

## Reaching the end alive: attune everything carryable, then end the run as a win.
func complete_run() -> void:
    var gained := inventory.attunable_now()
    if not gained.is_empty():
        inventory.attuned = Meta.attune(gained)
    Meta.record_clear()                          # advances the boss ladder one rung
    print("[clear] dungeon solved — attuned this run: %s | clears=%d" % [str(gained), Meta.clears()])
    end_run(true)

func end_run(won: bool) -> void:
    run_ended.emit(won)
    print("[run] ended, won=%s seed=%d" % [won, seed_value])

# --- input map, defined in code so the project has no fragile input section ---
func _setup_input_map() -> void:
    _add_action("move_up",    [KEY_W, KEY_UP])
    _add_action("move_down",  [KEY_S, KEY_DOWN])
    _add_action("move_left",  [KEY_A, KEY_LEFT])
    _add_action("move_right", [KEY_D, KEY_RIGHT])
    _add_action("attack",     [KEY_J, KEY_Z])       # LTTP "B"  — sword
    _add_action("interact",   [KEY_K, KEY_X])       # LTTP "A"  — lift/throw/pull/talk/dash
    _add_action("item",       [KEY_L, KEY_C])       # LTTP "Y"  — use equipped item
    _add_action("map",        [KEY_M, KEY_TAB])     # LTTP "X"  — map
    _add_action("inventory",  [KEY_I, KEY_ENTER])   # LTTP "Start" — pause/inventory
    _add_action("debug_unlock", [KEY_F1])           # sandbox: unlock all items this run

func _add_action(action_name: StringName, keys: Array) -> void:
    if not InputMap.has_action(action_name):
        InputMap.add_action(action_name)
    for k in keys:
        var ev := InputEventKey.new()
        ev.physical_keycode = k
        InputMap.action_add_event(action_name, ev)
