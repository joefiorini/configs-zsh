###### Autoloads
autoload -U promptinit
autoload colors         # named color arrays
colors

# use zmv plugin for easier bulk file renaming
autoload -U zmv
# load cdr plugin for remembering chpwd history
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

###### Options
setopt cdablevars       # cd into named vars
setopt prompt_subst     # enable var expansion in prompt

source ~/.zsh/history.zsh
source ~/.zsh/completions.zsh
source ~/.zsh/git.zsh
source ~/.zsh/title.zsh

# Force emacs mode
set -o emacs

###### Aliases

alias ll='/bin/ls -Gla'
alias gf='git fetch'
alias cwip='time cucumber -p wip'
alias cuke='time cucumber -p default'
alias cpkey="cat ~/.ssh/id_rsa.pub | pbcopy"
alias gignore="echo $1 >> .gitignore"
alias g='git'
alias mmv='noglob zmv -W'
alias nw="/Applications/node-webkit.app/Contents/MacOS/node-webkit"
alias og='bundle open $1'

alias scantiff='scanimage --format=tiff --mode=Color --resolution=600dpi'
alias scanpreview='scanimage --format=tiff --mode=Color --resolution=600dpi --preview=yes --preview-speed=yes'

alias ql='qlmanage -p 2>/dev/null'
alias git-brlog='for k in $(git branch -r | perl -pe '\''s/^..(.*?)( ->.*)?$/\1/'\''); do echo -e $(git show --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k -- | head -n 1)\\t$k; done | sort -r'

alias tt='open -a Textastic "$@"'

###### Speed up tab completion
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

###### Functions

set-terminal-tab-title() {
  print -Pn "\e]1;$1:q\a"
}

sync-tab-title-with-tmux() {
  set-terminal-tab-title "$(tmux display-message -p '#S')"
}

add-host() {
  echo $* | sudo tee -a /etc/hosts
}

pless() {
  pygmentize $1 | less -r
}

vim() {
  $EDITOR $*
}

cdvim(){
  (cd $1 && vim .)
}

reload() {
  source ~/.zshenv
  source ~/.zshrc
}

customize() {
  vim ~/.zshrc && reload
}

whodoneit() {
  for x in $(git grep --name-only $1); do
    git blame -f -- $x | grep $1;
  done
}

blog-code() {

  LANG=$2
  test $LANG || LANG="ruby"

  echo "Formatting your $LANG code."

  pygmentize -f html -l $LANG $1 | tidy -omit -wrap 80 -bare --show-warnings no --output-html yes --doctype omit --tidy-mark no | sed 's/<title><\/title>//' | pbcopy
}

slide-code() {
  LANG=$2
  test $LANG || LANG="ruby"

  echo "Formatting your $LANG code."

  pygmentize -f rtf -l $LANG $1 | pbcopy
}

tellme() {
  eval "$*"
  growlnotify -t "Command Complete" -s -m "$*"
}

git-url() {
  code_opt=""
  if [ "$2" -ne "" ]; then
    code_opt="-F code=$2"
  fi

  curl -i http://git.io -F "url=$1" "$code_opt"
}

# make meta+bksp kill path components
function backward-kill-partial-word {
        local WORDCHARS="${WORDCHARS//[\/.]/}"
        zle backward-kill-word "$@"
}

zle -N backward-kill-partial-word
bindkey '^Xw' backward-kill-partial-word

print_table () {
  sed -n "/\"$1\".* do |t|$/,/end$/ s/.*/&/ p" db/schema.rb
}

gtd() {
  if [[ -n "$@" ]]; then
    task="- $@"
    [[ $DEBUG = "1" ]] && echo "*$task*"
    echo "Writing new task to $TASKS_FILE..."
    backup="$TASKS_FILE.`date +%s`.backup"
    cat $TASKS_FILE > $backup
    echo "$task" | cat - $TASKS_FILE | sponge $TASKS_FILE
    changed=$(diff -w --unchanged-line-format= $TASKS_FILE $backup)
    if [[ "$changed" != "$task" ]]; then
      echo "Parity check failed, your tasks file is backed up at $backup. Please investigate and restore if necessary."
      echo "$changed"
    fi
  else
    e ~/Dropbox/clocktower/taskpaper.taskpaper
  fi
}

# rackup app in current directory
ru(){
  if [ -f 'config.ru' ]; then
    rackup config.ru $*
  elif [ -f 'app.rb' ]; then
    rackup app.rb $*
  else
    rackup $*
  fi
}

pretty_path() {
  name=$1
  [[ "$name" =~ ^"$HOME"(/|$) ]] && name="~${name#$HOME}"
  echo $name
}

# update tmux window title with pwd if in tmux session
update_tmux_title() {
  window_index=$(tmux display-message -p "#I" 2> /dev/null)
  [[ $? -eq 0 ]] && tmux rename-window -t $window_index $(pretty_path $(pwd))
}

###### Prompt

autoload -U spectrum
spectrum

autoload -Uz vcs_info

local smiley="%(?,%{$FG[064]%}⊕%{$reset_color%},%{$FG[160]%}⊗%{$reset_color%})"

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%{$FG[037]%}+%{$reset_color%}"
zstyle ':vcs_info:*' unstagedstr "%{$FG[160]%}!%{$reset_color%}"
zstyle ':vcs_info:*' formats "(%{$FG[064]%}%b%{$reset_color%}%u%c)"
zstyle ':vcs_info:*' actionformats \
        "[%{$FG[064]%}%r%{$reset_color%}|%{$FG[160]%}%a%{$reset_color%}]"

local jobs="%(1j, %{$FG[160]%}%j%{$reset_color%},)"
PROMPT='${smiley}${jobs} '
RPROMPT='%{$FG[136]%}$(rbenv prompt)%{$reset_color%} ${vcs_info_msg_0_}'

precmd_functions=($precmd_functions vcs_info update_tmux_title)

###### hub
command_exists hub && eval "$(hub alias -s zsh)"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### fasd
eval "$(fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install posix-alias)"

j() {
  if [ -x "$@" ]; then
    cd "$@"
  else
    fasd_cd -d "$@"
  fi
}
