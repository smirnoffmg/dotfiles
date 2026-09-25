#!/bin/sh
# Prints battery flow in watts and time left for the tmux status line: "+42W 0:58".
# Sign: + charging, - draining. Time is to empty when draining, to full when charging,
# as pmset (powerd) reports it, or computed from the instant power while pmset has none.
# Prints nothing when the battery is charged or idle on AC; tmux.conf hides the module then.
batt=$(pmset -g batt)
case $batt in *'; charged;'*) exit 0 ;; esac
est=$(printf '%s\n' "$batt" | grep -oE '[0-9]+:[0-9]{2} remaining' | cut -d' ' -f1)
ioreg -rn AppleSmartBattery | awk -v est="$est" '
  /^ *"Voltage" = /                 { mv = $3 }
  /^ *"InstantAmperage" = /         { ma = $3 }
  /^ *"AppleRawCurrentCapacity" = / { cur = $3 }
  /^ *"AppleRawMaxCapacity" = /     { max = $3 }
  function hm(min) { return sprintf("%d:%02d", int(min / 60), int(min % 60)) }
  END {
    # ioreg prints negative current as an unsigned 64-bit number; doubles cannot hold
    # it exactly, so take 2^64 - x from the last ten digits (|current| is far below 1e10).
    if (length(ma) >= 19) {
      ma = 3709551616 - substr(ma, length(ma) - 9)
      if (ma < 0) ma += 1e10
      ma = -ma
    }
    w = mv * ma / 1e6
    # Held at the optimized-charging limit the flow is a fraction of a watt: nothing to show.
    if (w > -0.5 && w < 0.5) exit
    left = ""
    # pmset prints "(no estimate)" for a while after unplugging or waking, and "0:00"
    # when it has nothing to count down.
    if (est == "0:00") est = ""
    if (w < 0)                left = est != "" ? " " est : " " hm(cur / -ma * 60)
    else if (w > 0 && max > cur) left = est != "" ? " " est : " " hm((max - cur) / ma * 60)
    printf "%+.0fW%s", w, left
  }'
