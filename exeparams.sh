#!/bin/bash

# Function to decode URL
decode_url() {
    url="$1"
    decoded_url=$(python -c "import urllib.parse as urlparse; print(urlparse.unquote(urlparse.unquote('$url')))")
    echo "$decoded_url"
}

# Function to extract parameters without values
extract_parameters() {
    url="$1"

    # Remove fragment identifier, if present
    url=${url%%#*}

    # Extract the base URL
    base_url=${url%%\?*}

    # Remove the base URL and extract the query string
    query_string="${url#*\?}"

    # Extract individual parameters without values
    IFS='&' read -ra parameters <<< "$query_string"
    filtered_params=()
    for param in "${parameters[@]}"; do
        param_key=${param%%=*}
        if ! [[ $param_key =~ https?://.* ]] && [[ ${param_key} != "" ]]; then
            filtered_params+=("$param_key")
        fi
    done

    # Print the extracted parameters
    if [ "${#filtered_params[@]}" -gt 0 ]; then
        printf '%s\n' "${filtered_params[@]}"
    fi
}

# Process URLs passed as command-line arguments
if [ $# -gt 0 ]; then
    for url in "$@"; do
        decoded_url=$(decode_url "$url")
        extract_parameters "$decoded_url"
    done
else
    # Read URLs from standard input
    while read -r url; do
        decoded_url=$(decode_url "$url")
        extract_parameters "$decoded_url"
    done
fi
