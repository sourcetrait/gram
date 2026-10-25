use ../common
use ../ref
use ../repo

# An iter's now state: its rev, its ptr, and the file its ptr names.
export def now [
    iter: string
]: [
    nothing -> record<
        rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
    >
] {
    read_state $iter 'now'
}

# An iter's next state: its rev, its ptr, and the file its ptr names.
export def next [
    iter: string
]: [
    nothing -> record<
        rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
    >
] {
    read_state $iter 'next'
}

# An iter's last state: its rev, its ptr, and the file its ptr names.
export def latest [
    iter: string
]: [
    nothing -> record<
        rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
    >
] {
    read_state $iter 'last'
}

# An iter's next, now, and last states in one record.
export def states [
    iter: string
]: [
    nothing -> record<
        next: record<
            rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
        >,
        now: record<
            rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
        >,
        last: record<
            rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
        >
    >
] {
    {
        next: (read_state $iter 'next')
        now: (read_state $iter 'now')
        last: (read_state $iter 'last')
    }
}

# An iter's state rolled: now to last, next to now, and the ptr into next.
export def advance [
    iter: string
    ptr: string
]: nothing -> int {
    if ($ptr | str trim | is-empty) or ($ptr == 'none') {
        error make --unspanned (
            "a roll's ptr cannot be empty or none; fresh rolls a fresh state"
        )
    }
    ref ref_filepath $ptr | ignore
    roll_state $iter $ptr
}

# An iter's state rolled fresh: now to last, next to now, none into next.
export def fresh [
    iter: string
]: nothing -> int {
    roll_state $iter 'none'
}

# Each state moved one place with its rev, the ptr into next at a new rev.
def roll_state [
    iter: string
    ptr: string
]: nothing -> int {
    let now = (open_state $iter 'now')
    let next = (open_state $iter 'next')
    let last = (open_state $iter 'last')
    let rev = (([$now.rev $next.rev $last.rev] | math max) + 1)
    let wanted = [
        {state: $last, rev: $now.rev, ptr: $now.ptr}
        {state: $now, rev: $next.rev, ptr: $next.ptr}
        {state: $next, rev: $rev, ptr: $ptr}
    ]
    for want in $wanted {
        let quoted = ($want.ptr | str replace --all "'" "''")
        let ptr_text = if $want.ptr == 'none' { 'none' } else { $"'($quoted)'" }
        $"rev: ($want.rev)(char nl)ptr: ($ptr_text)(char nl)"
        | save --force ($want.state.repo_dir | path join $want.state.file)
    }
    for want in $wanted {
        let written = (open_state $iter $want.state.name)
        if ($written.rev != $want.rev) or ($written.ptr != $want.ptr) {
            error make --unspanned $"($written.file) reads back altered at rev ($rev)"
        }
    }
    $rev
}

# One state file read and checked, its none ptr as null, with its ptr's file.
def read_state [
    iter: string
    name: string
]: nothing -> record {
    let state = (open_state $iter $name)
    let ptr = if $state.ptr == 'none' { null } else { $state.ptr }
    {rev: $state.rev, ptr: $ptr, file: (ref ref_filepath $state.ptr)}
}

# One state file opened and checked: an int rev of at least 1 and a string ptr.
def open_state [
    iter: string
    name: string
]: [
    nothing -> record<
        name: string, rev: int, ptr: string, repo_dir: directory, file: path
    >
] {
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let file = ($iter_dir | path join 'state' $"($name).yaml")
    common require_files $repo_dir [$file]
    let state = (open ($repo_dir | path join $file))
    if not ($state | describe | str starts-with 'record') {
        error make --unspanned $"not a state file: ($file)"
    }
    let rev_type = ($state.rev? | describe)
    let ptr_type = ($state.ptr? | describe)
    if ($rev_type != 'int') or ($ptr_type != 'string') {
        error make --unspanned (
            $"not a state file: ($file) needs an int rev and a string ptr"
        )
    }
    if $state.rev < 1 {
        error make --unspanned $"not a state file: ($file) has rev ($state.rev)"
    }
    {name: $name, rev: $state.rev, ptr: $state.ptr, repo_dir: $repo_dir, file: $file}
}
