# Function to create virtual sink and loopback sources
create_combined_sink() {
    pactl load-module module-null-sink sink_name=Combined

    # Find and loopback the headset output source
    headset_output=$(pactl list sources | grep 'Name' | grep 'monitor' | cut -d ' ' -f2)
    pactl load-module module-loopback sink=Combined source="$headset_output"

    # Find and loopback the microphone source (using role)
    microphone_source=$(pactl list sources | grep 'Role:' | grep 'microphone' | cut -d ' ' -f2)
    pactl load-module module-loopback sink=Combined source="$microphone_source"
}

create_combined_sink