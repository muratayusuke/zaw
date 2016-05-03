# zaw source for git files

function zaw-src-git-files-raw() {
    local ret=0
    git rev-parse --git-dir >/dev/null 2>&1
    ret=$?
    if (( ret != 0 )); then
        return ret
    fi

    "$1"
    ret=$?
    if (( ret != 0 )); then
        return ret
    fi

    actions=(zaw-callback-edit-file zaw-src-git-status-add zaw-src-git-status-add-p zaw-src-git-status-reset zaw-src-git-status-checkout zaw-src-git-status-rm zaw-callback-append-to-buffer)
    act_descriptions=("edit file" "add" "add -p" "reset" "checkout" "rm" "append to edit buffer")
    options=(-m -n)
    return 0
}

function zaw-src-git-files-classify-aux() {
    local -a as ms cs ds os
    : ${(A)as::=${(0)"$(git ls-files $(git rev-parse --show-cdup) -z -c -o --exclude-standard)"}}
    : ${(A)ms::=${(0)"$(git ls-files $(git rev-parse --show-cdup) -z -m)"}}
    : ${(A)us::=${(0)"$(git ls-files $(git rev-parse --show-cdup) -z -o --exclude-standard)"}}

    if is-at-least 5.0.0 || [[ -n "${ZSH_PATCHLEVEL-}" ]] && \
       is-at-least 1.5637 "$ZSH_PATCHLEVEL"; then
        os=(${as:|ms})
        os=(${os:|us})
    else
        os=(${as:#(${(~j.|.)ms})}) # TODO: too slower for large work tree
        os=(${os:#(${(~j.|.)us})}) # TODO: too slower for large work tree
    fi

    cs=($os)
    ds=($os)
    if (( $#ms != 0 )) && (( $#ms != 1 )) || [[ ! -z "$ms" ]]; then
        cs=($ms $cs)
        : ${(A)mds::=${ms/%/                   MODIFIED}}
        ds=($mds $ds)
    fi
    if (( $#us != 0 )) && (( $#us != 1 )) || [[ ! -z "$us" ]]; then
        cs=($us $cs)
        : ${(A)uds::=${us/%/                   UNTRACKED}}
        ds=($uds $ds)
    fi

    candidates=($cs)
    cand_descriptions=($ds)
    return 0
}

function zaw-src-git-files-legacy-aux() {
    : ${(A)candidates::=${(0)"$(git ls-files $(git rev-parse --show-cdup) -z -c -o --exclude-standard)"}}
    return 0
}

function zaw-src-git-files-add () {
    BUFFER="git add $1"
    zle accept-line
}

{
    function zaw-src-git-files-register-src() {
        eval "function $2 () { zaw-src-git-files-raw "$3" }"
        zaw-register-src -n "$1" "$2"
    }
    zaw-src-git-files-register-src git-files zaw-src-git-files zaw-src-git-files-classify-aux
    zaw-src-git-files-register-src git-files-legacy zaw-src-git-files-legacy{,-aux}
} always {
    unfunction zaw-src-git-files-register-src
}
