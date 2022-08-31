#!/bin/bash

# To get the theme data, run
# plist $HOME/Library/Preferences/com.apple.Terminal.plist
# then find the key starting with `<key>THEMENAME</key>`
# Exporting the terminal from within Terminal also works if you do this
# https://apple.stackexchange.com/questions/99027/how-can-i-import-a-terminal-file-using-the-command-line

THEMES="$1"

# convenience method
function st_yaml() {
  line=$(grep $2 $1)
  echo ${line#$2: }
}

# If we find `defaults`, we can assume we're on OSX
if ! command -v defaults &> /dev/null ; then # OSX
  exit
fi

for theme in $THEMES/**/*.terminal; do
  config="$(dirname "$theme")/config.yml"
  [ -e "$config" ] || continue
  themeName=$(st_yaml "$config" "terminal")
  bare=$(sed -n '/<dict>/,/<\/dict>/p' "$theme")
  echo "Importing $themeName Terminal Theme"
  defaults write com.apple.Terminal "Window Settings" -dict-add "$themeName" "$bare"
done

divider="[41m[30m*[32m*[33m*[34m*[35m*[36m*[37m*[38m*[90m*[91m*[92m*[93m*[94m*[95m*[30m*[32m*[33m*[34m*[35m*[36m*[37m*[38m*[90m*[91m*[92m*[93m*[94m*[95m*[41m[30m*[32m*[33m*[34m*[35m*[0m"
printf "\n${divider}\n[31mYOU WILL NEED TO RESTART TERMINAL[0m\nWe edited its plist\n${divider}\n"
