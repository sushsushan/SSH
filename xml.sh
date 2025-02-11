#!/bin/bash

# Confirm user is in the correct directory or prompt for path
echo "Current directory: $(pwd)"
echo "Enter path to WordPress directory or press enter to continue: "
read path
if [[ -n "$path" ]]; then
  cd "$path"
fi

# Check if WordPress Importer is installed
if ! wp plugin is-installed wordpress-importer; then
  echo "WordPress Importer needs to be installed."
  read -p "Do you want to install and activate WordPress Importer now? [y/n] " choice
  case "$choice" in
    y|Y )
      wp plugin install wordpress-importer --activate
      if ! wp plugin is-installed wordpress-importer; then
        echo "Failed to install WordPress Importer plugin. Please install it manually and try again."
        exit 1
      fi
      echo "WordPress Importer plugin installed and activated."
      ;;
    n|N )
      echo "Please install WordPress Importer plugin manually and try again."
      exit 1
      ;;
    * )
      echo "Invalid choice. Please try again."
      exit 1
      ;;
  esac
fi

# Get site name
site=$(wp option get blogname)
echo "This path has site: $site"

# Get domain name
domain=$(wp option get home)
echo "Domain: $domain"

# List all .xml files in current directory
xml_files=$(ls -1 *.xml 2>/dev/null)
if [[ -z "$xml_files" ]]; then
  echo "No .xml files found in current directory."
  exit 1
fi
echo "XML files: $xml_files"

# Prompt for filename of .xml file
echo "Enter the name of the XML file to import or press enter to skip: "
read filename
if [[ -n "$filename" ]]; then
  # Import .xml file with WP CLI
  wp import "$filename" --authors=create
  # Check if import was successful and retry if not
  while [[ $? -ne 0 ]]; do
    echo "Import failed. Retrying in 10 seconds..."
    sleep 10
    wp import "$filename" --authors=create
  done
  echo "Import successful!"
else
  echo "No XML file selected. Skipping import."
fi

# Count number of successful imports
import_count=$(grep -c "Imported post" wp-content/debug.log)
echo "$import_count files imported."
