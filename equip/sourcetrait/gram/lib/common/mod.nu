# An index's items, read whole.
export def read_index [
    repo_dir: directory
    index_file: path
]: nothing -> list<record> {
    if not ($repo_dir | path join $index_file | path exists) {
        error make --unspanned $"no index: ($index_file)"
    }
    open ($repo_dir | path join $index_file) | default []
}

# A summary refused unless it is one line of at most 80 characters, not blank.
export def check_summary [
    summary: string
    kind: string
]: nothing -> nothing {
    if ($summary | str trim | is-empty) {
        error make --unspanned $"a ($kind) summary cannot be empty"
    }
    if ($summary =~ '[\r\n]') {
        error make --unspanned $"a ($kind) summary is one line"
    }
    let length = ($summary | str length --grapheme-clusters)
    if $length > 80 {
        error make --unspanned (
            $"a ($kind) summary is at most 80 characters; this one is ($length)"
        )
    }
}

# Files the repository must hold, each missing one named.
export def require_files [
    repo_dir: directory
    files: list<path>
]: nothing -> nothing {
    let missing = ($files | where {|file|
        not ($repo_dir | path join $file | path exists)
    })
    if ($missing | is-not-empty) {
        error make --unspanned $"missing file: ($missing | str join ', ')"
    }
}

# An iter's `./` directory from a namepath: `foo`, `foo/bar`, or `foo:bar`.
export def repo_dir_iter [
    gram_repo: directory
    iter: string
]: nothing -> directory {
    let parts = ($iter | split row --regex '[:/]')
    if ($parts | any {|part| not ($part =~ '^[A-Za-z0-9_-]+$') }) {
        error make --unspanned $"not an iter namepath: '($iter)'"
    }
    let iter_root = (['.' 'iter' $parts.0] | path join)
    let dir = if ($parts | length) == 1 {
        $iter_root
    } else {
        [$iter_root 'sub' ...($parts | skip 1)] | path join
    }
    if ($gram_repo | path join $dir | path type) != 'dir' {
        error make --unspanned $"no iter at ($dir)"
    }
    let subiters = ($gram_repo | path join $iter_root 'sub')
    let categories = ($parts | skip 1 | drop 1)
    for category in ($categories | enumerate) {
        let cat_dir = ($categories | first ($category.index + 1) | path join)
        let held = (ls --all ($subiters | path join $cat_dir))
        if ($held | any {|entry| $entry.type != 'dir' }) {
            error make --unspanned (
                $"category ($cat_dir) holds files; it may hold only subiters"
            )
        }
    }
    $dir
}
