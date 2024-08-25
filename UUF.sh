#!/bin/bash

# Default values
TARGET_FILE="targets.txt"
URL=""

# Parse command line options
while getopts "l:u:" opt; do
  case ${opt} in
    l )
      TARGET_FILE=$OPTARG
      ;;
    u )
      URL=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-l target_file] [-u url]"
      exit 1
      ;;
  esac
done

# Ensure all necessary tools are available
for tool in gauplus waymore katana arjun urldedupe; do
  if ! command -v $tool &> /dev/null; then
    echo "$tool is not installed. Please install it and try again."
    exit 1
  fi
done

# Check if the targets file exists
if [ -z "$URL" ] && [ ! -f "$TARGET_FILE" ]; then
  echo "$TARGET_FILE not found. Please provide the file with domain names."
  exit 1
fi

# Create a directory to store results
mkdir -p recon_results

# Function to process a single domain
process_domain() {
  local DOMAIN=$1
  echo "Processing domain: $DOMAIN"
  echo "Starting URL gathering for $DOMAIN..."

  # Use gauplus to gather URLs based on provided options
  if [ -n "$URL" ]; then
    echo "Running gauplus with subdomains for $DOMAIN..."
    gauplus -b woff,css,png,svg,jpg,woff2,jpeg,gif,svg -subs -random-agent "$DOMAIN" > gauplus.txt || echo "gauplus failed."
  else
    echo "Running gauplus without subdomains for $DOMAIN..."
    gauplus -b woff,css,png,svg,jpg,woff2,jpeg,gif,svg -random-agent "$DOMAIN" > gauplus.txt || echo "gauplus failed."
  fi

  # Use waymore to gather URLs
  echo "Running waymore..."
  waymore -i "$DOMAIN" -mode U --retries 3 --timeout 10 --memory-threshold 95 --processes 5 --config ~/.config/waymore/config.yml > waymore.txt || echo "waymore failed."

  # Use katana to gather URLs
  echo "Running katana..."
  katana -u "$DOMAIN" -duc -silent -nc -jc -kf -fx -xhr -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg > katana.txt

  # Combine and deduplicate URLs
  echo "Combining URLs..."
  cat gauplus.txt waymore.txt katana.txt | urldedupe > final_urls.txt

  # Run arjun to discover parameters
  echo "Running arjun..."
  arjun -i final_urls.txt -t 10 -m GET,POST -oT arjun_params.txt

  echo "Processing completed for $DOMAIN."
}

# Process URL if provided
if [ -n "$URL" ]; then
  DOMAIN=$(echo "$URL" | awk -F/ '{print $1}')
  process_domain "$DOMAIN"
else
  # Loop through each domain in the targets file
  while IFS= read -r DOMAIN; do
    process_domain "$DOMAIN"
  done < "$TARGET_FILE"
fi

echo "Recon completed. Check recon_results directory for final results."

# Combine all arjun_params.txt files into one
find recon_results -name "arjun_params.txt" -exec cat {} + > final_arjun_params.txt

# Combine all final_urls.txt files into one
find recon_results -name "final_urls.txt" -exec cat {} + > final_urls.txt

echo "Final results saved in final_arjun_params.txt and final_urls.txt"
