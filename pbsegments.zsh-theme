CURRENT_BG='NONE'

# Characters
RIGHT_SEGMENT_SEPARATOR="\ue0b4" # Right segment separator
LEFT_SEGMENT_SEPARATOR="\uE0B6"  # Left segment separator
PLUSMINUS="\u00b1"               # Plus-minus symbol
GIT_BRANCH="\ue0a0"              # Git branch symbol
DETACHED="\u27a6"                # Detached HEAD symbol
ROOT_ICON="\u26a1"               # Lightning bolt (for root user)
BACKGROUND_TASK="\u2699"         # Gear icon (for background tasks)

# Colors
BACKGROUND_COLOR="#303030"       # General background color
TEXT_COLOR="white"               # General text color
CLEAN_GIT_BRANCH_COLOR="green"   # Color for a clean Git branch
DIRTY_GIT_BRANCH_COLOR="yellow"  # Color for a dirty Git branch
DIRTY_GIT_SYMBOL_COLOR="#ff005f" # Color for symbols in a dirty Git branch
CLEAN_GIT_SYMBOL_COLOR="#303030" # Color for symbols in a clean Git branch
PATH_BG_COLOR="black"            # Background color for the path
PATH_TEXT_COLOR="cyan"           # Text color for the path
USER_BG_COLOR="#303030"          # Background color for the username
USER_TEXT_COLOR="yellow"         # Text color for the username
PROMPT_SYMBOL_COLOR="cyan"       # Color for the prompt symbol '>'

# Function to create a prompt segment with optional background and foreground colors
prompt_segment() {
  local bg fg text
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  
  # Left separator (text color = current segment color, background = transparent)
  if [[ $CURRENT_BG != 'NONE' ]]; then
    print -n "%{%F{$1}%K{NONE}%}$LEFT_SEGMENT_SEPARATOR"
  fi
  
  # Segment text
  print -n "%{%K{$1}%}%{%F{$2}%} $3 %{%k%}"
  
  # Right separator (text color = current segment color, background = transparent)
  print -n "%{%F{$1}%K{NONE}%}$RIGHT_SEGMENT_SEPARATOR %{%k%}%{%f%}"
  
  # Update current background
  CURRENT_BG=$1
}

# Function to end the prompt, closing any open segments
prompt_end() {
  if [[ $CURRENT_BG != 'NONE' ]]; then
    print -n "%{%F{$CURRENT_BG}%}$RIGHT_SEGMENT_SEPARATOR"
  fi
  print -n "%{%k%}%{%f%}"
  CURRENT_BG='NONE'
}

# Function to display Git branch and status in the prompt
prompt_git() {
  local ref dirty clean bgclr fgclr repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)
  
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2>/dev/null) || ref="➦ $(git rev-parse --short HEAD 2>/dev/null)"

    if [[ -n $dirty ]]; then
      clean=' !'
      bgclr=$DIRTY_GIT_BRANCH_COLOR # Color for a dirty branch
      fgclr=$DIRTY_GIT_SYMBOL_COLOR # Color for symbols in a dirty branch
    else
      clean=' ✔'
      bgclr=$CLEAN_GIT_BRANCH_COLOR # Color for a clean branch
      fgclr=$CLEAN_GIT_SYMBOL_COLOR # Color for symbols in a clean branch
    fi

    # Add left separator before the Git branch
    print -n "%{%F{$bgclr}%K{NONE}%}$LEFT_SEGMENT_SEPARATOR"

    # Git branch text
    print -n "%{%K{$bgclr}%}%{%F{$fgclr}%} ${ref/refs\/heads\//$GIT_BRANCH}$clean %{%k%}"

    # Update current background
    CURRENT_BG=$bgclr
  fi
}

# Function to display the username in the prompt
prompt_context() {
  prompt_segment $USER_BG_COLOR $USER_TEXT_COLOR "$USER"
  CURRENT_BG='NONE'  # Reset background after displaying the username
}

# Function to display the current directory in the prompt
prompt_dir() {
  # Add left separator before the current directory
  print -n "%{%F{$PATH_BG_COLOR}%K{NONE}%}$LEFT_SEGMENT_SEPARATOR"
  prompt_segment $PATH_BG_COLOR $PATH_TEXT_COLOR "%~"
}

# Function to display the status symbols in the prompt
prompt_status() {
  local symbols
  symbols=()
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{$PATH_COLOR}%}$BACKGROUND_TASK" # Background tasks color
  [[ -n "$symbols" ]] && prompt_segment $BACKGROUND_COLOR default "$symbols"
}

## Main prompt

# Function to build the main prompt
build_prompt() {
  RETVAL=$?
  print -n "\n"
  prompt_status
  prompt_dir
  prompt_context
  prompt_git
  prompt_end
  print -n "\n"
  local prompt_symbol=">"
  local prompt_symbol_color=$PROMPT_SYMBOL_COLOR
  # Prompt symbol '>' without background, only text color
  print -n "%{$(print -P "%F{$prompt_symbol_color}")%}${prompt_symbol}"
}

# Set the prompt
PROMPT='%{%f%b%k%}$(build_prompt) '   # Main prompt
RPROMPT='%{%f%b%k%}$(prompt_status) ' # Right prompt (displays status)

