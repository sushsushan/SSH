#!/bin/bash

# Define colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No color

# Fetch domain details using uapi
output=$(uapi DomainInfo domains_data --output=json 2>/dev/null)

# Ensure output is not empty
if [[ -z "$output" ]]; then
    echo -e "${RED}Error: No data received from cPanel API.${NC}"
    exit 1
fi

# Extract domain details using jq for better parsing
domains=($(echo "$output" | jq -r '.result.data[] | .domain'))
documentroots=($(echo "$output" | jq -r '.result.data[] | .documentroot'))
types=($(echo "$output" | jq -r '.result.data[] | .type'))

# Check if jq successfully extracted data
if [[ ${#domains[@]} -eq 0 ]]; then
    echo -e "${RED}Error: No domains found.${NC}"
    exit 1
fi

# Initialize counters
main_count=0
addon_count=0
parked_count=0
subdomain_count=0

# Sort domains into categories
main_domains=()
main_paths=()
addon_domains=()
addon_paths=()
parked_domains=()
parked_paths=()
subdomains=()
sub_paths=()

for ((i=0; i<${#domains[@]}; i++)); do
    case "${types[i]}" in
        main)
            main_domains+=("${domains[i]}")
            main_paths+=("${documentroots[i]}")
            ((main_count++))
            ;;
        parked)
            parked_domains+=("${domains[i]}")
            parked_paths+=("${documentroots[i]}")
            ((parked_count++))
            ;;
        addon)
            addon_domains+=("${domains[i]}")
            addon_paths+=("${documentroots[i]}")
            ((addon_count++))
            ;;
        subdomain)
            subdomains+=("${domains[i]}")
            sub_paths+=("${documentroots[i]}")
            ((subdomain_count++))
            ;;
    esac
done

# Set column widths
domain_width=50
path_width=80
type_width=20

# Function to print a table border
print_border() {
    printf "${MAGENTA}+%-${domain_width}s+%-${path_width}s+%-${type_width}s+${NC}\n" \
        "$(printf -- '-%.0s' $(seq 1 $domain_width))" \
        "$(printf -- '-%.0s' $(seq 1 $path_width))" \
        "$(printf -- '-%.0s' $(seq 1 $type_width))"
}

# Print header
print_border
printf "${MAGENTA}| ${BLUE}%-${domain_width}s${MAGENTA} | ${YELLOW}%-${path_width}s${MAGENTA} | ${GREEN}%-${type_width}s${MAGENTA} |\n${NC}" "Domain Name" "Document Root/Path" "Type"
print_border

# Function to print domain rows with colors
print_domains() {
    local color=$1
    local domain_list=("${!2}")
    local path_list=("${!3}")
    local type_name=$4

    for ((i=0; i<${#domain_list[@]}; i++)); do
        printf "${MAGENTA}| ${NC}%-${domain_width}s ${MAGENTA}| ${NC}%-${path_width}s ${MAGENTA}| ${color}%-${type_width}s ${MAGENTA}|\n${NC}" \
            "${domain_list[i]}" "${path_list[i]}" "$type_name"
    done
}

# Print domains in the specified order with colors
print_domains "$CYAN" main_domains[@] main_paths[@] "Main"
print_domains "$RED" parked_domains[@] parked_paths[@] "Parked"
print_domains "$YELLOW" addon_domains[@] addon_paths[@] "Addon"
print_domains "$GREEN" subdomains[@] sub_paths[@] "Subdomain"

# Print bottom border
print_border

# Print summary
total_domains=$((main_count + addon_count + parked_count + subdomain_count))

echo -e "\n${CYAN}Summary:${NC}"
printf "  ${BLUE}%-20s ${NC}%d\n" "Main Domains:" "$main_count"
printf "  ${RED}%-20s ${NC}%d\n" "Parked Domains:" "$parked_count"
printf "  ${YELLOW}%-20s ${NC}%d\n" "Addon Domains:" "$addon_count"
printf "  ${GREEN}%-20s ${NC}%d\n" "Subdomains:" "$subdomain_count"
printf "  ${MAGENTA}%-20s ${NC}%d\n\n" "Total Domains:" "$total_domains"
