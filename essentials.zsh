# vim: fdl=0 fdm=marker fmr={{{,}}}
#                                          __   .__         .__
#   ____    ______  ______  ____    ____ _/  |_ |__|_____   |  |    ______
# _/ __ \  /  ___/ /  ___/_/ __ \  /    \\   __\|  |\__  \  |  |   /  ___/
# \  ___/  \___ \  \___ \ \  ___/ |   |  \|  |  |  | / __ \_|  |__ \___ \
#  \___  >/____  >/____  > \___  >|___|  /|__|  |__|(____  /|____//____  >
#      \/      \/      \/      \/      \/                \/            \/
# FIGMENTIZE: essentials

# The idea of this file is to be a complete zshrc containing the bare essentials
# for a good quality-of-life experience with zsh. It is similar in scope to my
# vim-essentials. It tries not to break too much if something unexpected
# happens.

# I am now staunchly against customisation frameworks for zsh. IMO, most of what
# they do is obscured and makes things hard to debug. I prefer to just configure
# things in zsh, myself.

# This file consists of various excerpts from files that are sourced when you
# start zsh from all over my system. Advanced users may wish to distribute parts
# of this file over zprofile, zshenv, profile, xinitrc, xprofile, etc.

# OVERRIDE_TERM=${OVERRIDE_TERM:-1}
# OVERRIDE_COMPINIT=${OVERRIDE_COMPINIT:-1}

# {{{ EXPORTS

if [ -n "$OVERRIDE_TERM" ]; then
    export TERM=xterm-256color
fi

# set all of these default-y programs

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

# probably not what you're using
# export TERMINAL='termite'

export BROWSER='firefox'
export READER='zathura'

# make BSD utilities be coloured in
export CLICOLOR=1

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"

export LC_CTYPE=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8
export LANG=en_GB.UTF-8

# Make less clever about ANSI sequences, plus case insensitive search
export LESS="-Ri"

# expose columns and lines to commands that are run. This is useful
export COLUMNS LINES

# make escape key go faster. I think this is a number of centiseconds? wth
export KEYTIMEOUT=5

# }}}

# {{{ ALIASES AND FUNCTIONS

# try to populate $LS_COLORS.
if [ -z "$LS_COLORS" ] && 2>&1 >/dev/null command -v dircolors; then
    eval "$(dircolors)"
fi

# global aliases. Whenever you have the unescaped string ... as an argument to a
# command, it expands to ../..
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias d='dirs -v | head -10'

# Make the "help" command both exist and be more bash-like and useful. `help` is
# like `man` but more powerful. You can do eg "help autoload" if you don't know
# what autoload is.
if 2>&1 >/dev/null alias run-help; then
    unalias run-help
fi
autoload -Uz run-help
alias help='run-help'

# fun easter eggs. Try typing ^X^T or tetriscurses
autoload -Uz tetris
zle -N tetris
bindkey -M main '^X^T' 'tetris'
autoload -Uz tetriscurses

# suffix aliases.
# Means that eg if you try to "run" a file with an extension of .txt or .py as a
# command, it will be opened in vim. Can be used on multiple files at once
alias -s {txt,md}="${EDITOR:-vim}"
alias -s {png,jpg,jpeg}="${IMG_VIEWER:-feh}"
alias -s pdf="${READER:-evince}"

# "List Xecutables" - excludes completion functions.
alias lx='print -rl -- ${(ko)commands} ${(ko)functions} ${(ko)aliases} | grep -v "^_"'

# silent alias (Like Vim's :silent)
alias silent='>/dev/null 2>&1 '

# switch on/switch off networking
alias airplane='nmcli radio all off'
alias unairplane='nmcli radio all on'

# make grep and friends case insensitive. Incidentally, you should install rg.
# It lets you recursively search a directory for a regular expression very very
# quickly.
alias grep='grep -i --color=auto'
alias ack='ack -i'
alias ag='ag -i'
alias rg='rg -i'

# DIY coloured man pages using an alias so it's faster
# colours personally engineered to not be utterly disgusting, unlike OMZ's
# colored-manpages, apparently.
# mb, md, so, us, me, se, ue respectively correspond to:
# start blinking - not sure what this is for actually
# start bold - used for section headers and key words
# start standout mode - used for statusline and search hits
# start underline mode - used for important words
# end all modes
# end standout
# end underline
#
# also, a bit of trickery to make the alias be on one line, but formatted over
# several, as some systems get themselves confused about \ns.
alias man="$(echo 'LESS_TERMCAP_mb="$(tput bold)$(tput setaf 6)"' \
                  'LESS_TERMCAP_md="$(tput bold)$(tput setaf 4)"' \
                  'LESS_TERMCAP_so="$(tput setab 0)$(tput setaf 7)"' \
                  'LESS_TERMCAP_us="$(tput setaf 2)"' \
                  'LESS_TERMCAP_me="$(tput sgr0)"' \
                  'LESS_TERMCAP_se="$(tput sgr0)"' \
                  'LESS_TERMCAP_ue="$(tput sgr0)"' \
                  'man')"

alias feh='feh -d'

alias tree="tree --dirsfirst"

# ls aliases, based on what the ls in PATH seems to be capable of
# https://stackoverflow.com/questions/1676426/how-to-check-the-ls-version
if >/dev/null 2>&1 ls --color -d /; then # GNU ls, probably
    # lc_all=c so that sorting is case sensitive, as it should be.
    alias ls='LC_ALL=C ls -h --group-directories-first --color=auto'
    # long listings with and without group of owner (List, Long List)
    alias l='ls -l -G'
    alias ll='ls -l'
    # long listing of all files (List All)
    alias la='ls -la'
    # long listing sorted by time (List Time)
    alias lt='\ls -ltrh --color=auto'
    # long listing sorted by size (List Bytes)
    alias lb='ls -lSr'
    # list directory arguments as directories, instead of listing their
    # contents. (List DIRectories)
    alias ldir='ls -l --directory'
    # sort by extension (List EXTensions)
    alias lext='ls -lX'
elif >/dev/null 2>&1 gls --color -d /; then # GNU ls is on the system as "gls"
    alias ls='LC_ALL=C gls -h --group-directories-first --color=auto'
    alias l='ls -l -G'
    alias ll='ls -l'
    alias la='ls -la'
    alias lt='\gls -ltrh --color=auto'
    alias lb='ls -lSr'
    alias ldir='ls -l --directory'
    alias lext='ls -lX'
elif >/dev/null 2>&1 ls -G -d /; then # BSD ls, probably (eg as on MacOS)
    alias ls='LC_ALL=C ls -h -G'
    alias lt='\ls -ltrh -G'
    alias l='ls -l -o'
    alias ll='ls -l'
    alias la='ls -la'
    alias ldir='ls -l -d'
    alias lb='ls -lSr'
else # some other ls (solaris?)
    # empty true to make bash happy
    true
fi

alias pgrep="pgrep -l"
alias pgrepl="pgrep -a"

# safety first
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# vim is now 60% faster to type than emacs
# This is an alias that I've quite badly gotten used to. Beware that you might
# accidentally open actual vi on systems where vi isn't symlinked to vim
alias vi=vim

# so I get my own vimrc when I use view
alias view='vim -R'

alias viz='"${EDITOR:-vim}" "${ZSHRC:-$HOME}/.zshrc"'
alias viv='"${EDITOR:-vim}" "$HOME/.vim/vimrc"'

# display my timetable for school using elinks
alias tt='elinks -dump -dump-width $COLUMNS "$HOME/Documents/timetable.html"'

# define the o alias to be a mimetype aware opener.
case "$(uname -s)" in
    Darwin)
        alias o=open
        ;;
    Cygwin)
        alias o=cygstart
        ;;
    *)
        if >/dev/null 2>&1 command -v mimeopen; then
            alias o=mimeopen
        elif >/dev/null 2>&1 command -v xdg-open; then
            alias o=xdg-open
        else
            alias o='echo "no idea mate" >&2'
        fi
        ;;
esac

# latex/pdf compilation related aliases
alias lmk='latexmk'
alias present='evince -s'

alias latex="latex -synctex=1 --shell-escape
                   -interaction=nonstopmode -halt-on-error";
alias pdflatex="pdflatex -synctex=1 -shell-escape
                   -interaction=nonstopmode -halt-on-error";
alias xelatex="xelatex -synctex=1 -shell-escape
                   -interaction=nonstopmode -halt-on-error";

# the space means that sudo can be followed by an alias (particularly things
# like sudo p for sudo pacman)
alias sudo='sudo '

# reload zsh configuration properly, by replacing the current shell with a fresh
# zsh. Make sure that zsh doesn't get any arguments. If you still have any jobs,
# it doesn't refresh.
alias z='if [ -z "$(jobs)" ]; then exec zsh; else jobs; fi #'

# restart or test wifi connection
alias wifirestart='sudo systemctl restart NetworkManager.service'
alias p88='ping 8.8.8.8 -c 20 -w 60'

# Easier to type than git, plus instead of showing help, make the default action
# be git status.
# Completions defined in ~/.zsh/completion.zsh, and in ~/.bash/bashrc
g() {
    if [ "$#" = 0 ]; then
        set -- status
    fi
    git "$@"
}

# Get a weather report, over http
wttr() {
    curl -H "Accept-Language: ${LANG%_*}" wttr.in/"${*:-Great_Shelford}"
}

# could also use 'fold -sw 80', although that could break URLs apparently
alias wrap='fmt -w 80'
alias unwrap='fmt -w 2500'

# somewhat more frivolous aliases below

alias rot13='tr "A-Za-z0-9" "N-ZA-Mn-za-m5-90-4"'
alias alpha='echo "abcdefghijklmnopqrstuvwxyz"'
alias ALPHA='echo "ABCDEFGHIJKLMNOPQRSTUVWXYZ"'
alias pang='echo "Sphinx of black quartz, judge my vow"'

# make figlet wrap text
if [ -n "$(echo | figlet -t 2>&1 || true)" ]; then
    FIG_FLAGS='-w "$COLUMNS"'
else
    FIG_FLAGS='-t'
fi
alias figlet="figlet -k $FIG_FLAGS"

# display all figlet fonts
figfonts() {
    local exts="$(printf "%s" '.*\.\('"$(
        { printf "flf tlf " ; figlet -I 5 } |
            sed -e 's/  */\\|/g')"'\)$')"
    echo "finding all $exts in $(figlet -I 2)"
    find "$(figlet -I 2)" -type f -regex "$exts" \
        -exec echo {} \; \
        -exec figlet -ktd "$(figlet -I 2)" -f {} "${1:-Test 123}" \; \
        -exec echo \;
}

# say all cows
saycows() {
    for i in $(cowsay -l | tail +2); do cowsay -f "$i" "$i"; done
}

# force lolcat to colour, so it can be piped. Who on earth pipes data to lolcat
# in order for lolcat NOT TO CHANGE IT???
alias lolcat='lolcat -f'

# self explanatory
alias starwars='tput setaf 220 && tput bold &&
                figlet -f starwars -w 80 "STAR WARS"'

partytime() {
    base64 --wrap=$COLUMNS /dev/urandom | lolcat -F 0.01 -p 1 |
    while read -r line; do
        echo "$line"
    done
}

# random {cowsay,cowthink}
alias rcowsay='cowsay -f $(cowsay -l | tail +2 | xargs shuf -n1 -e)'
alias rcowthink='cowthink -f $(cowsay -l | tail +2 | xargs shuf -n1 -e)'
# SINGLE QUOTES to stop the command substitution happening at startup
alias partycow='while true; do fortune | rcowsay; done | pv -qlL 3 | lolcat'
# go on a 23 day mad one
alias mathsparty='timestable -l 10000000 | pv -qlL 5 | lolcat -p 10 -F 0.01'

# internet related
alias parrot="curl parrot.live"

# alias this to something really common
# or better yet, write a function that randomly falls through to this but
# normally doesn't, or that only does this after being called twenty times
# you could obfuscate it by something like
# rot13 <<< evpx | zsh, assuming you have my glorious rot13 alias
alias rick='echo "critical system update; do not interrupt";
            CACA_DRIVER=ncurses mpv \
                "https://www.youtube.com/watch?v=dQw4w9WgXcQ" \
                -vo caca --really-quiet; echo "Never mind"'

# look cooler
alias cmatrix='cmatrix -abu 1'

alias mirrormirroronthewall='mpv /dev/video0'
alias mirrormirrorontheascii='CACA_DRIVER=ncurses mpv /dev/video0 -vo caca'
alias mirrormirroronthe16777216='mpv /dev/video0 -vo tct'

# fire up the webcam for a single frame to take a selfie. This is basically a
# joke, it's better to use for example MPV. See `alias mirrormirroronthewall`
selfie() {
    local selfie_loc
    selfie_loc="${1:-$HOME/Pictures/screenshots/selfie_$(date +%Y%m%d_%H%M%S).png}"
    mkdir -p "$(dirname "$selfie_loc")"
    echo "Taking selfie targeting $selfie_loc"
    ffmpeg -f video4linux2 -i /dev/video0 -ss 0:0:2 -frames 1 "$selfie_loc"
}

alias calcifer='{ >/dev/null 2>&1 command -v cacafire &&
                  { CACA_DRIVER=ncurses cacafire || true;
                  };
                } || aafire -driver curses'

# }}}

# {{{ PROMPT

# make rprompt go away when I move on. This hugely reduces clutter when you
# resize the screen a lot, as the active rprompt gets redrawn, and means you can
# easily copy/paste etc etc
setopt transient_rprompt

# prompt without any plugins or fancy fonts. Basically emulates the important
# bits of my powerline prompt
autoload -Uz vcs_info
function precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
# need to use %%b for bold off
zstyle ':vcs_info:*' actionformats \
    '%K{002}%F{000} (%s)-[%b|%a] %u%c%f%k'
zstyle ':vcs_info:*' formats \
    '%K{002}%F{000} (%s)-[%b] %u%c%f%k'
zstyle ':vcs_info:*' stagedstr "%K{003}*%K{002}"
zstyle ':vcs_info:*' unstagedstr "%K{001}+%K{002}"
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b:%r'
# don't waste time on VCS that nobody uses
zstyle ':vcs_info:*' enable git cvs svn hg
zstyle ':vcs_info:*' check-for-changes true

# right prompt with some information
status_prompt="%F{000}%(?.%F{002}OK .%K{001}%B%F{003} %? %b)"
shlvl_prompt="%(2L.%F{000}%K{003} %L .)"
hist_prompt="%K{004}%F{000} %h %k%f"
RPROMPT="$status_prompt$shlvl_prompt$hist_prompt"

function zle-line-init zle-keymap-select {
    case "$KEYMAP" in
        main|viins)
            vi_colour=006
            ;;
        vicmd)
            vi_colour=005
            ;;
        *)
            vi_colour=015
            ;;
    esac
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

host_prompt="%(!.%F{003}%K{001}.%F{000}%K{003}) %n@%m "
dir_prompt="%F{000}%K{004} %~ "
PROMPT=$'\n'"%F{\$vi_colour}┌─$host_prompt$dir_prompt%k\$vcs_info_msg_0_"$'\n%F{\$vi_colour}└─%f '
PROMPT2=".. "
RPROMPT2="%K{cyan} %^ %k"

# }}}

# {{{ COMPLETION

autoload -Uz compinit
if [ -n "$OVERRIDE_COMPINIT" ]; then
    compinit -u
else
    compinit
fi

# make the function g (defined earlier) complete like git
# https://stackoverflow.com/questions/4221239/zsh-use-completions-for-command-x-when-i-type-command-y
compdef '_dispatch git git' g

# completion insensitive to case and hyphen/underscores
# https://stackoverflow.com/questions/24226685/have-zsh-return-case-insensitive-auto-complete-matches-but-prefer-exact-matches
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' special-dirs true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH_CACHE_DIR

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

zstyle '*' single-ignored show

zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' completions 1
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' glob 1
zstyle ':completion:*' insert-unambiguous false
if [ -n "$LS_COLORS" ]; then
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
else
    zstyle ':completion:*' list-colors ''
fi
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' substitute 1
zstyle :compinstall filename "${ZDOTDIR:-$HOME}/.zshrc"

# Display red dots whilst waiting for completion.
function expand-or-complete-with-dots() {
    print -Pn "%{%F{red}......%f%}"
    zle expand-or-complete
    zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey -M main "^I" expand-or-complete-with-dots
# Shift-tab to complete backwards
# You should also be able to use ^N and ^P
bindkey -M main '^[[Z' reverse-menu-complete

# }}}

# {{{ OPTIONS

# complete with a menu
setopt menucomplete
# complete globs
setopt globcomplete
# allow completion from inside word
setopt complete_in_word
# jump to end of word when completing
setopt always_to_end
# ensure the path is hashed before completing
setopt hash_list_all
# use different sized columns in completion menu to cut down on space
setopt list_packed

# case insensitive glob
unsetopt case_glob
# zsh regex is case insensitive
unsetopt case_match
# use extended globs
setopt extendedglob
# allow ksh-like qualifiers before parenthetical glob groups
setopt ksh_glob
# allow patterns like programmeren/**.py (recursive without symlinks) and
# programmeren/***.py (recursive with symlinks), as shorthand for **/* and ***/*
setopt glob_star_short
# error if glob does not match
setopt nomatch

# Disable flow control. If you don't have this, ^S freezes the terminal and ^Q
# unfreezes it, which I find to be an annoying feature.
unsetopt flowcontrol
# do not allow > redirection to clobber files. Must use >! or >|
unsetopt clobber
# allow comments in interactive shell
setopt interactive_comments

# disowned jobs are automatically continued
setopt auto_continue
# check background jobs before exiting
setopt check_jobs

# keeping track of a directory stack.
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt auto_cd
# ignore duplicate directories, be silent, treat no argument as HOME
setopt pushd_ignore_dups
setopt pushd_silent
setopt pushd_to_home

# use basically unlimited history
export HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
export HISTSIZE=10000000
export SAVEHIST=10000000

# record timestamp of command in HISTFILE
setopt extended_history
# delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_expire_dups_first
# ignore duplicated commands history list
setopt hist_ignore_dups
# ignore commands that start with space
setopt hist_ignore_space
# show command with history expansion to user before running it
setopt hist_verify
# add commands to HISTFILE in order of execution. inc adds them directly at
# execution rather than when the shell exits.
setopt inc_append_history
# share command history data
setopt share_history
# expand ! csh style
unsetopt bang_hist
# remove superfluous whites
setopt hist_reduce_blanks
# don't immediately execute commands with history expansion
setopt hist_verify

# }}}

# {{{ KEYBINDINGS

# disables flow control (again, just to be on the safe side. makes this file
# easier to translate to Bash).
stty -ixon
alias reset='\reset; stty -ixon'

# vim mode bindings
bindkey -v
# alias these widgets so that zsh doesn't do the weird thing where it "protects"
# previously inserted text
# https://unix.stackexchange.com/questions/140770/how-can-i-get-back-into-normal-edit-mode-after-pressing-esc-in-zsh-vi-mode
bindkey -M main "^H" backward-delete-char
bindkey -M main "^?" backward-delete-char
bindkey -M main "^U" backward-kill-line
bindkey -M main "^W" backward-kill-word

# allow ctrl-p, ctrl-n for navigate history (standard behaviour)
bindkey -M main '^P' up-history
bindkey -M main '^N' down-history

bindkey -M main '^E' _expand_alias
bindkey -M vicmd '^E' _expand_alias
bindkey -M vicmd "K" run-help

# load a widget for command-line editing in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
# V for Vim. This key regrettably does not go into visual block mode in ZLE, so
# a fortunate side effect is that an advanced user looking for this
# functionality gets automatically propelled into vim.
bindkey -M vicmd '^V' edit-command-line

# ^R does a backwards incremental search
bindkey -M main '^R' history-incremental-pattern-search-backward

# }}}
