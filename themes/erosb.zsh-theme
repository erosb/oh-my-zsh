# erosb.zsh-theme

# branch , ahead, behind, lines added, lines deleted

function git_compact_status() {
    local branch  lines_added lines_deleted arr untracked_lines untracked_files rel_untracked_files
    local fmt_branch fmt_lines_added fmt_lines_deleted fmt_lines
    git branch 2>/dev/null 1>&2
    if [[ $? -eq 128 ]]; then
        return;
    fi
    branch=$(git branch | grep \* | cut -d ' ' -f2)
    
    arr=( $(git diff --numstat | awk 'BEGIN {added=0; deleted=0;} {added += $1; deleted += $2;} END {print added "  " deleted ; }') );
    rel_untracked_files=$(git st --porcelain --untracked-files=all | egrep '^\?\?' | colrm 1 3);
    git_root_dir=$(git rev-parse --show-toplevel)
    
    if [[ $git_root_dir == $PWD ]]; then
        untracked_files=$rel_untracked_files;
    else
        untracked_files=()
        for f in $rel_untracked_files; do
            untracked_files+=("$git_root_dir/$f")
        done
    fi
    
    if [[ $untracked_files != "" ]]; then
        untracked_lines=$(wc -l $(echo $untracked_files) | tail -n 1 | awk '{print $1}' )
    else
        untracked_lines=0
    fi
    
    lines_added=$(( $arr[1] +  $untracked_lines ))
    lines_deleted=$arr[2]
    fmt_branch="(%B$FG[125]$branch%b)"
    if [[ $lines_added -eq 0 ]]; then
        fmt_lines_added=""
    else
        fmt_lines_added=" $fg[green]+$lines_added%{$reset_color%}"
    fi
    
    
    if [[ $lines_deleted -eq 0 ]]; then
        fmt_lines_deleted=""
    else
        fmt_lines_deleted=" $fg[red]-$lines_deleted%{$reset_color%}"
    fi
    
    if [[ $lines_added -eq 0 && $lines_deleted -eq 0 ]]; then
        fmt_lines=" $FG[237]clear%{$reset_color%}"
    else
        fmt_lines="$fmt_lines_added$fmt_lines_deleted"
    fi
    
    
    echo "$fmt_branch$fmt_lines"
}

function displayed_pwd() {
    local relpref relpwd
    if [[ $PWD == $HOME ]]; then 
        echo "%B~%b"
        return
    fi
    relpwd=$(realpath --relative-base=$(realpath $HOME) $PWD)
    if [[ $relpwd == $PWD ]]; then 
        echo "${relpwd:h}/%B${relpwd:t}%b"
    else
        if [[ ${relpwd:h} == "." ]]; then
            relpref=""
        else
            relpref="${relpwd:h}/"
        fi
        echo "~/${relpref}%B${relpwd:t}%b"
    fi
}
	
# chpwd_functions+=(update_current_git_vars)
		
# display exitcode on the right when >0
return_code="%(?..%{$fg[red]%}%? ↵ %{$reset_color%})"
        
PROMPT='${return_code}$(git_compact_status) %{$reset_color%}$(displayed_pwd) %# '
RPROMPT=''
