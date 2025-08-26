#!/usr/bin/env bash
# Volume + Mic control with notifications (pamixer + swaync)

iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

# --- helpers ---
is_muted() { pamixer --get-mute; }                   # "true"/"false"
vol_num() { pamixer --get-volume; }                  # 0..150
mic_muted() { pamixer --default-source --get-mute; } # "true"/"false"
mic_vol() { pamixer --default-source --get-volume; } # 0..100

# --- icons ---
get_icon() {
  if [[ "$(is_muted)" == "true" || "$(vol_num)" -eq 0 ]]; then
    echo "$iDIR/volume-mute.png"
  else
    local v
    v="$(vol_num)"
    if ((v <= 30)); then
      echo "$iDIR/volume-low.png"
    elif ((v <= 60)); then
      echo "$iDIR/volume-mid.png"
    else
      echo "$iDIR/volume-high.png"
    fi
  fi
}

get_mic_icon() {
  if [[ "$(mic_muted)" == "true" || "$(mic_vol)" -eq 0 ]]; then
    echo "$iDIR/microphone-mute.png"
  else
    echo "$iDIR/microphone.png"
  fi
}

# --- notifications ---
notify_vol() {
  if [[ "$(is_muted)" == "true" ]]; then
    notify-send -e -u low -i "$iDIR/volume-mute.png" \
      -h string:x-canonical-private-synchronous:volume_notif \
      " Volume" " Muted"
  else
    local v
    v="$(vol_num)"
    notify-send -e -u low -i "$(get_icon)" \
      -h int:value:"$v" \
      -h string:x-canonical-private-synchronous:volume_notif \
      " Volume Level" " ${v}%"
    [[ -x "$sDIR/Sounds.sh" ]] && "$sDIR/Sounds.sh" --volume
  fi
}

notify_mic() {
  local v
  v="$(mic_vol)"
  local icon
  icon="$(get_mic_icon)"
  if [[ "$(mic_muted)" == "true" ]]; then
    notify-send -e -u low -i "$iDIR/microphone-mute.png" \
      -h string:x-canonical-private-synchronous:volume_notif \
      " Microphone" " Muted"
  else
    notify-send -e -u low -i "$icon" \
      -h int:value:"$v" \
      -h string:x-canonical-private-synchronous:volume_notif \
      " Mic Level" " ${v}%"
  fi
}

# --- actions ---
inc_volume() {
  if [[ "$(is_muted)" == "true" ]]; then toggle_mute; else
    pamixer -i 5 --allow-boost --set-limit 150 && notify_vol
  fi
}

dec_volume() {
  if [[ "$(is_muted)" == "true" ]]; then toggle_mute; else
    pamixer -d 5 && notify_vol
  fi
}

toggle_mute() {
  if [[ "$(is_muted)" == "false" ]]; then
    pamixer -m && notify_vol
  else
    pamixer -u && notify_vol
  fi
}

toggle_mic() {
  if [[ "$(mic_muted)" == "false" ]]; then
    pamixer --default-source -m && notify_mic
  else
    pamixer --default-source -u && notify_mic
  fi
}

inc_mic_volume() {
  if [[ "$(mic_muted)" == "true" ]]; then toggle_mic; else
    pamixer --default-source -i 5 && notify_mic
  fi
}

dec_mic_volume() {
  if [[ "$(mic_muted)" == "true" ]]; then toggle_mic; else
    pamixer --default-source -d 5 && notify_mic
  fi
}

# --- CLI ---
case "${1:-}" in
--get) echo "$(vol_num)%" ;;
--inc) inc_volume ;;
--dec) dec_volume ;;
--toggle) toggle_mute ;;
--toggle-mic) toggle_mic ;;
--mic-inc) inc_mic_volume ;;
--mic-dec) dec_mic_volume ;;
--get-icon) get_icon ;;
--get-mic-icon) get_mic_icon ;;
*) echo "$(vol_num)%" ;;
esac

