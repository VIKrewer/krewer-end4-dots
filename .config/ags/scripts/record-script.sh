#!/usr/bin/env bash

getdate() {
    date '+%Y-%m-%d_%H.%M.%S'
}

getaudiooutput() {
    pactl list sources | grep 'Name' | grep 'Headset' | grep 'output' | cut -d ' ' -f2
}

# Function to create virtual sink and loopback sources (Uncomment it if you want to create a virtual audio only when running this code)
# create_combined_sink() {
#     pactl load-module module-null-sink sink_name=Combined

#     # Find and loopback the headset output source
#     headset_output=$(pactl list sources | grep 'Name' | grep 'Headset' | grep 'output' | cut -d ' ' -f2)
#     pactl load-module module-loopback sink=Combined source="$headset_output"

#     # Find and loopback the microphone source (using role)
#     microphone_source=$(pactl list sources | grep 'Role:' | grep 'microphone' | cut -d ' ' -f2)
#     pactl load-module module-loopback sink=Combined source="$microphone_source"
# }

# Function to get the active monitor name
getactivemonitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

mkdir -p "$(xdg-user-dir VIDEOS)"
cd "$(xdg-user-dir VIDEOS)" || exit

if pgrep wf-recorder > /dev/null; then
    notify-send "Recording Stopped" "Stopped" -a 'record-script.sh' &
    pkill wf-recorder &

    # uncomment when creating virtual audio only when running code
    # pactl unload-module module-null-sink
    # pactl unload-module module-loopback
else
    notify-send "Starting recording" 'recording_'"$(getdate)"'.mp4' -a 'record-script.sh'
    if [[ "$1" == "--sound" ]]; then
        wf-recorder --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t --geometry "$(slurp)" --audio="$(getaudiooutput)" & disown
    elif [[ "$1" == "--fullscreen-sound" ]]; then
        wf-recorder -o $(getactivemonitor) --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t --audio="$(getaudiooutput)" & disown
    elif [[ "$1" == "--fullscreen-mic" ]]; then
        create_combined_sink
        wf-recorder -o $(getactivemonitor) --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t --audio="Combined.monitor" & disown 
    elif [[ "$1" == "--fullscreen" ]]; then
        wf-recorder -o $(getactivemonitor) --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t & disown
    else
        wf-recorder --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t --geometry "$(slurp)" & disown
    fi
fi
