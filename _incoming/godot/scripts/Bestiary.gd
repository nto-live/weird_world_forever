class_name Bestiary
extends RefCounted
## Data-driven enemy + biome tables. See 01-bestiary.md for the flavor and design reasoning.
##
## Conventions (from the doc):
##   hp  = number of base sword hits to kill (spin counts as 2)
##   dmg = damage units, where 8 units = 1 heart (LTTP's own table)
##   speed = px/s, tuned around the player WALK_SPEED (96)

enum Arch { PATROL, CHASE, CHARGER, TURRET, LOBBER, JUMPER, SWARM, PHASE, SUMMONER }

## The route a run takes through the world: shallow biomes first, techno last.
const BIOME_ORDER := ["crypts", "warrens", "thornwild", "emberdeep", "glacier", "sunken", "arcanum"]

const BIOMES := {
    "crypts": {
        "name": "Hollow Crypts",
        "floor": Color(0.16, 0.15, 0.14), "wall": Color(0.08, 0.08, 0.09),
        "enemies": [
            {"id": "shambler",  "name": "Rotting Shambler", "arch": Arch.PATROL,  "hp": 2, "dmg": 4, "speed": 26.0, "color": Color(0.45, 0.55, 0.34), "tags": ["undead"]},
            {"id": "bloater",   "name": "Bloater",          "arch": Arch.PATROL,  "hp": 3, "dmg": 4, "speed": 20.0, "color": Color(0.52, 0.60, 0.28), "tags": ["undead", "on_death_poison"]},
            {"id": "ghoul",     "name": "Crypt Ghoul",      "arch": Arch.CHASE,   "hp": 3, "dmg": 4, "speed": 62.0, "color": Color(0.60, 0.66, 0.52), "tags": ["undead"]},
            {"id": "rattler",   "name": "Bone Rattler",     "arch": Arch.JUMPER,  "hp": 2, "dmg": 4, "speed": 54.0, "color": Color(0.85, 0.82, 0.72), "tags": ["undead"]},
            {"id": "warden",    "name": "Grave Warden",     "arch": Arch.CHARGER, "hp": 5, "dmg": 8, "speed": 78.0, "color": Color(0.38, 0.42, 0.50), "tags": ["undead", "armored"]},
            {"id": "wraith",    "name": "Choir Wraith",     "arch": Arch.PHASE,   "hp": 3, "dmg": 4, "speed": 40.0, "color": Color(0.55, 0.70, 0.78), "tags": ["undead"]},
        ],
        "boss": {"id": "grave_sovereign", "name": "The Grave Sovereign", "arch": Arch.SUMMONER, "hp": 14, "dmg": 8, "speed": 34.0,
                 "color": Color(0.70, 0.58, 0.30), "tags": ["undead", "boss"], "boss": true,
                 "summon_id": "shambler", "summon_count": 3, "summon_interval": 3.5, "shield": true},
    },
    "warrens": {
        "name": "Silkfall Warrens",
        "floor": Color(0.17, 0.16, 0.15), "wall": Color(0.09, 0.08, 0.10),
        "enemies": [
            {"id": "skitterer", "name": "Web Skitterer",    "arch": Arch.SWARM,   "hp": 1, "dmg": 2, "speed": 74.0, "color": Color(0.42, 0.34, 0.30), "tags": ["spider"]},
            {"id": "spitter",   "name": "Silk Spitter",     "arch": Arch.TURRET,  "hp": 2, "dmg": 2, "speed": 0.0,  "color": Color(0.58, 0.50, 0.40), "tags": ["spider", "slows"],
                 "ranged": {"interval": 2.2, "pspeed": 90.0, "pdmg": 2, "pcolor": Color(0.85, 0.85, 0.80), "kind": "straight"}},
            {"id": "duskweaver","name": "Duskweaver",       "arch": Arch.CHASE,   "hp": 3, "dmg": 4, "speed": 58.0, "color": Color(0.34, 0.28, 0.36), "tags": ["spider"]},
            {"id": "lurker",    "name": "Trapdoor Lurker",  "arch": Arch.CHARGER, "hp": 3, "dmg": 4, "speed": 92.0, "color": Color(0.30, 0.26, 0.24), "tags": ["spider", "ambush"]},
            {"id": "broodmother","name": "Broodmother",     "arch": Arch.SUMMONER, "hp": 6, "dmg": 4, "speed": 24.0, "color": Color(0.40, 0.30, 0.34), "tags": ["spider"],
                 "summon_id": "skitterer", "summon_count": 3, "summon_interval": 4.0},
        ],
        "boss": {"id": "weaver_queen", "name": "The Weaver Queen", "arch": Arch.TURRET, "hp": 16, "dmg": 8, "speed": 0.0,
                 "color": Color(0.62, 0.50, 0.62), "tags": ["spider", "boss"], "boss": true, "aggro": 999.0,
                 "ranged": {"interval": 1.6, "pspeed": 120.0, "pdmg": 4, "pcolor": Color(0.90, 0.90, 0.85), "kind": "straight"}},
    },
    "thornwild": {
        "name": "Thornwild",
        "floor": Color(0.15, 0.19, 0.13), "wall": Color(0.08, 0.12, 0.07),
        "enemies": [
            {"id": "boar",      "name": "Horned Boar",      "arch": Arch.CHARGER, "hp": 4, "dmg": 8, "speed": 96.0, "color": Color(0.50, 0.38, 0.26), "tags": ["beast"]},
            {"id": "spriggan",  "name": "Spriggan",         "arch": Arch.PATROL,  "hp": 2, "dmg": 4, "speed": 44.0, "color": Color(0.36, 0.52, 0.28), "tags": ["beast", "disguised"]},
            {"id": "wisp",      "name": "Wisp",             "arch": Arch.SWARM,   "hp": 1, "dmg": 2, "speed": 40.0, "color": Color(0.85, 0.90, 0.55), "tags": ["spirit"]},
            {"id": "treant",    "name": "Bark Treant",      "arch": Arch.LOBBER,  "hp": 5, "dmg": 4, "speed": 0.0,  "color": Color(0.34, 0.28, 0.18), "tags": ["plant"],
                 "ranged": {"interval": 2.6, "pspeed": 70.0, "pdmg": 4, "pcolor": Color(0.55, 0.45, 0.25), "kind": "lob"}},
            {"id": "wolf",      "name": "Dire Wolf",        "arch": Arch.CHASE,   "hp": 3, "dmg": 4, "speed": 84.0, "color": Color(0.44, 0.44, 0.48), "tags": ["beast"]},
        ],
        "boss": {"id": "root_mother", "name": "Root-Mother", "arch": Arch.LOBBER, "hp": 15, "dmg": 8, "speed": 0.0,
                 "color": Color(0.36, 0.32, 0.16), "tags": ["plant", "boss"], "boss": true, "aggro": 999.0,
                 "ranged": {"interval": 2.0, "pspeed": 80.0, "pdmg": 4, "pcolor": Color(0.60, 0.50, 0.22), "kind": "lob"}},
    },
    "emberdeep": {
        "name": "Emberdeep",
        "floor": Color(0.18, 0.12, 0.10), "wall": Color(0.10, 0.06, 0.06),
        "enemies": [
            {"id": "imp",       "name": "Cinder Imp",       "arch": Arch.JUMPER,  "hp": 2, "dmg": 4, "speed": 66.0, "color": Color(0.88, 0.42, 0.20), "tags": ["fire"]},
            {"id": "hound",     "name": "Magma Hound",      "arch": Arch.CHASE,   "hp": 3, "dmg": 4, "speed": 80.0, "color": Color(0.78, 0.28, 0.16), "tags": ["fire", "weak_ice"]},
            {"id": "emberbat",  "name": "Ember Bat",        "arch": Arch.SWARM,   "hp": 1, "dmg": 2, "speed": 92.0, "color": Color(0.95, 0.55, 0.25), "tags": ["fire"]},
            {"id": "golem",     "name": "Obsidian Golem",   "arch": Arch.CHARGER, "hp": 6, "dmg": 8, "speed": 64.0, "color": Color(0.22, 0.18, 0.24), "tags": ["weak_ice", "splits_on_fire"]},
            {"id": "slime",     "name": "Lava Slime",       "arch": Arch.PATROL,  "hp": 2, "dmg": 4, "speed": 30.0, "color": Color(0.90, 0.35, 0.18), "tags": ["fire", "splits"]},
        ],
        "boss": {"id": "forge_tyrant", "name": "The Forge Tyrant", "arch": Arch.CHARGER, "hp": 18, "dmg": 8, "speed": 88.0,
                 "color": Color(0.85, 0.45, 0.18), "tags": ["fire", "boss"], "boss": true, "aggro": 999.0},
    },
    "glacier": {
        "name": "Glacier Barrow",
        "floor": Color(0.15, 0.18, 0.22), "wall": Color(0.08, 0.11, 0.16),
        "enemies": [
            {"id": "thrall",    "name": "Frozen Thrall",    "arch": Arch.PATROL,  "hp": 3, "dmg": 4, "speed": 24.0, "color": Color(0.55, 0.68, 0.78), "tags": ["undead", "shatters_on_death"]},
            {"id": "rime",      "name": "Rime Skitterer",   "arch": Arch.SWARM,   "hp": 1, "dmg": 2, "speed": 70.0, "color": Color(0.62, 0.76, 0.86), "tags": ["spider", "slows"]},
            {"id": "basilisk",  "name": "Ice Basilisk",     "arch": Arch.TURRET,  "hp": 4, "dmg": 0, "speed": 0.0,  "color": Color(0.45, 0.62, 0.72), "tags": ["freezes"],
                 "ranged": {"interval": 2.4, "pspeed": 130.0, "pdmg": 0, "pcolor": Color(0.75, 0.92, 1.0), "kind": "straight", "freeze": true}},
            {"id": "snowwraith","name": "Snow Wraith",      "arch": Arch.PHASE,   "hp": 3, "dmg": 4, "speed": 46.0, "color": Color(0.80, 0.88, 0.95), "tags": ["undead"]},
            {"id": "yeti",      "name": "Yeti",             "arch": Arch.CHARGER, "hp": 6, "dmg": 8, "speed": 74.0, "color": Color(0.86, 0.88, 0.90), "tags": ["beast"]},
        ],
        "boss": {"id": "frostmaw", "name": "Frostmaw", "arch": Arch.PHASE, "hp": 16, "dmg": 8, "speed": 60.0,
                 "color": Color(0.72, 0.86, 0.95), "tags": ["boss", "ice"], "boss": true, "aggro": 999.0,
                 "ranged": {"interval": 2.8, "pspeed": 100.0, "pdmg": 4, "pcolor": Color(0.80, 0.95, 1.0), "kind": "straight"}},
    },
    "sunken": {
        "name": "Sunken Ruins",
        "floor": Color(0.12, 0.16, 0.19), "wall": Color(0.07, 0.09, 0.12),
        "enemies": [
            {"id": "drowned",   "name": "Drowned Servant",  "arch": Arch.PATROL,  "hp": 3, "dmg": 4, "speed": 30.0, "color": Color(0.34, 0.50, 0.50), "tags": ["undead", "drowned", "pulls"]},
            {"id": "eel",       "name": "Barbed Eel",       "arch": Arch.CHARGER, "hp": 3, "dmg": 4, "speed": 104.0, "color": Color(0.28, 0.42, 0.36), "tags": ["aquatic"]},
            {"id": "jelly",     "name": "Jelly Drift",      "arch": Arch.SWARM,   "hp": 2, "dmg": 2, "speed": 34.0, "color": Color(0.48, 0.62, 0.78), "tags": ["aquatic", "zaps"]},
            {"id": "crab",      "name": "Undertow Crab",    "arch": Arch.PATROL,  "hp": 5, "dmg": 8, "speed": 26.0, "color": Color(0.66, 0.36, 0.28), "tags": ["aquatic", "armored"]},
            {"id": "siren",     "name": "Siren Wisp",       "arch": Arch.SUMMONER, "hp": 4, "dmg": 4, "speed": 30.0, "color": Color(0.58, 0.74, 0.82), "tags": ["spirit"],
                 "summon_id": "drowned", "summon_count": 2, "summon_interval": 4.5},
        ],
        "boss": {"id": "tidebound", "name": "The Tidebound", "arch": Arch.SUMMONER, "hp": 16, "dmg": 8, "speed": 32.0,
                 "color": Color(0.30, 0.52, 0.60), "tags": ["aquatic", "boss"], "boss": true, "aggro": 999.0,
                 "summon_id": "drowned", "summon_count": 3, "summon_interval": 3.2, "shield": true},
    },
    "arcanum": {
        "name": "The Arcanum",
        "floor": Color(0.13, 0.12, 0.17), "wall": Color(0.07, 0.07, 0.11),
        "enemies": [
            {"id": "priest",    "name": "Techno-Priest",    "arch": Arch.SUMMONER, "hp": 5, "dmg": 4, "speed": 30.0, "color": Color(0.55, 0.45, 0.85), "tags": ["machine", "elite", "corrupts"],
                 "summon_id": "servitor", "summon_count": 2, "summon_interval": 4.0, "shield": true},
            {"id": "warthog",   "name": "Laser Warthog",    "arch": Arch.CHARGER, "hp": 5, "dmg": 8, "speed": 112.0, "color": Color(0.85, 0.35, 0.55), "tags": ["machine", "elite"],
                 "ranged": {"interval": 3.0, "pspeed": 300.0, "pdmg": 4, "pcolor": Color(1.0, 0.25, 0.35), "kind": "laser"}},
            {"id": "sentinel",  "name": "Arcane Sentinel",  "arch": Arch.TURRET,  "hp": 4, "dmg": 4, "speed": 0.0,  "color": Color(0.60, 0.60, 0.90), "tags": ["machine"],
                 "ranged": {"interval": 2.0, "pspeed": 220.0, "pdmg": 4, "pcolor": Color(0.6, 0.5, 1.0), "kind": "laser"}},
            {"id": "clockwork", "name": "Clockwork Golem",  "arch": Arch.PATROL,  "hp": 4, "dmg": 8, "speed": 40.0, "color": Color(0.62, 0.58, 0.50), "tags": ["machine", "revives_once"]},
            {"id": "mana",      "name": "Mana Elemental",   "arch": Arch.PHASE,   "hp": 3, "dmg": 4, "speed": 52.0, "color": Color(0.45, 0.80, 0.95), "tags": ["spirit", "machine"]},
            {"id": "specter",   "name": "Cyber Specter",    "arch": Arch.CHASE,   "hp": 3, "dmg": 4, "speed": 78.0, "color": Color(0.70, 0.45, 0.90), "tags": ["machine", "phases_walls"]},
            {"id": "servitor",  "name": "Servitor",         "arch": Arch.PATROL,  "hp": 2, "dmg": 4, "speed": 34.0, "color": Color(0.45, 0.55, 0.60), "tags": ["machine", "undead"]},
            {"id": "raver",     "name": "Rave Punk",         "arch": Arch.SWARM,   "hp": 2, "dmg": 2, "speed": 98.0, "color": Color(0.95, 0.25, 0.85), "tags": ["machine", "raver"]},
            {"id": "bruiser",   "name": "Bassline Bruiser",  "arch": Arch.CHARGER, "hp": 4, "dmg": 4, "speed": 96.0, "color": Color(0.35, 0.95, 0.45), "tags": ["machine", "raver"],
             "ring": {"interval": 2.4, "count": 8, "speed": 110.0, "dmg": 2, "color": Color(0.4, 1.0, 0.5)}},
            {"id": "dj",        "name": "Strobe DJ",         "arch": Arch.TURRET,  "hp": 5, "dmg": 2, "speed": 0.0,  "color": Color(0.55, 0.85, 1.0), "tags": ["machine", "raver", "strobe"],
             "ranged": {"interval": 1.8, "pspeed": 200.0, "pdmg": 2, "pcolor": Color(0.7, 0.9, 1.0), "kind": "laser"},
             "summon_id": "raver", "summon_count": 2, "summon_interval": 5.0},
            {"id": "mosh",      "name": "Mosh Pit King",     "arch": Arch.CHARGER, "hp": 7, "dmg": 8, "speed": 92.0, "color": Color(0.90, 0.35, 0.90), "tags": ["machine", "raver", "elite"],
             "ring": {"interval": 3.0, "count": 10, "speed": 120.0, "dmg": 4, "color": Color(1.0, 0.4, 0.9)}},
        ],
        "boss": {"id": "ordinator", "name": "The Ordinator", "arch": Arch.SUMMONER, "hp": 22, "dmg": 8, "speed": 36.0,
                 "color": Color(0.70, 0.55, 0.95), "tags": ["machine", "boss"], "boss": true, "aggro": 999.0,
                 "summon_id": "servitor", "summon_count": 2, "summon_interval": 3.0, "shield": true},
    },
}

## Enemies that can appear in any biome.
const GLOBAL := [
    {"id": "keese", "name": "Cave Keese", "arch": Arch.SWARM, "hp": 1, "dmg": 2, "speed": 88.0, "color": Color(0.55, 0.45, 0.55), "tags": ["bat"]},
    {"id": "rat",   "name": "Rat King",   "arch": Arch.SWARM, "hp": 1, "dmg": 2, "speed": 64.0, "color": Color(0.48, 0.44, 0.40), "tags": ["vermin"]},
]

## Rare global spawns (low chance anywhere). The dungeon's weirdest locals.
const RARE := [
    {"id": "hermit", "name": "Mad Hermit", "arch": Arch.CHASE, "hp": 4, "dmg": 4, "speed": 58.0,
     "color": Color(0.74, 0.62, 0.44), "tags": ["human", "ranged"],
     "ranged": {"interval": 1.9, "pspeed": 150.0, "pdmg": 4, "pcolor": Color(0.95, 0.85, 0.5),
                "kind": "spread", "count": 5, "spread": 0.5}},
]

static func biome_for_depth(depth: int) -> String:
    var i: int = clamp(int(depth / 2), 0, BIOME_ORDER.size() - 1)
    return BIOME_ORDER[i]

static func enemies_for(biome: String) -> Array:
    return BIOMES.get(biome, {}).get("enemies", [])

static func boss_for(biome: String) -> Dictionary:
    return BIOMES.get(biome, {}).get("boss", {})

static func find(biome: String, id: String) -> Dictionary:
    for e in enemies_for(biome):
        if e["id"] == id:
            return e
    # summons may live in another biome (e.g. Servitor); fall back to a global search
    for b in BIOMES.values():
        for e in b.get("enemies", []):
            if e["id"] == id:
                return e
    for e in GLOBAL:
        if e["id"] == id:
            return e
    for e in RARE:
        if e["id"] == id:
            return e
    return {}
