#!/bin/bash
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
