#!/bin/bash
# Mintty apparently works by copying the theme files into "$(wslpath $APPDATA)/mintty/themes"
# If I recall, this is because the themes need to be outside of the unix filespace so Windows can reach them;
# I'm not working on WSL much right now, so just keep that pattern
if ! command -v mintheme &> /dev/null ; then # WSL
  exit
fi
THEMES="$1"

mintty_home="$(wslpath $APPDATA)/mintty"

mkdir -p "$mintty_home/themes"
pushd "$mintty_home" > /dev/null
git clone "https://github.com/mintty/utils.git" &> /dev/null
cp "$THEMES"/**/*.minttyrc "$mintty_home/themes"
echo "Font=JetBrains Mono
FontHeight=14
FontWeight=400
CtrlShiftShortcuts=yes
ClipShortcuts=yes
ComposeKey=alt
CursorType=block
Transparency=off
AltFnShortcuts=yes
ZoomShortcuts=no
ScrollMod=off
Term=xterm-256color
ThemeFile=flare.minttyrc
Columns=150" > "$mintty_home/config"

# Add the utils to the path for theme changing
echo "PATH=$mintty_home/utils:\$PATH" > "$HOME/dotfiles/.doNotCommit.d/.doNotCommit.wsl"

