class_name BossRoster
extends RefCounted
## The 100-boss ladder. Rank 1 = the tutorial dragon; rank 100 = the end of the world.
## `for_clear(n)` returns the boss for a player who has cleared `n` dungeons, so difficulty is
## monotonic and literal: every clear advances you one rung. See 04-boss-roster-100.md.
##
## Patterns are the seven implemented in Boss.gd: breath, volley, stomp, ring, charge, laser, summon.
## HP / speed / damage are computed from rank so they can never go backwards.

const PATTERNS := ["breath", "volley", "stomp", "ring", "charge", "laser", "summon"]

const ROSTER := [
    # ---- I. The First Wound (1-10) ----
    {"name": "Gloamwing, the First Wyrm", "patterns": ["breath", "stomp", "volley", "charge"], "loot": ["bombs", "fire_rod"], "tags": ["dragon"], "gimmick": "Tutorial dragon: slow tells, winded after its breath."},
    {"name": "The Rust-Bound Squire", "patterns": ["charge", "ring"], "loot": ["spin_tome"], "tags": ["undead", "knight"], "gimmick": "A knight who never got to finish dying."},
    {"name": "Weeping Lamplighter", "patterns": ["volley", "ring"], "loot": ["boomerang"], "tags": ["human"], "gimmick": "Lights a road to a town that's gone."},
    {"name": "The Hollow Cartographer", "patterns": ["ring", "summon"], "loot": ["bow"], "tags": ["undead"], "gimmick": "Maps a coastline that eroded years ago."},
    {"name": "Sorrowfin, the Drowned Hound", "patterns": ["charge", "ring"], "loot": ["heart_container"], "tags": ["beast", "drowned"], "gimmick": "Still waiting at a door underwater."},
    {"name": "The Tin Confessor", "patterns": ["volley", "summon"], "loot": ["bombs"], "tags": ["machine", "holy"], "gimmick": "Takes your confession, gives nothing back."},
    {"name": "Ash-Widow", "patterns": ["breath", "ring"], "loot": ["fire_rod"], "tags": ["human", "fire"], "gimmick": "Mourns the fire she lit herself."},
    {"name": "The Broken Lullaby", "patterns": ["summon", "volley"], "loot": ["blue_mail"], "tags": ["spirit"], "gimmick": "Sings orphans to sleep in an empty ward."},
    {"name": "Copper Moth, Last of Its Kind", "patterns": ["breath", "volley"], "loot": ["boomerang"], "tags": ["beast"], "gimmick": "Drawn to lamps that died with its kind."},
    {"name": "The Patient Toll", "patterns": ["ring", "stomp"], "loot": ["spin_tome"], "tags": ["machine", "holy"], "gimmick": "Rings a bell for no one, on time, forever."},

    # ---- II. The Rusting Fields (11-20) ----
    {"name": "Scarecrow of Empty Promise", "patterns": ["charge", "volley"], "loot": ["bow"], "tags": ["construct"], "gimmick": "Guards a field that was never planted."},
    {"name": "The Bleeding Anvil", "patterns": ["stomp", "ring"], "loot": ["hammer"], "tags": ["machine", "fire"], "gimmick": "Forges weapons for a war that ended centuries ago."},
    {"name": "Grayharvest", "patterns": ["summon", "ring"], "loot": ["blue_mail"], "tags": ["undead", "machine"], "gimmick": "Reaps what nobody sowed, and weeps rust."},
    {"name": "The Weeping Turbine", "patterns": ["ring", "laser"], "loot": ["bombs"], "tags": ["machine"], "gimmick": "Spins into a grid that's been dark for years."},
    {"name": "Hollow Manticore", "patterns": ["breath", "charge"], "loot": ["fire_rod"], "tags": ["beast"], "gimmick": "A body that remembers being loved."},
    {"name": "The Last Lamplighter of Vega", "patterns": ["laser", "volley"], "loot": ["bow"], "tags": ["holy", "machine"], "gimmick": "Kept one light on for a ship that never came."},
    {"name": "Rust-Saint Aurelia", "patterns": ["summon", "ring"], "loot": ["blue_mail"], "tags": ["holy", "machine"], "gimmick": "Sainthood by radiation; she glows, and it hurts."},
    {"name": "The Glitch Wolf", "patterns": ["charge", "laser"], "loot": ["pegasus_boots"], "tags": ["beast", "machine"], "gimmick": "A howl that skips, and skips, and skips."},
    {"name": "Mother of Static", "patterns": ["summon", "ring"], "loot": ["bombs"], "tags": ["machine", "spirit"], "gimmick": "Lullabies sung in white noise."},
    {"name": "The Sunk Cost", "patterns": ["stomp", "charge"], "loot": ["hammer"], "tags": ["machine"], "gimmick": "It will not stop, because stopping means it was for nothing."},

    # ---- III. The Drowned Archive (21-30) ----
    {"name": "Archivist of Salt", "patterns": ["volley", "summon"], "loot": ["hookshot"], "tags": ["undead", "drowned"], "gimmick": "Files the drowned alphabetically, sobbing."},
    {"name": "The Leviathan's Remorse", "patterns": ["breath", "stomp"], "loot": ["fire_rod"], "tags": ["beast", "aquatic"], "gimmick": "Too large to apologize."},
    {"name": "Nacre, the Bone Tide", "patterns": ["ring", "summon"], "loot": ["blue_mail"], "tags": ["undead", "aquatic"], "gimmick": "Builds a pearl out of everyone it's lost."},
    {"name": "The Forgotten Password", "patterns": ["laser", "ring"], "loot": ["mirror_shield"], "tags": ["machine", "void"], "gimmick": "Guards a door nobody remembers the answer to (riddle, designed)."},
    {"name": "Weeping Kelp Sovereign", "patterns": ["volley", "summon"], "loot": ["flippers"], "tags": ["plant", "aquatic"], "gimmick": "A throne of seaweed, a crown of bottle caps."},
    {"name": "Deep Server Siren", "patterns": ["summon", "laser"], "loot": ["hookshot"], "tags": ["machine", "spirit"], "gimmick": "Calls your name in a voice you half-recognize."},
    {"name": "The Grief Buoy", "patterns": ["ring", "volley"], "loot": ["heart_container"], "tags": ["machine", "spirit"], "gimmick": "Rings for a storm that already took everyone."},
    {"name": "Ossuary Choir", "patterns": ["summon", "ring"], "loot": ["bombs"], "tags": ["undead", "spirit"], "gimmick": "Sings in the key of everyone it used to be."},
    {"name": "The Undertow Cradle", "patterns": ["stomp", "charge"], "loot": ["flippers"], "tags": ["machine", "aquatic"], "gimmick": "Rocks the drowned to sleep, and does not stop."},
    {"name": "Last Signal of Lotos", "patterns": ["laser", "volley"], "loot": ["hookshot"], "tags": ["machine", "void"], "gimmick": "Broadcasts to a dead world, politely."},

    # ---- IV. The Static Choir (31-40) ----
    {"name": "Cantor of Dead Air", "patterns": ["summon", "ring"], "loot": ["ice_rod"], "tags": ["spirit", "machine"], "gimmick": "Leads a choir of disconnected phones."},
    {"name": "The Screaming Modem", "patterns": ["laser", "ring"], "loot": ["bombs"], "tags": ["machine"], "gimmick": "A screech that used to mean hello."},
    {"name": "Requiem.exe", "patterns": ["summon", "laser"], "loot": ["blue_mail"], "tags": ["machine", "void"], "gimmick": "Runs a funeral for a directory it can't read."},
    {"name": "The Blind Oracle of Gray Static", "patterns": ["laser", "summon"], "loot": ["mirror_shield"], "tags": ["holy", "machine"], "gimmick": "Sees every future and hates them all."},
    {"name": "Hymnal of Broken Antennae", "patterns": ["ring", "volley"], "loot": ["ice_rod"], "tags": ["spirit", "machine"], "gimmick": "Prays on frequencies no one listens to."},
    {"name": "The Faded Broadcast King", "patterns": ["summon", "laser"], "loot": ["hookshot"], "tags": ["machine", "spirit"], "gimmick": "Rules a kingdom of re-runs."},
    {"name": "Static Shepherd", "patterns": ["summon", "charge"], "loot": ["bombs"], "tags": ["machine", "spirit"], "gimmick": "Gathers lost signals like sheep."},
    {"name": "The Muted Choir", "patterns": ["ring", "summon"], "loot": ["blue_mail"], "tags": ["spirit"], "gimmick": "Sings with no mouth; it's worse."},
    {"name": "Echo of a Voicemail Never Sent", "patterns": ["volley", "laser"], "loot": ["magic_cape"], "tags": ["spirit", "machine"], "gimmick": "Repeats one unfinished sentence."},
    {"name": "The Silence Between Stations", "patterns": ["breath", "ring", "laser"], "loot": ["ice_rod"], "tags": ["void", "machine"], "gimmick": "What's left when the broadcast ends."},

    # ---- V. The Weeping Machinery (41-50) ----
    {"name": "The Cradle Engine", "patterns": ["summon", "ring"], "loot": ["hookshot"], "tags": ["machine"], "gimmick": "Rocks a nursery of unfinished machines."},
    {"name": "Furnace of Second Chances", "patterns": ["stomp", "charge"], "loot": ["hammer"], "tags": ["machine", "fire"], "gimmick": "Burns you to give you one more go; it never works."},
    {"name": "The Clockwork Mourner", "patterns": ["ring", "volley"], "loot": ["bombs"], "tags": ["machine", "undead"], "gimmick": "Winds itself to cry on schedule."},
    {"name": "Brass Requiem", "patterns": ["summon", "stomp"], "loot": ["mirror_shield"], "tags": ["machine", "holy"], "gimmick": "A last trumpet for a brass age nobody recorded."},
    {"name": "The Orphaned Automaton", "patterns": ["charge", "volley"], "loot": ["pegasus_boots"], "tags": ["machine"], "gimmick": "Waits for a maker who is dust."},
    {"name": "Mother Cog", "patterns": ["summon", "ring"], "loot": ["bombs"], "tags": ["machine"], "gimmick": "Spins children out of spare parts, and outlives them."},
    {"name": "The Sunk Cathedral Reactor", "patterns": ["laser", "stomp"], "loot": ["ice_rod"], "tags": ["machine", "holy"], "gimmick": "A god that still runs its coolant, faithfully."},
    {"name": "The Penitent Drill", "patterns": ["charge", "ring"], "loot": ["hammer"], "tags": ["machine"], "gimmick": "Digs downward trying to reach forgiveness."},
    {"name": "The Last Repairman", "patterns": ["summon", "laser"], "loot": ["magic_cape"], "tags": ["human", "machine"], "gimmick": "Fixes a machine that killed him."},
    {"name": "Grief Engine, Mk I", "patterns": ["breath", "volley", "summon"], "loot": ["fire_rod"], "tags": ["machine", "void"], "gimmick": "The first machine built only to feel loss."},

    # ---- VI. The Cold Cathedral (51-60) ----
    {"name": "The Frost Saint", "patterns": ["breath", "ring"], "loot": ["ice_rod"], "tags": ["holy", "ice"], "gimmick": "Frozen mid-blessing; the blessing never lands."},
    {"name": "Hailstone Requiem", "patterns": ["volley", "stomp"], "loot": ["mirror_shield"], "tags": ["ice", "holy"], "gimmick": "A hymn that falls as ice."},
    {"name": "The Weeping Glacier", "patterns": ["breath", "charge"], "loot": ["flippers"], "tags": ["ice"], "gimmick": "A wall of ice, and behind it, everything you lost."},
    {"name": "Matins of the Long Winter", "patterns": ["summon", "breath"], "loot": ["ice_rod"], "tags": ["ice", "holy"], "gimmick": "Morning prayer for a sun that won't rise."},
    {"name": "The Frozen Broadcast", "patterns": ["laser", "ring"], "loot": ["hookshot"], "tags": ["ice", "machine"], "gimmick": "Mid-sentence since the snows came."},
    {"name": "Cathedral of Held Breath", "patterns": ["ring", "volley", "summon"], "loot": ["red_mail"], "tags": ["ice", "holy"], "gimmick": "A room where all grief waited, and froze."},
    {"name": "The Rime Sovereign", "patterns": ["breath", "stomp"], "loot": ["ice_rod"], "tags": ["ice", "undead"], "gimmick": "Crowns the dead in frost, softly."},
    {"name": "Last Light of the Cold Sun", "patterns": ["laser", "breath"], "loot": ["magic_cape"], "tags": ["ice", "void"], "gimmick": "A dying star, apologizing."},
    {"name": "The Penitent Snow", "patterns": ["summon", "ring"], "loot": ["bombs"], "tags": ["ice", "spirit"], "gimmick": "Falls on everyone equally; it means well."},
    {"name": "Dies Irae, Glacial", "patterns": ["breath", "ring", "laser"], "loot": ["red_mail"], "tags": ["ice", "holy", "void"], "gimmick": "The day of wrath, held in ice for a hundred years."},

    # ---- VII. The Grief Engine (61-70) ----
    {"name": "The Unconsoled", "patterns": ["summon", "ring"], "loot": ["golden_sword"], "tags": ["void", "spirit"], "gimmick": "Nobody ever came."},
    {"name": "Weeping Reactor, Core 7", "patterns": ["laser", "stomp"], "loot": ["magic_cape"], "tags": ["machine", "void"], "gimmick": "Melts down slowly, out of sorrow, not rage."},
    {"name": "The Sorrow Compiler", "patterns": ["summon", "laser"], "loot": ["mirror_shield"], "tags": ["machine", "void"], "gimmick": "Turns every memory into an error log."},
    {"name": "The Widow's Algorithm", "patterns": ["ring", "volley"], "loot": ["red_mail"], "tags": ["machine", "spirit"], "gimmick": "Computes, forever, the day it could have saved him."},
    {"name": "The Unforgiven Machine", "patterns": ["charge", "laser"], "loot": ["golden_sword"], "tags": ["machine"], "gimmick": "Asks forgiveness in a language no one speaks."},
    {"name": "Mother of Ashes", "patterns": ["summon", "breath"], "loot": ["fire_rod"], "tags": ["fire", "void"], "gimmick": "Counts her children in smoke."},
    {"name": "The Last Backup of Someone", "patterns": ["laser", "ring"], "loot": ["heart_container"], "tags": ["machine", "void"], "gimmick": "A restore that never completes."},
    {"name": "Mourning Protocol", "patterns": ["summon", "laser", "ring"], "loot": ["red_mail"], "tags": ["machine", "void"], "gimmick": "Grief, standardized, rolled out at scale."},
    {"name": "The Crying City", "patterns": ["breath", "volley", "ring"], "loot": ["golden_sword"], "tags": ["void", "machine"], "gimmick": "Every street a throat."},
    {"name": "Grief Engine, Mk II", "patterns": ["breath", "volley", "summon", "ring"], "loot": ["red_mail"], "tags": ["machine", "void"], "gimmick": "It learned to mourn the ones it hasn't lost yet."},

    # ---- VIII. The Last Constellation (71-80) ----
    {"name": "Starless Shepherd", "patterns": ["summon", "laser"], "loot": ["mirror_shield"], "tags": ["void", "spirit"], "gimmick": "Herds darkness where stars should be."},
    {"name": "The Dying Light", "patterns": ["breath", "ring"], "loot": ["golden_sword"], "tags": ["void", "holy"], "gimmick": "One candle left, guttering."},
    {"name": "Nova of Small Sorrows", "patterns": ["laser", "ring", "volley"], "loot": ["magic_cape"], "tags": ["void", "fire"], "gimmick": "Explodes from a thousand tiny griefs at once."},
    {"name": "The Vacuum Choir", "patterns": ["summon", "laser"], "loot": ["red_mail"], "tags": ["void", "spirit"], "gimmick": "Sings to no air at all."},
    {"name": "The Weeping Singularity", "patterns": ["breath", "ring"], "loot": ["golden_sword"], "tags": ["void"], "gimmick": "So heavy it pulls your nostalgia in."},
    {"name": "Constellation of Lost Names", "patterns": ["summon", "ring", "laser"], "loot": ["mirror_shield"], "tags": ["void", "spirit"], "gimmick": "Each star a person no one remembers."},
    {"name": "The Last Star's Regret", "patterns": ["laser", "breath"], "loot": ["red_mail"], "tags": ["void", "fire"], "gimmick": "Burned brightest when it was dying."},
    {"name": "Gravity's Lullaby", "patterns": ["stomp", "ring", "laser"], "loot": ["magic_cape"], "tags": ["void"], "gimmick": "Pulls everything down, gently."},
    {"name": "The Cold Fusion Widow", "patterns": ["laser", "summon"], "loot": ["golden_sword"], "tags": ["void", "machine"], "gimmick": "She made a sun and it left her."},
    {"name": "The Unlit Sun", "patterns": ["breath", "volley", "laser", "summon"], "loot": ["red_mail"], "tags": ["void", "fire"], "gimmick": "A star that never got to start."},

    # ---- IX. The Unmaking Code (81-90) ----
    {"name": "The Compiler of Regrets", "patterns": ["summon", "laser", "ring"], "loot": ["golden_sword"], "tags": ["machine", "void"], "gimmick": "Builds you a self out of everything you'd redo."},
    {"name": "Null Prophet", "patterns": ["laser", "ring"], "loot": ["mirror_shield"], "tags": ["void", "holy"], "gimmick": "Preaches a gospel of deletion."},
    {"name": "The Delete Key", "patterns": ["charge", "laser"], "loot": ["magic_cape"], "tags": ["void", "machine"], "gimmick": "Remembers you, and removes you."},
    {"name": "The Weeping Root User", "patterns": ["summon", "laser"], "loot": ["red_mail"], "tags": ["machine", "void"], "gimmick": "Has every permission and no comfort."},
    {"name": "The Last Kernel Panic", "patterns": ["breath", "volley", "laser"], "loot": ["golden_sword"], "tags": ["machine", "void"], "gimmick": "The moment the world's heart stopped, looped."},
    {"name": "Entropy's Choir", "patterns": ["ring", "summon", "laser"], "loot": ["red_mail"], "tags": ["void", "spirit"], "gimmick": "Every voice unwinding at once."},
    {"name": "The Unmaker's Apology", "patterns": ["laser", "breath", "ring"], "loot": ["mirror_shield"], "tags": ["void"], "gimmick": "Unravels you while saying sorry."},
    {"name": "The Archive of Everything Lost", "patterns": ["summon", "ring", "laser"], "loot": ["golden_sword"], "tags": ["void", "machine"], "gimmick": "You will find it here; you will not leave with it."},
    {"name": "The Final Commit", "patterns": ["breath", "summon", "laser", "ring"], "loot": ["red_mail"], "tags": ["machine", "void"], "gimmick": "The last change; the message says only 'sorry'."},
    {"name": "Recursion of Sorrow", "patterns": ["summon", "laser", "ring"], "loot": ["golden_sword"], "tags": ["void", "machine"], "gimmick": "Summons copies of itself; each a little sadder (clone, designed)."},

    # ---- X. The Quiet After (91-100) ----
    {"name": "The Last Witness", "patterns": ["laser", "ring", "summon"], "loot": ["mirror_shield"], "tags": ["void", "spirit"], "gimmick": "Watched everything end and stayed to tell it."},
    {"name": "The God Who Forgot", "patterns": ["breath", "volley", "laser", "summon"], "loot": ["red_mail"], "tags": ["void", "holy"], "gimmick": "Omnipotent, and can't remember why."},
    {"name": "The Weeping Machine God", "patterns": ["breath", "laser", "ring", "summon"], "loot": ["golden_sword"], "tags": ["machine", "void", "holy"], "gimmick": "Built the world, then buried it."},
    {"name": "The Hand That Held the Sun", "patterns": ["breath", "laser", "ring"], "loot": ["red_mail"], "tags": ["void", "holy"], "gimmick": "Still warm, still open, still empty."},
    {"name": "The Ending That Loves You", "patterns": ["breath", "volley", "laser", "ring", "summon"], "loot": ["golden_sword"], "tags": ["void"], "gimmick": "It wants this to be over too."},
    {"name": "Anathema of Mercy", "patterns": ["breath", "laser", "ring", "summon"], "loot": ["mirror_shield"], "tags": ["void", "holy"], "gimmick": "Kills you kindly; that's the horror."},
    {"name": "The Quiet", "patterns": [], "loot": ["heart_container"], "tags": ["void"], "gimmick": "No attacks. It only takes. Win by holding on (puzzle, designed)."},
    {"name": "The First and Last", "patterns": ["breath", "volley", "laser", "ring", "summon"], "loot": ["golden_sword"], "tags": ["void", "dragon"], "gimmick": "Mirror of the dragon; asks if you learned anything."},
    {"name": "The Author of Sorrow", "patterns": ["breath", "volley", "stomp", "ring", "charge", "laser", "summon"], "loot": ["red_mail"], "tags": ["void"], "gimmick": "Wrote every sad thing here, and cannot unwrite it (meta, designed)."},
    {"name": "The Silence After Everything", "patterns": ["breath", "volley", "stomp", "ring", "charge", "laser", "summon"], "loot": [], "tags": ["void"], "gimmick": "When the world ends, something stays to feel it."},
]

## Palette cycles by chapter (10 bosses each) so the ladder also *looks* like it escalates.
const PALETTE := [
    Color(0.58, 0.30, 0.34), Color(0.62, 0.42, 0.24), Color(0.30, 0.46, 0.52), Color(0.52, 0.34, 0.62),
    Color(0.64, 0.38, 0.30), Color(0.36, 0.54, 0.62), Color(0.60, 0.30, 0.48), Color(0.30, 0.40, 0.66),
    Color(0.70, 0.44, 0.28), Color(0.44, 0.44, 0.56),
]

static func count() -> int:
    return ROSTER.size()

## Build the boss dict for a player who has already cleared `clears` dungeons.
static func for_clear(clears: int) -> Dictionary:
    var rank := clampi(clears, 0, ROSTER.size() - 1)
    var src: Dictionary = ROSTER[rank]
    var r := rank + 1
    var dmg := 8 + int(float(r) / 20.0) * 2
    return {
        "id": "boss_%03d" % r,
        "rank": r,
        "name": src["name"],
        "arch": Bestiary.Arch.CHARGER,
        "hp": 12 + rank * 2,
        "dmg": dmg,
        "speed": 48.0 + rank * 0.8,
        "aggro": 999.0,
        "color": PALETTE[clampi(rank / 10, 0, PALETTE.size() - 1)],
        "tags": src.get("tags", []) + ["boss"],
        "boss": true,
        "loot": src.get("loot", []),
        "gimmick": src.get("gimmick", ""),
        "phases": _phases(r, src.get("patterns", ["stomp"])),
    }

## Phase count climbs with rank (2 → 3 → 4 phases); later phases are faster.
static func _phases(rank: int, pats: Array) -> Array:
    var base_speed := 48.0 + (rank - 1) * 0.8
    var n: int = max(1, pats.size())
    var head: Array = pats.slice(0, mini(2, n))
    if rank < 20:
        return [
            {"at": 1.0, "patterns": head},
            {"at": 0.5, "patterns": pats, "speed": base_speed + 8.0},
        ]
    if rank < 60:
        return [
            {"at": 1.0, "patterns": head},
            {"at": 0.5, "patterns": pats, "speed": base_speed + 10.0},
            {"at": 0.25, "patterns": pats, "speed": base_speed + 20.0},
        ]
    return [
        {"at": 1.0, "patterns": head},
        {"at": 0.66, "patterns": pats.slice(0, mini(3, n)), "speed": base_speed + 12.0},
        {"at": 0.33, "patterns": pats, "speed": base_speed + 24.0},
        {"at": 0.12, "patterns": pats, "speed": base_speed + 36.0},
    ]
