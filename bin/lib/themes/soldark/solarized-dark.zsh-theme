#
# Solarized Dark Theme, based on Cobalt2 by Wes Bos
#
# # README: See README.md
source "$(dirname "$0")/../solarized-core.zsh"

FINAL_BG='008'
FINAL_FG='010'
SEGMENT_SEPARATOR=''

PERSONAL_BG='000'
PERSONAL_ICON='🥃'

PATH_FG='010'
PATH_BG='008'

SYMBOL_BG='006'
SYMBOL_FG='001'
FAILED_ICON='✘'
BACKGROUND_ICON='⚙'
ALIAS_ICON='⚡'

GIT_CLEAN_FG='002'
GIT_DIRTY_FG='005'
GIT_CLEAN_BG='000'
GIT_DIRTY_BG='000'

CURRENT_BG='NONE' # Initial value of "NONE"

PROMPT='%{%f%b%k%}$(build_prompt) '
