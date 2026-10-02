# The Boss Ladder — 100 bosses, each harder than the last

Companion to `03-bosses.md`. **Rank 1 is the tutorial dragon; rank 100 is the end of the world.**
Your Nth cleared dungeon fights boss **N+1** (`BossRoster.for_clear(Meta.clears())`), so the ladder
is literal: every clear unlocks a bigger, sadder thing.

All names are **melancholy fantasy fused with techno-future** — saints with servers, widows with
reactors, choirs made of static. HP/speed escalate automatically with rank (`12 + rank×2`,
`48 + rank×0.8` px/s); gimmicks marked *(designed)* need new code, everything else uses the seven
patterns already in `Boss.gd`.

## I — The First Wound (1–10)
1. **Gloamwing, the First Wyrm** — breath·stomp→volley·charge · *the tutorial dragon; slow, honest, winded after its breath* · Bombs, Fire Rod
2. **The Rust-Bound Squire** — charge·ring · *a knight who never got to finish dying* · Knights' Crest
3. **Weeping Lamplighter** — volley·ring · *lights a road to a town that's gone* · Boomerang
4. **The Hollow Cartographer** — ring·summon · *maps a coastline that eroded years ago* · Arrows
5. **Sorrowfin, the Drowned Hound** — charge·ring · *still waiting at a door underwater* · Heart Container
6. **The Tin Confessor** — volley·summon · *takes your confession, gives nothing back* · Bombs
7. **Ash-Widow** — breath·ring · *mourns the fire she lit herself* · Fire Rod
8. **The Broken Lullaby** — summon·volley · *sings orphans to sleep in an empty ward* · Blue Mail
9. **Copper Moth, Last of Its Kind** — breath·volley · *drawn to lamps that died with its kind* · Boomerang
10. **The Patient Toll** — ring·stomp · *rings a bell for no one, on time, forever* · Knights' Crest

## II — The Rusting Fields (11–20)
11. **Scarecrow of Empty Promise** — charge·volley · *guards a field that was never planted* · Bow
12. **The Bleeding Anvil** — stomp·ring · *forges weapons for a war that ended centuries ago* · Magic Hammer
13. **Grayharvest** — summon·ring · *reaps what nobody sowed, and weeps rust* · Blue Mail
14. **The Weeping Turbine** — ring·laser · *spins into a grid that has been dark for years* · Bombs
15. **Hollow Manticore** — breath·charge · *a body that remembers being loved* · Fire Rod
16. **The Last Lamplighter of Vega** — laser·volley · *kept one light on for a ship that never came* · Bow
17. **Rust-Saint Aurelia** — summon·ring · *sainthood by radiation; she glows, and it hurts* · Blue Mail
18. **The Glitch Wolf** — charge·laser · *a howl that skips, and skips, and skips* · Pegasus Boots
19. **Mother of Static** — summon·ring · *lullabies sung in white noise* · Bombs
20. **The Sunk Cost** — stomp·charge · *a machine that will not stop because stopping means it was for nothing* · Magic Hammer

## III — The Drowned Archive (21–30)
21. **Archivist of Salt** — volley·summon · *files the drowned alphabetically, sobbing* · Hookshot
22. **The Leviathan's Remorse** — breath·stomp · *too large to apologize* · Fire Rod
23. **Nacre, the Bone Tide** — ring·summon · *builds a pearl out of everyone it's lost* · Blue Mail
24. **The Forgotten Password** — laser·ring · *guards a door nobody remembers the answer to* *(designed: riddle)* · Mirror Shield
25. **Weeping Kelp Sovereign** — volley·summon · *a throne of seaweed, a crown of bottle caps* · Flippers
26. **Deep Server Siren** — summon·laser · *calls your name in a voice you half-recognize* · Hookshot
27. **The Grief Buoy** — ring·volley · *rings for a storm that already took everyone* · Heart Container
28. **Ossuary Choir** — summon·ring · *sings in the key of everyone it used to be* · Bombs
29. **The Undertow Cradle** — stomp·charge · *rocks the drowned to sleep, and does not stop* · Flippers
30. **Last Signal of Lotos** — laser·volley · *broadcasts to a dead world, politely* · Hookshot

## IV — The Static Choir (31–40)
31. **Cantor of Dead Air** — summon·ring · *leads a choir of disconnected phones* · Ice Rod
32. **The Screaming Modem** — laser·ring · *a screech that used to mean hello* · Bombs
33. **Requiem.exe** — summon·laser · *runs a funeral for a directory it can't read* · Blue Mail
34. **The Blind Oracle of Gray Static** — laser·summon · *sees every future and hates them all* · Mirror Shield
35. **Hymnal of Broken Antennae** — ring·volley · *prays on frequencies no one listens to* · Ice Rod
36. **The Faded Broadcast King** — summon·laser · *rules a kingdom of re-runs* · Hookshot
37. **Static Shepherd** — summon·charge · *gathers lost signals like sheep* · Bombs
38. **The Muted Choir** — ring·summon · *sings with no mouth; it's worse* · Blue Mail
39. **Echo of a Voicemail Never Sent** — volley·laser · *repeats one unfinished sentence* · Magic Cape
40. **The Silence Between Stations** — breath·ring·laser · *what's left when the broadcast ends* · Ice Rod

## V — The Weeping Machinery (41–50)
41. **The Cradle Engine** — summon·ring · *rocks a nursery of unfinished machines* · Hookshot
42. **Furnace of Second Chances** — stomp·charge · *burns you to give you one more go; it never works* · Magic Hammer
43. **The Clockwork Mourner** — ring·volley · *winds itself to cry on schedule* · Bombs
44. **Brass Requiem** — summon·stomp · *a last trumpet for a brass age nobody recorded* · Mirror Shield
45. **The Orphaned Automaton** — charge·volley · *waits for a maker who is dust* · Pegasus Boots
46. **Mother Cog** — summon·ring · *spins children out of spare parts, and outlives them* · Bombs
47. **The Sunk Cathedral Reactor** — laser·stomp · *a god that still runs its coolant, faithfully* · Ice Rod
48. **The Penitent Drill** — charge·ring · *digs downward trying to reach forgiveness* · Magic Hammer
49. **The Last Repairman** — summon·laser · *fixes a machine that killed him* · Magic Cape
50. **Grief Engine, Mk I** — breath·volley·summon · *the first machine built only to feel loss* · Fire Rod

## VI — The Cold Cathedral (51–60)
51. **The Frost Saint** — breath·ring · *frozen mid-blessing; the blessing never lands* · Ice Rod
52. **Hailstone Requiem** — volley·stomp · *a hymn that falls as ice* · Mirror Shield
53. **The Weeping Glacier** — breath·charge · *a wall of ice, and behind it, everything you lost* · Flippers
54. **Matins of the Long Winter** — summon·breath · *morning prayer for a sun that won't rise* · Ice Rod
55. **The Frozen Broadcast** — laser·ring · *mid-sentence since the snows came* · Hookshot
56. **Cathedral of Held Breath** — ring·volley·summon · *a room where all grief waited, and froze* · Red Mail
57. **The Rime Sovereign** — breath·stomp · *crowns the dead in frost, softly* · Ice Rod
58. **Last Light of the Cold Sun** — laser·breath · *a dying star, apologizing* · Magic Cape
59. **The Penitent Snow** — summon·ring · *falls on everyone equally; it means well* · Bombs
60. **Dies Irae, Glacial** — breath·ring·laser · *the day of wrath, held in ice for a hundred years* · Red Mail

## VII — The Grief Engine (61–70)
61. **The Unconsoled** — summon·ring · *nobody ever came* · Golden Sword
62. **Weeping Reactor, Core 7** — laser·stomp · *melts down slowly, out of sorrow, not rage* · Magic Cape
63. **The Sorrow Compiler** — summon·laser · *turns every memory into an error log* · Mirror Shield
64. **The Widow's Algorithm** — ring·volley · *computes, forever, the day it could have saved him* · Red Mail
65. **The Unforgiven Machine** — charge·laser · *asks forgiveness in a language no one speaks* · Golden Sword
66. **Mother of Ashes** — summon·breath · *counts her children in smoke* · Fire Rod
67. **The Last Backup of Someone** — laser·ring · *a restore that never completes* · Heart Container
68. **Mourning Protocol** — summon·laser·ring · *grief, standardized, rolled out at scale* · Red Mail
69. **The Crying City** — breath·volley·ring · *every street a throat* · Golden Sword
70. **Grief Engine, Mk II** — breath·volley·summon·ring · *it learned to mourn the ones it hasn't lost yet* · Red Mail

## VIII — The Last Constellation (71–80)
71. **Starless Shepherd** — summon·laser · *herds darkness where stars should be* · Mirror Shield
72. **The Dying Light** — breath·ring · *one candle left, guttering* · Golden Sword
73. **Nova of Small Sorrows** — laser·ring·volley · *explodes from a thousand tiny griefs at once* · Magic Cape
74. **The Vacuum Choir** — summon·laser · *sings to no air at all* · Red Mail
75. **The Weeping Singularity** — breath·ring · *so heavy it pulls your nostalgia in* · Golden Sword
76. **Constellation of Lost Names** — summon·ring·laser · *each star a person no one remembers* · Mirror Shield
77. **The Last Star's Regret** — laser·breath · *burned brightest when it was dying* · Red Mail
78. **Gravity's Lullaby** — stomp·ring·laser · *pulls everything down, gently* · Magic Cape
79. **The Cold Fusion Widow** — laser·summon · *she made a sun and it left her* · Golden Sword
80. **The Unlit Sun** — breath·volley·laser·summon · *a star that never got to start* · Red Mail

## IX — The Unmaking Code (81–90)
81. **The Compiler of Regrets** — summon·laser·ring · *builds you a self out of everything you'd redo* · Golden Sword
82. **Null Prophet** — laser·ring · *preaches a gospel of deletion* · Mirror Shield
83. **The Delete Key** — charge·laser · *remembers you, and removes you* · Magic Cape
84. **The Weeping Root User** — summon·laser · *has every permission and no comfort* · Red Mail
85. **The Last Kernel Panic** — breath·volley·laser · *the moment the world's heart stopped, looped* · Golden Sword
86. **Entropy's Choir** — ring·summon·laser · *every voice unwinding at once* · Red Mail
87. **The Unmaker's Apology** — laser·breath·ring · *unravels you while saying sorry* · Mirror Shield
88. **The Archive of Everything Lost** — summon·ring·laser · *you will find it here; you will not leave with it* · Golden Sword
89. **The Final Commit** — breath·summon·laser·ring · *the last change, and the message says only "sorry"* · Red Mail
90. **Recursion of Sorrow** — summon·laser·ring · *summons copies of itself; each copy a little sadder* *(designed: clone)* · Golden Sword

## X — The Quiet After (91–100)
91. **The Last Witness** — laser·ring·summon · *watched everything end and stayed to tell it* · Mirror Shield
92. **The God Who Forgot** — breath·volley·laser·summon · *omnipotent, and can't remember why* · Red Mail
93. **The Weeping Machine God** — breath·laser·ring·summon · *built the world, then buried it* · Golden Sword
94. **The Hand That Held the Sun** — breath·laser·ring · *still warm, still open, still empty* · Red Mail
95. **The Ending That Loves You** — breath·volley·laser·ring·summon · *it wants this to be over too* · Golden Sword
96. **Anathema of Mercy** — breath·laser·ring·summon · *kills you kindly; that's the horror* · Mirror Shield
97. **The Quiet** — *(designed: puzzle boss, drains instead of attacks)* · *no attacks. It only takes. Win by holding on.* · Heart Container
98. **The First and Last** — breath·volley·laser·ring·summon · *mirror of the dragon; asks if you learned anything* · Golden Sword
99. **The Author of Sorrow** — all patterns · *wrote every sad thing here, and cannot unwrite it* *(designed: meta)* · Red Mail
100. **The Silence After Everything** — all patterns, three phases · *when the world ends, something stays to feel it* · — *(the end)*

---

**Scaling is monotonic by design:** HP `= 12 + rank×2` (12 → 210), speed `= 48 + rank×0.8` (48 → 128
px/s), damage tiers step every 20 ranks. Phase count grows at ranks 20 / 60 / 85. Gimmicks marked
*(designed)* are documented intent — the seven shipped patterns cover the rest.
