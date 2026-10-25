use ../common
use ../repo

# A sequence or protocol index's entries by name, in the order named, with files.
export def entries [
    iter: string
    kind: string
    names: list<string>
]: nothing -> list<record> {
    if $kind not-in ['sequence' 'protocol'] {
        error make --unspanned $"not an indexed kind: ($kind)"
    }
    let bad = ($names | where {|name| not ($name =~ '^[A-Za-z0-9_-]+$') })
    if ($bad | is-not-empty) {
        error make --unspanned $"not a ($kind) name: ($bad | str join ', ')"
    }
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let index_file = ($iter_dir | path join $kind $"($kind).yaml")
    let items = (
        common read_index $repo_dir $index_file
        | where {|item| ($item | get -o $kind) != null }
    )
    let known = ($items | each {|item| $item | get $kind })
    let missing = ($names | where {|name| $name not-in $known })
    if ($missing | is-not-empty) {
        error make --unspanned (
            $"no ($kind) ($missing | str join ', ') in ($index_file)"
        )
    }
    let repeated = ($names | uniq | where {|name|
        ($known | where {|known_name| $known_name == $name } | length) > 1
    })
    if ($repeated | is-not-empty) {
        error make --unspanned (
            $"($kind) ($repeated | str join ', ') listed twice in ($index_file)"
        )
    }
    let found = ($names | each {|name|
        let item = ($items | where {|item| ($item | get $kind) == $name } | first)
        {
            name: $name
            summary: $item.summary
            apply: ($item.apply? | default [])
            file: ($iter_dir | path join $kind $"($name).md")
        }
    })
    common require_files $repo_dir ($found | each {|entry| $entry.file })
    $found
}
