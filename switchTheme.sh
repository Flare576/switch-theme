# This script sets environment variables that it expects other apps to understand/respect and
# Therefore doesn't work in a vacuum. Things that need to happen include:
# ".doNotCommit.theme" needs to be sourced
# .vimrc needs to include the UpdateTheme function, which also knows where the theme files are
#  - could be helped if env_var held the full path instead of just the name/filename
# omz also needs to be made aware of the new file location (during setup)
# actually, could just setup symlink during this script if it's not already there
# tmux should also just be setup with full path in envar
# bat should NOT have full path; we don't currently add any new themes, just reference ones it ships with

function st() {
  app_root="$(dirname "$(switchTheme.sh)")"
  themes="$app_root/themes"
  hasRun="false"
  # Each theme can have a number of "aliases", e.g. "dark", "night", "soldark"
  # Find matching alias (and warn if there's more than one)
  for config in "$themes"/**/config.yml; do
    [ -e "$config" ] || continue
    checkFor=( $(yaml "$config" "['alias']" | sed "s/[][',]//g") )
    # padding with spaces is a nice trick to guard against partial matches
    [[ " ${checkFor[@]} " =~ " $1 " ]] || continue
    if [ $hasRun = "true" ] ; then
      echo "There as a duplicate alias; using first found"
      return 1
    fi
    hasRun="true"
    theme_folder="$(dirname "$config")"
    [ -z "$THEME_CONFIG" ] && THEME_CONFIG="$HOME/.config/theme"
    cat << EOF > $THEME_CONFIG
export ST_VIM_THEME="$theme_folder/$(yaml "$config" "['vim']")"
export ST_TMUX_THEME="$theme_folder/$(yaml "$config" "['tmux']")"
source "$theme_folder/$(yaml "$config" "['zsh']")"
# bat doesn't use full paths; it ships with its themes
export BAT_THEME="$(yaml "$config" "['bat']")"
EOF
    source "$THEME_CONFIG"

    # refresh current zsh and tmux
    command -v tmux &> /dev/null && tmux source-file "$ST_TMUX_THEME" &> /dev/null
    # vim and zsh are configured to watch for changes on updates

    # cheat makes it pretty easy, so why not
    # because it edits a source-controlled file each time;TODO: see if we can avoid that
    if command -v cheat &> /dev/null ; then
      cheat_theme="$(yaml "$config" "['cheat']")"
      filename="$HOME/cheat/conf.yml"
      sed -i "" -e "s/^style:.*/style: $cheat_theme/" "$filename"
    fi

    # VSCode makes it pretty easy, so why not
    if command -v Code &> /dev/null ; then
      code_theme="$(yaml "$config" "['vscode']")"
      filename="$HOME/Library/Application Support/Code/User/settings.json"
      sed -i "" -e "s/\"workbench.colorTheme\":.*/\"workbench.colorTheme\": \"$code_theme\"/" "$filename"
    fi

    # Terminal emulators for different machines I use
    if command -v mintheme &> /dev/null ; then # WSL
      # https://github.com/mintty/utils/pull/2/files
      # patch submitted to mintheme; remove check when accepted (or declined)
      minttyTheme="$(yaml "$config" "['mintty']")"
      theme=$(mintheme --save $name/$minttyTheme | sed \
        -e '2!d' \
        -e 's/saved.\+''//')
      if [[ theme != *"tmux"* ]] ; then # declined
        echo $theme | sed -e 's/^/Ptmux;/'
      else # accepted
        echo $theme
      fi
    elif command -v defaults &> /dev/null ; then # OSX
      title="$(yaml "$config" "['terminal']")"
      # TODO: should be a way to check if this value is already there...
      # THIS WON'T WORK: editing the plist requires a restart
      theme="${theme_folder}/${title}.terminal"
      bare=$(sed -n '/<dict>/,/<\/dict>/p' "$theme")
      defaults write com.apple.Terminal "Window Settings" -dict-add "$title" "$bare"
      defaults write com.apple.Terminal "Startup Window Settings" "$title"    # Set new profile to startup
      defaults write com.apple.Terminal "Default Window Settings" "$title"    # Set new profile to default
      osascript "$app_root/themeOpenTerminals.scpt" "$title" # Update active/existing windows
    elif command -v dconf &> /dev/null ; then  # Chromebook
      # copy/paste desired theme over "current" theme (which should be "Flare")
      symId=":6d940353-9091-4d32-b491-95a661527d08/"
      basePath="/org/gnome/terminal/legacy/profiles:"
      gnomeId="$(yaml "$config" "['gnome']")"
      updateTo=$(dconf dump "$basePath/$gnomeId" | sed -e "s/visible-name='.*'/visible-name='Flare'/")
      echo "$updateTo" | dconf load $basePath/$symId
    fi # else we're probably not running a terminal emulator on this machine
  done
}

function yaml() {
  python3 -c "import yaml;print(yaml.safe_load(open('$1'))$2)"
}

# ZSH/OMZ "switchTheme" functionality to watch for changes to theme settings
function zsh_theme_refresh() {
  [ -z "$THEME_CONFIG" ] && THEME_CONFIG="$HOME/.config/theme"
  [ -f "$THEME_CONFIG" ] && source "$THEME_CONFIG"
  [ -f "$ST_ZSH_THEME" ] && source "$ST_ZSH_THEME"
}
precmd_functions=(${precmd_functions[@]} zsh_theme_refresh)

# When sourced
# see https://stackoverflow.com/a/28776166
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ $sourced -eq 1 ]; then
  [ -z "$THEME_CONFIG" ] && THEME_CONFIG="$HOME/.config/theme"
  [ -e "$THEME_CONFIG" ] || st dark
  source "$THEME_CONFIG"
else
  printf "$0"
fi
