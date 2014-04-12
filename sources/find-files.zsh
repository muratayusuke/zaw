# zaw source for find files

function zaw-src-find-file() {
    candidates=(`find . -type f`)
    for candidate in ${candidates}
    do
        as_short=`echo ${candidate} | awk -F'/' '{if (NF>4){LASTDIR=NF-1; print $1"/"$2"/.../"$LASTDIR"/"$NF;} else {print $0}}'`
        cand_descriptions+=${as_short}
    done

    actions=(
        zaw-callback-edit-file
        zaw-callback-append-to-buffer
    )
    act_descriptions=(
        "edit file"
        "append to edit buffer"
    )
}

zaw-register-src -n find-file zaw-src-find-file
