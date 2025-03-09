#!/bin/bash

# Define Colors
orange="\e[48;5;202m  \e[0m"   # Saffron
white="\e[48;5;15m  \e[0m"     # White
green="\e[48;5;28m  \e[0m"     # Green
blue="\e[34m●\e[0m"           # Ashoka Chakra
shadow="\e[48;5;236m  \e[0m"   # 3D Shadow effect

# Clear the screen
clear

# Printing the 3D Indian Flag
echo -e "\n"

# Top Saffron Band
for i in {1..5}; do
  echo -e "     $orange$orange$orange$orange$orange$orange$orange$orange$orange$orange$orange$orange$orange$orange$orange$orange$shadow"
done

# Middle White Band with Ashoka Chakra
for i in {1..2}; do
  echo -e "     $white$white$white$white$white$white$white$white $blue $white$white$white$white$white$white$white$shadow"
done

# Bottom Green Band
for i in {1..5}; do
  echo -e "     $green$green$green$green$green$green$green$green$green$green$green$green$green$green$green$green$shadow"
done

# Ashoka Chakra Circle Representation
echo -e "\n          \e[34m⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫ ⚫\e[0m\n"

# Bold Jai Hind Message with a 3D Feel
echo -e "\n\e[1;33m              🇮🇳  JAI HIND!  🇮🇳\e[0m\n"
