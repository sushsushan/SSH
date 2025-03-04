cat cache.json | tr -d '{}"' | sed 's/\],/\]\n/g' | awk -F '[:,]' '
BEGIN {
    print "┌────────────────────────────────┬────────────┬──────────────────────────────────────────┐";
    print "│ Domain Name                    │ Type       │ Document Root                            │";
    print "├────────────────────────────────┼────────────┼──────────────────────────────────────────┤";
}
{
    domain_name = $1;
    domain_type = $4;
    document_root = $6;

    gsub(/^[ \t]+|[ \t]+$/, "", domain_name);
    gsub(/^[ \t]+|[ \t]+$/, "", domain_type);
    gsub(/^[ \t]+|[ \t]+$/, "", document_root);

    if (domain_name != "" && domain_type != "" && document_root != "") {
        printf "│ %-30s │ %-10s │ %-40s │\n", domain_name, domain_type, document_root;
    }
}
END {
    print "└────────────────────────────────┴────────────┴──────────────────────────────────────────┘";
}'
