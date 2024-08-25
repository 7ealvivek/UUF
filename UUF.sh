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
for tool in gau waybackurls katana arjun urldedupe; do
  if ! command -v $tool &> /dev/null; then
    echo "$tool is not installed. Please install it and try again."
    exit 1
  fi
done

# Function to process a single domain
process_domain() {
  local DOMAIN=$1
  local CLEAN_DOMAIN=$(echo "$DOMAIN" | sed 's/[^a-zA-Z0-9]/_/g')  # Sanitize domain for filenames

  echo "Processing domain: '$DOMAIN'"  # Debugging output with quotes
  
  echo "Starting URL gathering for $DOMAIN..."

  # Define output filenames
  local ALL_URLS_FILE="${CLEAN_DOMAIN}_all_urls.txt"
  local FINAL_URLS_FILE="${CLEAN_DOMAIN}_final_urls.txt"
  local ARJUN_PARAMS_FILE="${CLEAN_DOMAIN}_arjun_params.txt"

  # Run the URL gathering tools and combine outputs
  gau "$DOMAIN" | tee -a "$ALL_URLS_FILE"
  waybackurls "$DOMAIN" | tee -a "$ALL_URLS_FILE"
  katana -u "$DOMAIN" -d 10 -u -c -silent -nc -jc -kf -fx -xhr -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg | tee -a "$ALL_URLS_FILE"

  # Deduplicate URLs and save final results
  urldedupe -s "$ALL_URLS_FILE" > "$FINAL_URLS_FILE"

  # Run arjun to discover parameters and save the output
  arjun -i "$FINAL_URLS_FILE" -t 10 -m GET,POST -oT "$ARJUN_PARAMS_FILE"
}

# Process URL if provided
if [ -n "$URL" ]; then
  echo "URL provided: '$URL'"  # Debugging output with quotes
  DOMAIN=$(echo "$URL" | awk -F/ '{print $1}')
  echo "Extracted domain from URL: '$DOMAIN'"  # Debugging output with quotes
  process_domain "$DOMAIN"
else
  # Loop through each domain in the targets file
  while IFS= read -r DOMAIN; do
    echo "Read line from file: '$DOMAIN'"  # Debugging output with quotes
    DOMAIN=$(echo "$DOMAIN" | awk -F/ '{print $1}')  # Ensure domain extraction
    echo "Extracted domain from file line: '$DOMAIN'"  # Debugging output with quotes
    process_domain "$DOMAIN"
  done < "$TARGET_FILE"
fi

echo "Recon completed. Check the current directory for final results."

echo "Final results saved as:"
echo "*.txt files with domain-specific names."
