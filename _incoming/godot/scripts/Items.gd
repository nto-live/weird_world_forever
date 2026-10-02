class_name Items
extends RefCounted
## Item + power-up catalogue. Data-driven; see 02-items-and-powerups.md.
##
## kind: ATTACK (an unlockable verb) / UTILITY (movement+world) / PASSIVE (run-scoped numbers)
##       / CONSUMABLE.
## attune: true  => if you CLEAR the dungeon carrying it, it becomes permanent.
## verb  : the attack/ability this grants (checked by Game.attack_unlocked / Player).
## gate  : the world obstacle this item opens (used by Reachability).

enum Kind { ATTACK, UTILITY, PASSIVE, CONSUMABLE }

const ITEMS := {
    # ---------------- ATTACK UNLOCKS ----------------
    "sword":          {"name": "Fighter's Sword", "kind": Kind.ATTACK, "verb": "swing", "mp": 0, "attune": false},
    "spin_tome":      {"name": "Knights' Crest", "kind": Kind.ATTACK, "verb": "spin", "mp": 0, "attune": true,
                       "desc": "Unlocks the charged Spin Attack (hold attack ~2 s)."},
    "master_sword":   {"name": "Master Sword", "kind": Kind.ATTACK, "verb": "beam", "mp": 0, "tier": 2, "attune": true,
                       "desc": "Sword beams at full health; x2 damage."},
    "bow":            {"name": "Bow & Arrows", "kind": Kind.ATTACK, "verb": "arrow", "mp": 0, "ammo": true, "attune": true},
    "boomerang":      {"name": "Boomerang", "kind": Kind.ATTACK, "verb": "boomerang", "mp": 0, "attune": true},
    "bombs":          {"name": "Bombs", "kind": Kind.ATTACK, "verb": "bomb", "mp": 0, "ammo": true, "gate": "cracked", "attune": true},
    "hookshot":       {"name": "Hookshot", "kind": Kind.ATTACK, "verb": "grapple", "mp": 0, "gate": "gap", "attune": true},
    "hammer":         {"name": "Magic Hammer", "kind": Kind.ATTACK, "verb": "smash", "mp": 0, "gate": "peg", "attune": true},
    "fire_rod":       {"name": "Fire Rod", "kind": Kind.ATTACK, "verb": "fire", "mp": 8, "gate": "web", "attune": true},
    "ice_rod":        {"name": "Ice Rod", "kind": Kind.ATTACK, "verb": "ice", "mp": 8, "gate": "water", "attune": true},
    "somaria":        {"name": "Cane of Somaria", "kind": Kind.ATTACK, "verb": "block", "mp": 8, "attune": true},
    "byrna":          {"name": "Cane of Byrna", "kind": Kind.ATTACK, "verb": "barrier", "mp": 16, "attune": true},
    "laser_gauntlet": {"name": "Laser Gauntlet", "kind": Kind.ATTACK, "verb": "laser", "mp": 8, "biome": "arcanum", "attune": true},
    "arcane_bolt":    {"name": "Arcane Bolt", "kind": Kind.ATTACK, "verb": "bolt", "mp": 6, "biome": "arcanum", "attune": true},
    "servitor_charm": {"name": "Servitor Charm", "kind": Kind.ATTACK, "verb": "command", "mp": 12, "biome": "arcanum", "attune": true},

    # ---------------- UTILITY UNLOCKS ----------------
    "pegasus_boots":  {"name": "Pegasus Boots", "kind": Kind.UTILITY, "verb": "dash", "attune": true},
    "flippers":       {"name": "Zora's Flippers", "kind": Kind.UTILITY, "verb": "swim", "gate": "water", "attune": true},
    "power_glove":    {"name": "Power Glove", "kind": Kind.UTILITY, "verb": "lift", "attune": true},
    "titans_mitt":    {"name": "Titan's Mitt", "kind": Kind.UTILITY, "verb": "lift_heavy", "gate": "boulder", "attune": true},
    "magic_cape":     {"name": "Magic Cape", "kind": Kind.UTILITY, "verb": "vanish", "attune": true},
    "magic_mirror":   {"name": "Magic Mirror", "kind": Kind.UTILITY, "verb": "warp", "attune": true},

    # ---------------- PASSIVE (run-scoped) ----------------
    "tempered_sword": {"name": "Tempered Sword", "kind": Kind.PASSIVE, "tier": 3, "attune": false},
    "golden_sword":   {"name": "Golden Sword", "kind": Kind.PASSIVE, "tier": 4, "attune": false},
    "red_shield":     {"name": "Red Shield", "kind": Kind.PASSIVE, "attune": false},
    "mirror_shield":  {"name": "Mirror Shield", "kind": Kind.PASSIVE, "attune": false},
    "blue_mail":      {"name": "Blue Mail", "kind": Kind.PASSIVE, "reduction": 0.5, "attune": false},
    "red_mail":       {"name": "Red Mail", "kind": Kind.PASSIVE, "reduction": 0.25, "attune": false},
    "heart_container":{"name": "Heart Container", "kind": Kind.PASSIVE, "hearts": 1, "attune": false},
    "magic_upgrade":  {"name": "Magic Upgrade", "kind": Kind.PASSIVE, "mp": 8, "attune": false},
    "bottle":         {"name": "Bottle", "kind": Kind.PASSIVE, "attune": false},

    # ---------------- CONSUMABLE ----------------
    "potion_red":     {"name": "Red Potion", "kind": Kind.CONSUMABLE, "attune": false},
    "potion_green":   {"name": "Green Potion", "kind": Kind.CONSUMABLE, "attune": false},
    "fairy":          {"name": "Fairy", "kind": Kind.CONSUMABLE, "attune": false},
    "arrows":         {"name": "Arrows", "kind": Kind.CONSUMABLE, "attune": false},
    "bomb_ammo":      {"name": "Bombs", "kind": Kind.CONSUMABLE, "attune": false},
}

## The only attack you start with. Everything else is an unlock.
const STARTING := ["sword"]

static func get_item(id: String) -> Dictionary:
    return ITEMS.get(id, {})

static func is_attack(id: String) -> bool:
    return int(get_item(id).get("kind", -1)) == Kind.ATTACK

static func can_attune(id: String) -> bool:
    return bool(get_item(id).get("attune", false))

static func kind_of(id: String) -> int:
    return int(get_item(id).get("kind", -1))

static func verb_of(id: String) -> String:
    return str(get_item(id).get("verb", ""))

static func attack_id_for_verb(verb: String) -> String:
    for id in ITEMS.keys():
        if is_attack(id) and verb_of(id) == verb:
            return id
    return ""

## Items eligible for a room pedestal (attacks + utilities only; no passives/consumables).
static func pedestal_pool() -> Array:
    var out: Array = []
    for id in ITEMS.keys():
        if kind_of(id) in [Kind.ATTACK, Kind.UTILITY]:
            out.append(id)
    return out
