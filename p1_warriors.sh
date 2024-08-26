#!/bin/bash

# Script Name: p1_warriors.sh
# Description: This script runs httpx to enumerate alive hosts from a target list, then runs nuclei on the results to find vulnerabilities, and sends notifications via Telegram.
# Author: Vivek Kumar Kashyap (https://bugcrowd.com/realvivek)
# Usage: ./p1_warriors.sh [options] -l <target_file>
# Options:
#   -l <target_file>  : Specify the target file for httpx or nuclei. If -n is used, it is the file directly used by nuclei.
#   -s <severities>   : Comma-separated list of severities to filter (e.g., critical,high,medium,low). Default is all severities.
#   -n                : Skip running httpx, use the provided target file directly for nuclei.

# Function to display startup animation
display_startup_animation() {
    clear
    echo -e "\nStarting P1’s..."
    sleep 1
}

# Telegram configuration
TELEGRAM_BOT_TOKEN="7474418301:AAEQwa4SDAg3oZipZW8dD_d-Z19J_lvuuuE"
TELEGRAM_CHAT_ID="994467652"

# Function to send message to Telegram
send_telegram_message() {
    local message=$1
    local url="https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage"
    local payload="chat_id=$TELEGRAM_CHAT_ID&text=$message"
    curl -s -X POST "$url" -d "$payload" > /dev/null
}

# Function to run httpx
run_httpx() {
    local target_file=$1
    local output_file=$2
    echo "Running httpx on $target_file..."
    httpx -l "$target_file" -o "$output_file"
}

# Function to run nuclei
run_nuclei() {
    local target_file=$1
    local output_file=$2
    local severity_args=$3

    if ! command -v ./nuclei &> /dev/null; then
        echo "Error: nuclei command not found. Please install nuclei." >&2
        exit 1
    fi

    echo "Running nuclei on $target_file..."
    ./nuclei -l "$target_file" -o "$output_file" -et ~/nuclei-templates/technologies/ -etags network,headers,dns,ssl,pop3 -jsonl -timeout 18 -severity "$severity_args" -bs 100 -c 25 -rl 340 -eid weak-cipher-suites,self-signed-ssl,revoked-ssl-certificate,unauthenticated-varnish-cache-purge,untrusted-root-certificate,expired-ssl,mismatched-ssl-certificate,missing-x-frame-options,mismatched-ssl,CVE-2000-0114,CVE-2017-5487,aws-object-listing,CVE-2021-24917,exposed-sharepoint-list,git-mailmap
}

# Function to process nuclei output
process_nuclei_output() {
    local input_file=$1
    local severities=$2
    jq -r --argjson severities "$(echo "$severities" | jq -R -s 'split(",")')" \
        'select(.info.severity as $sev | $severities | index($sev)) | 
        "\(.info.name)\nSeverity: \(.info.severity)\nHost: \(.host)\nAffected URL: \(.["matched-at"])\nTemplate Detail: \(.template)\n"' \
        "$input_file" | tee -a nuclei_output.txt | while IFS= read -r line; do
        send_telegram_message "$line"
    done
}

# Default values
severities="critical,high,medium,low"
skip_httpx=false

# Parse arguments
while getopts ":l:s:n" opt; do
    case ${opt} in
        l)
            target_file=${OPTARG}
            ;;
        s)
            severities=${OPTARG}
            ;;
        n)
            skip_httpx=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

if [ -z "${target_file}" ]; then
    echo "Target file is required. Use -l <target_file>" >&2
    exit 1
fi

httpx_output="httpx_output.txt"
nuclei_output="nuclei_output.json"

# Display startup animation
display_startup_animation

if [ "$skip_httpx" = true ]; then
    echo "Skipping httpx. Using the provided target file directly."
    run_nuclei "$target_file" "$nuclei_output" "$severities"
else
    run_httpx "$target_file" "$httpx_output"
    run_nuclei "$httpx_output" "$nuclei_output" "$severities"
fi

process_nuclei_output "$nuclei_output" "$severities"
