# NEU BOT v1.14

Derived from v1.13.

Changes:
- Failed attack result immediately stops and rebuilds the direction instead of waiting for unit destruction.
- Failed targets are counted and target selection prefers another enemy point.
- Combat-ineffective group (no tanks and <=1 infantry after grace period) rebuilds automatically.
- Survivors retreat to the nearest own point before rebuild.
- Aircraft light support patrols a corridor between the current attack target and the nearest own point, switching with the group's new target.
- New `artsupport` role is selected strictly by tag `t(... artsupport ...)` before the generic `nobot` exclusion.
- `artsupport` stays on an own safe rear point and relocates if that point is lost or the supported attack changes.
- Artillery safe point is selected geometrically for maximum clearance from enemy-held points, with target distance as tie-breaker.
- Fixed tank-loss replacement so it remains assigned to the dead tank's group when that group is still active.

Support patrol interval: 20 seconds (`SupportPatrolSec`).
