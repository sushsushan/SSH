uapi ResourceUsage get_usages | awk '
BEGIN {
    printf "%-26s %-14s %-14s\n", "Description", "Maximum", "Usage";
    print "------------------------------------------------------------";
}
/description:/ {desc=$2}
/maximum:/ {
    max=clean_value($2);
    if (max == "~") max = "Unlimited";
    else if (desc ~ /(Disk|Bandwidth)/) max = convert_to_gb(max);
}
/usage:/ {
    usage=clean_value($2);
    if (desc ~ /(Disk|Bandwidth)/) usage = convert_to_gb(usage);
    
    # Adjust spacing for "MySQL®" since it has a special character
    if (desc ~ /MySQL/) {
        printf "%-27s %-14s %-14s\n", desc, max, usage;
    } else {
        printf "%-26s %-14s %-14s\n", desc, max, usage;
    }
}

function clean_value(value) {
    gsub(/'\''/, "", value);  # Removes unwanted single quotes
    return value;
}

function convert_to_gb(value) {
    if (value ~ /^[0-9]+$/) {
        return sprintf("%.2f GB", value / (1024*1024*1024));  # Convert bytes to GB
    }
    return value;
}'
