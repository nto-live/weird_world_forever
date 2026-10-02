class_name Feel
extends RefCounted
## FEEL / TUNABLES — the numbers that make it "feel like LTTP".
##
## Every value here is a CONFIG value, not a magic constant scattered through code.
## Confidence: [exact] = verified from the original; [approx] = tuned to feel, verify by playtest.
## See 00-LTTP-controls-and-feel.md for sources and reasoning.

# ---- Movement (pixels per SECOND; the original is ~1.5-2.0 px/frame at 60 fps) ----
const WALK_SPEED := 96.0          # [approx] ~1.6 px/frame at 60 fps
const DASH_SPEED := 190.0         # [approx] ~2x walk (Pegasus Boots)
## LTTP's original quirk: each axis advances at walk rate, so diagonals travel ~1.41x faster.
## true = authentic (faster diagonals); false = normalized (fairer). DECISION POINT (Kiro Q6).
const DIAGONAL_IS_FASTER := false

# ---- Combat ----
const SWORD_REACH := 14.0         # [approx] ~1 tile past the body
const SWORD_WIDTH := 12.0         # [approx]
const SWING_TIME := 0.18          # [approx] active hitbox window of a plain swing
const SPIN_DURATION := 0.36       # [approx] spin attack window
const SPIN_CHARGE_TIME := 2.0     # [exact] hold ~2 s to charge the Spin Attack
const SPIN_DAMAGE_MULT := 2.0     # [exact] spin does ~2x a swing
const ATTACK_COOLDOWN := 0.10     # [approx]

# ---- Health / damage ----
const MAX_HEARTS := 6             # [exact-ish] starting hearts (design choice)
const DAMAGE_UNIT_PER_HEART := 8  # [exact] the game's damage tables use 8 units = 1 heart
const IFRAME_TIME := 0.8          # [approx] TUNE FIRST — the single most important feel var
const KNOCKBACK_SPEED := 240.0    # [approx]
const HURT_STUN := 0.22           # [approx] control loss after a hit
const BLOCK_DOT := 0.5            # facing dot threshold for the passive shield

# ---- TMX / world ----
const TILE := 16                  # [exact] SNES-era tile size
const ROOM_W := 16                # [exact] 16 tiles wide  = 256 px
const ROOM_H := 14                # [exact] 14 tiles tall   = 224 px
