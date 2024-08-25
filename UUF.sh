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
for tool in gau waybackurls katana arjun urldedupe jq; do
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
  local DOMAIN_DIR="recon_results/$(echo "$DOMAIN" | sed 's/[^a-zA-Z0-9]/_/g')"
  mkdir -p "$DOMAIN_DIR"
  cd "$DOMAIN_DIR" || exit

  echo "Starting URL gathering for $DOMAIN..."

  # Run the URL gathering tools
  gau --o gau.txt "$DOMAIN"
  waybackurls "$DOMAIN" > waybackurls.txt
  katana -u "https://$DOMAIN" -d 10 -silent -o katana.json

  # Combine and deduplicate URLs
  jq -r '.urls[]' katana.json >> all_urls.txt
  cat gau.txt waybackurls.txt >> all_urls.txt
  urldedupe -s all_urls.txt > final_urls.txt

  # Run arjun to discover parameters
  arjun -i final_urls.txt -t 10 -m GET,POST -oT arjun_params.txt

  cd - || exit
}

# Process URL if provided
if [ -n "$URL" ]; then
  DOMAIN=$(echo "$URL" | awk -F/ '{print $3}')
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
