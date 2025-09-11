#/bin/bash
# Check for Distrobox, assume Steam Deck
# Just copy the profile and colorschemes into ~/.loca/share/konsole. Ez Pz

THEMES="$1"

# convenience method
function st_yaml() {
  line=$(grep $2 $1)
  echo ${line#$2: }
}

if [ -z "$CONTAINER_ID" ]; then
  exit
fi

konsoleProfiles="$HOME/.local/share/konsole"

find "$THEMES" -type f -name "*.profile" | while read -r theme; do
  baseDir="$(dirname "$theme")"
  config="${baseDir}/config.yml"
  [ -e "$config" ] || continue
  themeName=$(st_yaml "$config" "konsole")
  echo "Importing $themeName"
  cp "${baseDir}/${themeName}.colorscheme" "$konsoleProfiles"
  cp "$theme" "$konsoleProfiles"
done
