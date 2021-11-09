#!/bin/bash
THEMES="$1"

# convenience method
function st_yaml() {
  python3 -c "import yaml;print(yaml.safe_load(open('$1'))$2)"
}

# If we find `defaults`, we can assume we're on OSX
if ! command -v defaults &> /dev/null ; then # OSX
  exit
fi

for theme in $THEMES/themes/**/*.terminal; do
  config="$(dirname "$theme")/config.yml"
  [ -e "$config" ] || continue
  themeName=$(st_yaml "$config" "['terminal']")
  bare=$(sed -n '/<dict>/,/<\/dict>/p' "$theme")
  echo "Importing $themeName Terminal Theme"
  defaults write com.apple.Terminal "Window Settings" -dict-add "$themeName" "$bare"
done
