if status is-interactive
    function take
        if string match -qr '^([A-Za-z0-9]+@|https?|git|ssh|ftps?|rsync).*\.git/?$' $argv[1]
            git clone $argv[1]; and cd (basename (string replace -r '\.git$' '' $argv[1]))
        else
            mkdir -p $argv[1]; and cd $argv[1]
        end
    end

    function repeat
        for i in (seq $argv[1])
            $argv[2..-1]
        end
    end

    # faster command not found
    function fish_command_not_found
        __fish_default_command_not_found_handler $argv[1]
    end

    if command -q fasd
        # fasd
        function __fasd_init -e fish_postexec -d "fasd takes record of the directories changed into"
            set -lx RETVAL $status
            if test $RETVAL -eq 0 # if there was no error
                command fasd --proc (command fasd --sanitize "$argv" | tr -s " " \n) >/dev/null 2>&1 &
                disown
            end
        end

        function __fasd_print_completion
            set cmd (commandline -po)
            test (count $cmd) -ge 2; and fasd $argv $cmd[2..-1] -l
        end

        function fasd_cd -d "fasd builtin cd"
            if test (count $argv) -le 1
                command fasd "$argv"
            else
                fasd -e 'printf %s' $argv | read -l ret
                test -z "$ret"; and return
                test -d "$ret"; and cd "$ret"; or printf "%s\n" $ret
            end
        end

        function __fasd_print_completion
            set cmd (commandline -po)
            test (count $cmd) -ge 2; and fasd $argv $cmd[2..-1] -l
        end

        function c
            fasd_cd -d $argv
        end
        complete -c c -a "(__fasd_print_completion -d)" -f

        function fasd_inline
            set -l opts (fasd -lR (string replace -r '^,' '' $argv[1]))
            if test (count $opts) -gt 1
                printf '%s\n' $opts | fzf --height 10
            else
                echo $opts[1]
            end
            commandline -f repaint
        end
        abbr --add fasd_inline --position anywhere --regex ',[^ ]+' --function fasd_inline
    end

    function __abbr_date
        date -d (string replace -r '^,d(-?\d+)' '$1' $argv[1])" days" "+%Y-%m-%d"
    end
    abbr --add dateoffset --position anywhere --regex ',d-?\d+' --function __abbr_date

    # get zsh like up/down

    # from: type up-or-search
    function up-or-prefix-search --description 'Search back or move cursor up 1 line'
        # If we are already in search mode, continue
        if commandline --search-mode
            commandline -f history-prefix-search-backward
            return
        end

        # If we are navigating the pager, then up always navigates
        if commandline --paging-mode
            commandline -f up-line
            return
        end

        # We are not already in search mode.
        # If we are on the top line, start search mode,
        # otherwise move up
        set -l lineno (commandline -L)

        switch $lineno
            case 1
                commandline -f history-prefix-search-backward

            case '*'
                commandline -f up-line
        end
    end
    bind --preset \e\[A up-or-prefix-search

    # from: type down-or-search
    function down-or-prefix-search --description 'search forward or move down 1 line'
        # If we are already in search mode, continue
        if commandline --search-mode
            commandline -f history-prefix-search-forward
            return
        end

        # If we are navigating the pager, then up always navigates
        if commandline --paging-mode
            commandline -f down-line
            return
        end

        # We are not already in search mode.
        # If we are on the bottom line, start search mode,
        # otherwise move down
        set -l lineno (commandline -L)
        set -l line_count (count (commandline))

        switch $lineno
            case $line_count
                commandline -f history-prefix-search-forward

            case '*'
                commandline -f down-line
        end
    end
    bind --preset \e\[B down-or-prefix-search

    set puser (whoami)
    set phost (prompt_hostname)

    function fish_prompt
        set -l last_status $status
        set -l stat
        if test $last_status -ne 0
            set stat (set_color -o red)"$last_status "(set_color normal)
        end

        set -l git_root $PWD
        while test $git_root != / -a ! -e "$git_root/.git"
            set git_root (dirname $git_root)
        end
        set -l prompt
        if test $git_root = /
            set prompt (prompt_pwd)
        else
            set parent (dirname $git_root)
            set prompt (string replace -r "^$parent/" "" $PWD)
        end

        set -l git_branch (git branch 2>/dev/null | sed -n '/\* /s///p')
        if test -n "$git_branch"
            set git_branch (set_color -o cyan)" "$git_branch
        end

        string join '' -- [ $stat (set_color -o green) $puser@$phost (set_color -o grey) ' ' $prompt (set_color normal) $git_branch (set_color normal) ] ' '
    end

    function kc_abbr
        echo 'kubectl --context '(kubectl config get-contexts -o name | fzf --height 10); and commandline -f repaint
    end
    abbr --add kc --function kc_abbr

    set -g fish_greeting
    set -g fish_autosuggestion_enabled 0

    if command -q nvim
        set -Ux EDITOR nvim
        abbr --add vim nvim
    else if command -q vim
        set -Ux EDITOR vim
    else if command -q vi
        set -Ux EDITOR vi
    end
    set -Ux NODE_OPTIONS --use-openssl-ca

    abbr --add ts tig status
    abbr --add t tig
    abbr --add g git
    abbr --add gs git status -sb
    abbr --add tw timew
    abbr --add cal cal -m
    abbr --add k kubectl
    abbr --add dkc docker-compose
    abbr --add xc xclip -sel clip

    if command -q eza
        alias ll "eza -la"
    end

    if functions -q fzf_key_bindings
        fzf_key_bindings
    end

    set -l foreground ebdbb2
    set -l selection 504945
    set -l comment 8f3f71
    set -l red fb4934
    set -l orange fe8019
    set -l yellow fabd2f
    set -l green b8bb26
    set -l purple d3869b
    set -l cyan 8ec07c
    set -l blue 83a598

    # Syntax Highlighting Colors
    set -g fish_color_normal $foreground
    set -g fish_color_command $green
    set -g fish_color_keyword $blue
    set -g fish_color_quote $yellow
    set -g fish_color_redirection $foreground
    set -g fish_color_end $orange
    set -g fish_color_error $red
    set -g fish_color_param $foreground
    set -g fish_color_comment $comment
    set -g fish_color_selection --background=$selection
    set -g fish_color_search_match --background=$selection
    set -g fish_color_operator $green
    set -g fish_color_escape $blue
    set -g fish_color_autosuggestion $comment

    # Completion Pager Colors
    set -g fish_pager_color_progress $comment
    set -g fish_pager_color_prefix $cyan
    set -g fish_pager_color_completion $foreground
    set -g fish_pager_color_description $comment

    alias hl='hledger --infer-equity'

    bind \cc 'if test (commandline -b) = ""; echo ""; and commandline -f repaint; else; commandline -f cancel-commandline; end'
end
