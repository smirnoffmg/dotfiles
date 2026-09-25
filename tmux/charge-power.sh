#!/bin/sh
# Prints charger input, battery flow in watts and time left for the tmux status line:
# "󰚥 12.7W 󰁹 -16.8W 1:43" on AC, "󰁹 -16.8W 1:43" on battery. Battery sign: + charging,
# - draining. Time is to empty when draining, to full when charging, as pmset (powerd)
# reports it; "~" marks a figure computed from the instant power while pmset has none.
est=$(pmset -g batt | grep -oE '[0-9]+:[0-9]{2} remaining' | cut -d' ' -f1)
ioreg -rn AppleSmartBattery | awk -v est="$est" '
  /^ *"ExternalConnected" = /       { ac = ($3 == "Yes") }
  /^ *"Voltage" = /                 { mv = $3 }
  /^ *"InstantAmperage" = /         { ma = $3 }
  /^ *"AppleRawCurrentCapacity" = / { cur = $3 }
  /^ *"AppleRawMaxCapacity" = /     { max = $3 }
  match($0, /"SystemPowerIn"=[0-9]+/) { pin = substr($0, RSTART + 16, RLENGTH - 16) }
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
    left = ""
    # pmset prints "(no estimate)" for a while after unplugging or waking, and "0:00"
    # when it has nothing to count down.
    if (est == "0:00") est = ""
    if (w < 0)                left = est != "" ? " " est : " ~" hm(cur / -ma * 60)
    else if (w > 0 && max > cur) left = est != "" ? " " est : " ~" hm((max - cur) / ma * 60)
    batt = sprintf("󰁹 %+.1fW%s", w, left)
    if (ac) printf "󰚥 %.1fW %s", pin / 1000, batt
    else    printf "%s", batt
  }'
