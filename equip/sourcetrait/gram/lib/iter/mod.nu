use ../common
use ../repo

# An iter's indices, each scaffolded empty, by its path under the iter.
const INDICES = [
    'info/info.yaml'
    'log/log.yaml'
    'plan/agenda.yaml'
    'plan/debt.yaml'
    'plan/defer.yaml'
    'plan/maybe.yaml'
    'plan/roadmap.yaml'
    'protocol/protocol.yaml'
    'sequence/sequence.yaml'
    'study/study.yaml'
]

# A new iter's summary in its top iter's iter.yaml, until one is written.
const SUMMARY = 'To do'

# An iter's model: its namepath, its directory, its summary, and its nest.
export def main [
    iter: string
]: [
    nothing -> record<
        iter: string, path: directory, summary: string,
        nest: oneof<
            record<top: string, summary: string, path: directory>,
            table<sub: string, summary: string, path: directory>
        >
    >
] {
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let parts = ($iter | split row --regex '[:/]')
    let namepath = ($parts | str join '/')
    let top = ($parts | first)
    let index_file = (['.' 'iter' $top 'iter.yaml'] | path join)
    let index = (read_index $repo_dir $index_file)
    if ($parts | length) == 1 {
        mut subs = []
        for entry in $index.subiters {
            let sub_namepath = ([$top $entry.sub] | str join '/')
            let sub_iter = {
                sub: $"{iter:($sub_namepath)}", summary: $entry.summary,
                path: (common repo_dir_iter $repo_dir $sub_namepath)
            }
            $subs = ($subs | append $sub_iter)
        }
        return {
            iter: $namepath, path: $iter_dir, summary: $index.summary,
            nest: $subs
        }
    }
    let sub = ($parts | skip 1 | str join '/')
    let listed = ($index.subiters | where {|entry| $entry.sub == $sub })
    if ($listed | is-empty) {
        error make --unspanned $"no sub ($sub) in ($index_file)"
    }
    if ($listed | length) > 1 {
        error make --unspanned $"sub ($sub) listed twice in ($index_file)"
    }
    let top_iter = {
        top: $"{iter:($top)}", summary: $index.summary,
        path: (common repo_dir_iter $repo_dir $top)
    }
    {
        iter: $namepath, path: $iter_dir,
        summary: ($listed | first | get summary), nest: $top_iter
    }
}

# A new iter scaffolded: its empty indices, its fresh state, its empty bootstrap.
export def new [
    iter: string
]: nothing -> record<iter: string, path: directory, files: list<path>> {
    let repo_dir = (repo repo_dir)
    let parts = ($iter | split row --regex '[:/]')
    if ($parts | any {|part| not ($part =~ '^[A-Za-z0-9_-]+$') }) {
        error make --unspanned $"not an iter namepath: '($iter)'"
    }
    let top = ($parts | first)
    let top_dir = (['.' 'iter' $top] | path join)
    let is_top = (($parts | length) == 1)
    let sub = ($parts | skip 1 | str join '/')
    let dir = if $is_top {
        $top_dir
    } else {
        [$top_dir 'sub' ...($parts | skip 1)] | path join
    }
    if ($repo_dir | path join $dir | path exists) {
        error make --unspanned $"($dir) already exists"
    }
    let index_file = ($top_dir | path join 'iter.yaml')
    let index = if $is_top {
        {summary: $SUMMARY, subiters: []}
    } else {
        let listed = (top_index $repo_dir $index_file $sub)
        check_categories $repo_dir $top_dir ($parts | skip 1 | drop 1)
        $listed | update subiters ($listed.subiters | append {sub: $sub, summary: $SUMMARY})
    }
    let state = [[name rev]; [last 1] [now 2] [next 3]]
    for index_path in $INDICES {
        let file = ($repo_dir | path join $dir $index_path)
        mkdir ($file | path dirname)
        "[]\n" | save $file
    }
    mkdir ($repo_dir | path join $dir 'state')
    for one in $state {
        let file = ($repo_dir | path join $dir 'state' $"($one.name).yaml")
        $"rev: ($one.rev)\nptr: none\n" | save $file
    }
    "" | save ($repo_dir | path join $dir 'bootstrap.md')
    $index | to yaml | save --force ($repo_dir | path join $index_file)
    let files = (
        [$index_file]
        | append ($INDICES | each {|index_path| $dir | path join $index_path })
        | append ($state | each {|one| $dir | path join 'state' $"($one.name).yaml" })
        | append ($dir | path join 'bootstrap.md')
    )
    {iter: ($parts | str join '/'), path: $dir, files: $files}
}

# A top iter's iter.yaml as written, refused missing, reformatted, or listing the sub.
def top_index [
    repo_dir: directory
    index_file: path
    sub: string
]: nothing -> record<summary: string, subiters: table<sub: string, summary: string>> {
    let file = ($repo_dir | path join $index_file)
    if not ($file | path exists) {
        error make --unspanned $"no index: ($index_file)"
    }
    let text = (open --raw $file | decode utf-8)
    let index = ($text | from yaml)
    if ($index | to yaml) != $text {
        error make --unspanned (
            $"($index_file) is not as to yaml writes it; a rewrite would reformat it"
        )
    }
    if (($index | get -o summary | describe) != 'string') {
        error make --unspanned $"no summary in ($index_file)"
    }
    let subiters = ($index | get -o subiters | default [])
    if ($subiters | any {|entry| ($entry | get -o sub) == $sub }) {
        error make --unspanned $"sub ($sub) already listed in ($index_file)"
    }
    {summary: $index.summary, subiters: $subiters}
}

# A subiter's category directories, each holding nothing but subiters.
def check_categories [
    repo_dir: directory
    top_dir: path
    categories: list<string>
]: nothing -> nothing {
    for category in ($categories | enumerate) {
        let cat_dir = ([$top_dir 'sub' ...($categories | first ($category.index + 1))] | path join)
        let on_disk = ($repo_dir | path join $cat_dir)
        if ($on_disk | path exists) {
            let held = (ls --all $on_disk)
            if ($held | any {|entry| $entry.type != 'dir' }) {
                error make --unspanned (
                    $"category ($cat_dir) holds files; it may hold only subiters"
                )
            }
        }
    }
}

# A top iter's iter.yaml, its summary and its subiters, each held to its shape.
def read_index [
    repo_dir: directory
    index_file: path
]: nothing -> record<summary: string, subiters: table<sub: string, summary: string>> {
    if not ($repo_dir | path join $index_file | path exists) {
        error make --unspanned $"no index: ($index_file)"
    }
    let index = (open ($repo_dir | path join $index_file))
    let summary = ($index | get -o summary)
    if ($summary | describe) != 'string' {
        error make --unspanned $"no summary in ($index_file)"
    }
    let subiters = ($index | get -o subiters | default [])
    let malformed = ($subiters | where {|entry|
        let named = (($entry | get -o sub | describe) == 'string')
        let summarized = (($entry | get -o summary | describe) == 'string')
        not ($named and $summarized)
    })
    if ($malformed | is-not-empty) {
        error make --unspanned $"a subiter without its sub or summary in ($index_file)"
    }
    {summary: $summary, subiters: ($subiters | select sub summary)}
}
