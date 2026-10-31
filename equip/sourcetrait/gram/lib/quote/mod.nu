use ../common
use ../repo

# A quote's name, CamelCase parts joined by /, as a concept's path is.
const NAME = '^[A-Z][A-Za-z0-9]*(/[A-Z][A-Za-z0-9]*)*$'

# A quote by its iter and name, or a table of them by a list of names.
export def main [
    iter: string
    quote: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<quote: string, summary: string, file: path>,
        table<quote: string, summary: string, file: path>
    >
] {
    let single = (($quote | describe) == 'string')
    let names = if $single { [$quote] } else { $quote }
    let found = (lookup $iter $names)
    if $single { $found | first } else { $found }
}

# A new quote: its item in the iter's quote/quote.yaml and a stub titled for it.
export def new [
    iter: string
    quote: string
    summary: string
]: nothing -> record<quote: string, summary: string, file: path> {
    common check_summary $summary 'quote'
    if not ($quote =~ $NAME) {
        error make --unspanned $"not a quote name: '($quote)'"
    }
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let held = (homes $repo_dir $iter_dir)
    let live = ($held | first)
    let taken = ($held | where {|home|
        $home.items | any {|item| $item.quote? == $quote }
    })
    if ($taken | is-not-empty) {
        error make --unspanned (
            $"quote ($quote) already listed in (($taken | first).index_file)"
        )
    }
    let parts = ($quote | split row '/')
    if ($parts | length) > 1 {
        let parent = ($parts | drop 1 | str join '/')
        if not ($live.items | any {|item| $item.quote? == $parent }) {
            error make --unspanned (
                $"no quote ($parent) in ($live.index_file) to hold ($quote)"
            )
        }
    }
    let file = ($live.dir | path join $"($quote).md")
    if ($repo_dir | path join $file | path type) != null {
        error make --unspanned $"($file) already exists"
    }
    let item = {quote: $quote, summary: $summary}
    if ([$item] | to yaml | from yaml | first).summary != $summary {
        error make --unspanned "the summary would not read back as written"
    }
    let index_path = ($repo_dir | path join $live.index_file)
    if ($index_path | path exists) and (
        (open --raw $index_path | decode) != ($live.items | to yaml)
    ) {
        error make --unspanned (
            $"($live.index_file) is not as to yaml writes it; a new quote rewrites it"
        )
    }
    mkdir ($repo_dir | path join $file | path dirname)
    $"# (title_of ($parts | last))(char nl)" | save ($repo_dir | path join $file)
    $live.items | append $item | sort-by quote | to yaml | save --force $index_path
    let entry = (lookup $iter [$quote] | first)
    if $entry.summary != $summary {
        error make --unspanned $"($live.index_file) reads ($quote) back altered"
    }
    $entry
}

# Every uncited top quote and its subtree moved into the iter's old/quote/.
export def prune [
    iter: string
]: nothing -> record<kept: int, moved: int, quotes: list<string>> {
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let namepath = ($iter | split row --regex '[:/]' | str join '/')
    let held = (homes $repo_dir $iter_dir)
    let live = ($held | first)
    let old = ($held | last)
    let index_path = ($repo_dir | path join $live.index_file)
    if not ($index_path | path exists) {
        return {kept: 0, moved: 0, quotes: []}
    }
    if (open --raw $index_path | decode) != ($live.items | to yaml) {
        error make --unspanned (
            $"($live.index_file) is not as to yaml writes it; a prune rewrites it"
        )
    }
    let names = ($live.items | each {|item| $item.quote })
    let cited = (cited $repo_dir $iter_dir $namepath)
    let tops = ($names | where {|name| not ($name | str contains '/') })
    let moving_tops = ($tops | where {|top|
        not ($names | where {|name| in_tree $name $top } | any {|name| $name in $cited })
    })
    if ($moving_tops | is-empty) {
        return {kept: ($names | length), moved: 0, quotes: []}
    }
    let moving = ($live.items | where {|item|
        $moving_tops | any {|top| in_tree $item.quote $top }
    })
    let kept = ($live.items | where {|item|
        not ($moving_tops | any {|top| in_tree $item.quote $top })
    })
    let moving_files = ($moving | each {|item| $"($item.quote).md" })
    let old_index_path = ($repo_dir | path join $old.index_file)
    let old_present = ($old_index_path | path exists)
    let problems = (
        [
            ($moving | where {|item|
                not ($repo_dir | path join $live.dir $"($item.quote).md" | path exists)
            } | each {|item| $"no file for quote ($item.quote) in ($live.dir)" })
            ($moving | where {|item|
                ($repo_dir | path join $old.dir $"($item.quote).md" | path type) != null
            } | each {|item| $"quote ($item.quote) already in ($old.dir)" })
            ($moving | where {|item|
                $old.items | any {|listed| $listed.quote? == $item.quote }
            } | each {|item| $"quote ($item.quote) already listed in ($old.index_file)" })
            ($moving_tops | each {|top|
                let tree_dir = ($repo_dir | path join $live.dir $top)
                if ($tree_dir | path exists) {
                    glob ($tree_dir | path join '**' '*')
                    | where {|file| ($file | path type) == 'file' }
                    | each {|file|
                        $file | path relative-to ($repo_dir | path join $live.dir)
                    }
                    | where {|file| $file not-in $moving_files }
                    | each {|file| $"($file) in ($live.dir) is no listed quote" }
                } else {
                    []
                }
            } | flatten)
            (if $old_present and (
                (open --raw $old_index_path | decode) != ($old.items | to yaml)
            ) {
                [$"($old.index_file) is not as to yaml writes it; a prune rewrites it"]
            } else {
                []
            })
        ] | flatten
    )
    if ($problems | is-not-empty) {
        error make --unspanned ($problems | str join '; ')
    }
    for item in $moving {
        let source = ($repo_dir | path join $live.dir $"($item.quote).md")
        let target = ($repo_dir | path join $old.dir $"($item.quote).md")
        mkdir ($target | path dirname)
        cp $source $target
        if (open --raw $target | hash sha256) != (open --raw $source | hash sha256) {
            error make --unspanned $"($target) differs from ($source)"
        }
    }
    $old.items | append $moving | sort-by quote | to yaml | save --force $old_index_path
    $kept | to yaml | save --force $index_path
    if (common read_index $repo_dir $live.index_file) != $kept {
        error make --unspanned $"($live.index_file) reads back altered"
    }
    for item in $moving {
        let source = ($repo_dir | path join $live.dir $"($item.quote).md")
        let target = ($repo_dir | path join $old.dir $"($item.quote).md")
        if (open --raw $target | hash sha256) != (open --raw $source | hash sha256) {
            error make --unspanned $"($source) is not its copy at ($target)"
        }
        rm --permanent $source
    }
    for top in $moving_tops {
        let tree_dir = ($repo_dir | path join $live.dir $top)
        if ($tree_dir | path exists) {
            rm --recursive --permanent $tree_dir
        }
    }
    let found = (lookup $iter ($moving | each {|item| $item.quote }))
    let strays = ($found | where {|entry|
        not ($entry.file | str starts-with $old.dir)
    })
    if ($strays | is-not-empty) {
        let named = ($strays | each {|entry| $entry.quote } | str join ', ')
        error make --unspanned $"quote ($named) still read from ($live.dir)"
    }
    {
        kept: ($kept | length)
        moved: ($moving | length)
        quotes: ($moving | each {|item| $item.quote })
    }
}

# A quote ref's iter namepath and quote name, the iter's lowercase parts first.
export def named [
    ref: string
    body: string
]: nothing -> record<iter: string, name: string> {
    let parts = ($body | split row '#' | first | split row ':')
    let iter_parts = ($parts | take while {|part| $part =~ '^[a-z0-9_/-]+$' })
    let rest = ($parts | skip ($iter_parts | length))
    if ($iter_parts | is-empty) {
        error make --unspanned $"no iter in '($ref)'"
    }
    if ($rest | is-empty) {
        error make --unspanned $"no quote in '($ref)'"
    }
    let name = ($rest | first)
    if not ($name =~ $NAME) {
        error make --unspanned $"not a quote name in '($ref)'"
    }
    {iter: ($iter_parts | str join '/'), name: $name}
}

# Quotes by name in an iter, each from quote/ or, once pruned, old/quote/.
def lookup [
    iter: string
    names: list<string>
]: nothing -> list<record<quote: string, summary: string, file: path>> {
    let bad = ($names | where {|name| not ($name =~ $NAME) })
    if ($bad | is-not-empty) {
        error make --unspanned $"not a quote name: ($bad | str join ', ')"
    }
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let held = (homes $repo_dir $iter_dir)
    mut found = []
    for name in $names {
        $found = ($found | append (one_held $held $name))
    }
    common require_files $repo_dir ($found | each {|entry| $entry.file })
    $found
}

# The live quote/ and the archived old/quote/, each its directory and items.
def homes [
    repo_dir: directory
    iter_dir: path
]: nothing -> list<record> {
    [($iter_dir | path join 'quote') ($iter_dir | path join 'old' 'quote')]
    | each {|dir|
        let index_file = ($dir | path join 'quote.yaml')
        let items = if ($repo_dir | path join $index_file | path exists) {
            common read_index $repo_dir $index_file
        } else {
            []
        }
        {dir: $dir, index_file: $index_file, items: $items}
    }
}

# A quote's entry in the live index or, once pruned, in the archived one.
def one_held [
    held: list<record>
    name: string
]: nothing -> record<quote: string, summary: string, file: path> {
    mut hits = []
    for home in $held {
        let listed = ($home.items | where {|item| $item.quote? == $name })
        if ($listed | length) > 1 {
            error make --unspanned $"quote ($name) listed twice in ($home.index_file)"
        }
        if ($listed | is-not-empty) {
            $hits = ($hits | append {
                quote: $name
                summary: ($listed | first).summary
                file: ($home.dir | path join $"($name).md")
            })
        }
    }
    if ($hits | is-empty) {
        let looked = ($held | each {|home| $home.index_file } | str join ' or ')
        error make --unspanned $"no quote ($name) in ($looked)"
    }
    if ($hits | length) > 1 {
        error make --unspanned $"quote ($name) listed both live and archived"
    }
    $hits | first
}

# The quotes of an iter its own documents cite, quote/, old/, and sub/ aside.
def cited [
    repo_dir: directory
    iter_dir: path
    namepath: string
]: nothing -> list<string> {
    let root = ($repo_dir | path join $iter_dir)
    let skipped = (['quote' 'old' 'sub'] | each {|part| $root | path join $part })
    let files = (
        glob ($root | path join '**' '*')
        | where {|file| ($file | path type) == 'file' }
        | where {|file| not ($skipped | any {|dir| $file | str starts-with $"($dir)/" }) }
    )
    mut names = []
    for file in $files {
        let text = (try { open --raw $file | decode utf-8 } catch { '' })
        let bodies = ($text | parse --regex '\{quote:(?P<body>[^{}\s]+)\}')
        for row in $bodies {
            let held = (try { named $row.body $row.body } catch { null })
            if ($held != null) and ($held.iter == $namepath) {
                $names = ($names | append $held.name)
            }
        }
    }
    $names | uniq
}

# Whether a quote's name sits in a top quote's tree, the top itself included.
def in_tree [
    name: string
    top: string
]: nothing -> bool {
    ($name == $top) or ($name | str starts-with $"($top)/")
}

# A ConceptName's prose title: its words split at their capitals, the first kept.
def title_of [
    name: string
]: nothing -> string {
    $name
    | parse --regex '(?P<word>[A-Z][a-z0-9]+|[A-Z]+(?![a-z])|[A-Z])'
    | enumerate
    | each {|row|
        if ($row.index == 0) or ($row.item.word =~ '^[A-Z]{2,}$') {
            $row.item.word
        } else {
            $row.item.word | str lowercase
        }
    }
    | str join ' '
}
