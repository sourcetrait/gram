use ../common
use ../repo

# The newest entries a prune leaves in an iter's log/log.yaml.
const KEPT = 20

# The newest entry in an iter's log: its rev, its summary, and its file.
export def latest [
    iter: string
]: nothing -> record<rev: int, summary: string, file: path> {
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let log_dir = ($iter_dir | path join 'log')
    let index_file = ($log_dir | path join 'log.yaml')
    let items = (common read_index $repo_dir $index_file)
    if ($items | is-empty) {
        error make --unspanned $"no log entries in ($index_file)"
    }
    entries $repo_dir [{dir: $log_dir, item: ($items | last)}] | first
}

# One entry in an iter's log by its rev, or a table of them by a list of revs.
export def rev [
    iter: string
    rev: oneof<int, list<int>>
]: [
    nothing -> oneof<
        record<rev: int, summary: string, file: path>,
        table<rev: int, summary: string, file: path>
    >
] {
    let single = (($rev | describe) == 'int')
    let revs = if $single { [$rev] } else { $rev }
    let unnumbered = ($revs | where {|wanted| $wanted < 1 })
    if ($unnumbered | is-not-empty) {
        error make --unspanned (
            $"not a log rev: ($unnumbered | str join ', '); revs count from 1"
        )
    }
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let log_dir = ($iter_dir | path join 'log')
    let old_dir = ($iter_dir | path join 'old' 'log')
    let flat_file = ($log_dir | path join 'log.yaml')
    let flat = ($repo_dir | path join $flat_file | path exists)
    let flat_items = if $flat {
        common read_index $repo_dir $flat_file
    } else {
        []
    }
    let flat_revs = ($flat_items | each {|item| $item.rev })
    let wanted = ($revs | each {|wanted|
        let dir = if $wanted in $flat_revs {
            $log_dir
        } else {
            shard_dir $old_dir $wanted
        }
        {rev: $wanted, dir: $dir}
    })
    let indices = ($wanted | each {|want| $want.dir } | uniq | each {|dir|
        let index_file = ($dir | path join 'log.yaml')
        let items = if $dir == $log_dir {
            $flat_items
        } else if ($repo_dir | path join $index_file | path exists) {
            common read_index $repo_dir $index_file
        } else {
            []
        }
        let asked = ($wanted | where dir == $dir | each {|want| $want.rev })
        let listed = ($items | each {|item| $item.rev })
        let looked = if $flat and ($dir != $log_dir) {
            $"($flat_file) or ($index_file)"
        } else {
            $index_file
        }
        {
            dir: $dir
            index_file: $index_file
            looked: $looked
            items: $items
            missing: ($asked | where {|wanted| $wanted not-in $listed })
            repeated: ($asked | uniq | where {|wanted|
                ($listed | where {|seen| $seen == $wanted } | length) > 1
            })
        }
    })
    let problems = ($indices | each {|index|
        let missing = ($index.missing | str join ', ')
        let repeated = ($index.repeated | str join ', ')
        [
            (if ($index.missing | is-not-empty) {
                $"no log entry ($missing) in ($index.looked)"
            })
            (if ($index.repeated | is-not-empty) {
                $"rev ($repeated) listed twice in ($index.index_file)"
            })
        ] | compact
    } | flatten)
    if ($problems | is-not-empty) {
        error make --unspanned ($problems | str join '; ')
    }
    let found = (entries $repo_dir ($wanted | each {|want|
        let index = ($indices | where dir == $want.dir | first)
        {dir: $want.dir, item: ($index.items | where rev == $want.rev | first)}
    }))
    if $single { $found | first } else { $found }
}

# A new entry in an iter's log: its index item and a stub titled with its rev.
export def new [
    iter: string
    summary: string
]: nothing -> record<rev: int, summary: string, file: path> {
    common check_summary $summary 'log'
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let index_file = ($iter_dir | path join 'log' 'log.yaml')
    let items = (common read_index $repo_dir $index_file)
    let new_rev = if ($items | is-empty) {
        1
    } else {
        ($items | last | get rev) + 1
    }
    let file = ($iter_dir | path join 'log' $"($new_rev).md")
    if ($repo_dir | path join $file | path type) != null {
        error make --unspanned $"($file) already exists"
    }
    let item_text = ([{rev: $new_rev, summary: $summary}] | to yaml)
    if ($item_text | from yaml | first | get summary) != $summary {
        error make --unspanned "the summary would not read back as written"
    }
    let index_path = ($repo_dir | path join $index_file)
    let index_text = (open --raw $index_path | decode)
    let appending = ($items | is-not-empty)
    if $appending and (not ($index_text | str ends-with (char nl))) {
        error make --unspanned $"($index_file) does not end with a newline"
    }
    mkdir ($repo_dir | path join $iter_dir 'log')
    $"# REV ($new_rev)(char nl)" | save ($repo_dir | path join $file)
    if $appending {
        $item_text | save --append $index_path
    } else {
        $item_text | save --force $index_path
    }
    let entry = (rev $iter $new_rev)
    if $entry.summary != $summary {
        error make --unspanned $"($index_file) reads rev ($new_rev) back altered"
    }
    {rev: $entry.rev, summary: $entry.summary, file: $entry.file}
}

# Every entry but the newest 20 moved into its old/log shard and its index.
export def prune [
    iter: string
]: nothing -> record<kept: int, moved: int, shards: list<path>> {
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let log_dir = ($iter_dir | path join 'log')
    let old_dir = ($iter_dir | path join 'old' 'log')
    let index_file = ($log_dir | path join 'log.yaml')
    let items = (common read_index $repo_dir $index_file)
    let moving = ($items | drop $KEPT)
    let kept = ($items | skip ($moving | length))
    if ($moving | is-empty) {
        return {kept: ($kept | length), moved: 0, shards: []}
    }
    let index_path = ($repo_dir | path join $index_file)
    if (open --raw $index_path | decode) != ($items | to yaml) {
        error make --unspanned (
            $"($index_file) is not as to yaml writes it; a prune rewrites it"
        )
    }
    let revs = ($items | each {|item| $item.rev })
    if not ($revs | window 2 | all {|pair| $pair.0 < $pair.1 }) {
        error make --unspanned $"($index_file) is not in rev order"
    }
    let shards = (
        $moving
        | group-by {|item| shard_dir $old_dir $item.rev }
        | transpose dir items
    )
    let problems = ($shards | each {|shard|
        let shard_index = ($shard.dir | path join 'log.yaml')
        let shard_path = ($repo_dir | path join $shard_index)
        let present = ($shard_path | path exists)
        let listed = if $present {
            common read_index $repo_dir $shard_index | each {|item| $item.rev }
        } else {
            []
        }
        let lowest = ($shard.items | first | get rev)
        let unread = ($shard.items | where {|item|
            not ($repo_dir | path join $log_dir $"($item.rev).md" | path exists)
        })
        let taken = ($shard.items | where {|item|
            let target = ($repo_dir | path join $shard.dir $"($item.rev).md")
            ($target | path type) != null
        })
        [
            (if ($unread | is-not-empty) {
                let named = ($unread | each {|item| $item.rev } | str join ', ')
                $"no entry file for rev ($named) in ($log_dir)"
            })
            (if ($taken | is-not-empty) {
                let named = ($taken | each {|item| $item.rev } | str join ', ')
                $"rev ($named) already in ($shard.dir)"
            })
            (if ($listed | any {|listed_rev| $listed_rev >= $lowest }) {
                $"($shard_index) lists a rev at or past ($lowest)"
            })
            (if $present and not (
                open --raw $shard_path | decode | str ends-with (char nl)
            ) {
                $"($shard_index) does not end with a newline"
            })
        ] | compact
    } | flatten)
    if ($problems | is-not-empty) {
        error make --unspanned ($problems | str join '; ')
    }
    for shard in $shards {
        mkdir ($repo_dir | path join $shard.dir)
        for item in $shard.items {
            let source = ($repo_dir | path join $log_dir $"($item.rev).md")
            let target = ($repo_dir | path join $shard.dir $"($item.rev).md")
            cp $source $target
            let copied = (open --raw $target | hash sha256)
            if $copied != (open --raw $source | hash sha256) {
                error make --unspanned $"($target) differs from ($source)"
            }
        }
    }
    for shard in $shards {
        let shard_path = ($repo_dir | path join $shard.dir 'log.yaml')
        if ($shard_path | path exists) {
            $shard.items | to yaml | save --append $shard_path
        } else {
            $shard.items | to yaml | save $shard_path
        }
    }
    $kept | to yaml | save --force $index_path
    if (common read_index $repo_dir $index_file) != $kept {
        error make --unspanned $"($index_file) reads back altered"
    }
    for shard in $shards {
        for item in $shard.items {
            let source = ($repo_dir | path join $log_dir $"($item.rev).md")
            let target = ($repo_dir | path join $shard.dir $"($item.rev).md")
            let copied = (open --raw $target | hash sha256)
            if $copied != (open --raw $source | hash sha256) {
                error make --unspanned $"($source) is not its copy at ($target)"
            }
            rm --permanent $source
        }
    }
    let found = (rev $iter ($moving | each {|item| $item.rev }))
    let strays = ($found | where {|entry|
        not ($entry.file | str starts-with $old_dir)
    })
    if ($strays | is-not-empty) {
        let named = ($strays | each {|entry| $entry.rev } | str join ', ')
        error make --unspanned $"rev ($named) still read from ($log_dir)"
    }
    {
        kept: ($kept | length)
        moved: ($moving | length)
        shards: ($shards | get dir)
    }
}

# The shard an archived rev sits in: its thousand's range, then its hundred's.
def shard_dir [
    old_dir: path
    rev: int
]: nothing -> path {
    let thousand = ((($rev - 1) // 1000) * 1000)
    let hundred = ((($rev - 1) // 100) * 100)
    $old_dir | path join (
        $"($thousand + 1)-($thousand + 1000)"
    ) $"($hundred + 1)-($hundred + 100)"
}

# Index items as entries in their directories, every entry's file checked.
def entries [
    repo_dir: directory
    located: list<record<dir: path, item: record>>
]: nothing -> list<record> {
    let found = ($located | each {|at|
        {
            rev: $at.item.rev
            summary: $at.item.summary
            file: ($at.dir | path join $"($at.item.rev).md")
        }
    })
    common require_files $repo_dir ($found | each {|entry| $entry.file })
    $found
}
