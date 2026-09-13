# NEU BOT v1.19

Based on v1.18 BTG assembly/approach/assault logic.

Changes:
- global `aircraftlight` cooldown: 360 seconds (6 minutes), so new air support cannot be requested more often than once per 6 minutes;
- cooldown starts when an aircraftlight request is accepted;
- repeated requests from another BTG or immediate replacement after aircraft loss are blocked until cooldown expires;
- log markers: `AIR COOLDOWN START` and `AIR COOLDOWN BLOCK`.

Dependencies are the active v1.18 core/logic/map/data files; the v1.19 patch is loaded before v1.18 logic and intercepts all `aircraftlight` spawn requests.
