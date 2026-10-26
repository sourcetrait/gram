use ../common
use ../iter
use ../log
use ../plan
use ../protocol
use ../sequence
use ../repo

# The file a GramRef names, or nothing for none and kinds no file holds.
export def ref_filepath [
    ref: string
]: nothing -> oneof<nothing, path> {
    located $ref | get path
}

# Each GramRef's path and summary, an iter's top or subiters, a record or table.
export def resolve [
    ref: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<
            ref: string, path: oneof<nothing, path>,
            summary: oneof<nothing, string>,
            actual: oneof<
                nothing,
                record<top: string, summary: string, path: directory>,
                table<sub: string, summary: string, path: directory>
            >
        >,
        table<
            ref: string, path: oneof<nothing, path>,
            summary: oneof<nothing, string>,
            actual: oneof<
                nothing,
                record<top: string, summary: string, path: directory>,
                table<sub: string, summary: string, path: directory>
            >
        >
    >
] {
    let single = (($ref | describe) == 'string')
    let refs = if $single { [$ref] } else { $ref }
    mut found = []
    for one in $refs {
        let at = (located $one)
        let entry = {
            ref: $one, path: $at.path, summary: $at.summary, actual: $at.actual
        }
        $found = ($found | append $entry)
    }
    if $single { $found | first } else { $found }
}

# Each GramRef in its braced form, {kind:body}, a string or a list for a list.
export def braced [
    ref: oneof<list<string>, string>
]: nothing -> oneof<list<string>, string> {
    let single = (($ref | describe) == 'string')
    let refs = if $single { [$ref] } else { $ref }
    mut found = []
    for one in $refs {
        $found = ($found | append (one_braced $one))
    }
    if $single { $found | first } else { $found }
}

# Each GramRef in its braceless form, kind:body, a string or a list for a list.
export def braceless [
    ref: oneof<list<string>, string>
]: nothing -> oneof<list<string>, string> {
    let single = (($ref | describe) == 'string')
    let refs = if $single { [$ref] } else { $ref }
    mut found = []
    for one in $refs {
        let braced = (one_braced $one)
        let bare = if $braced == 'none' {
            'none'
        } else {
            $braced | parse --regex '^\{(?P<inner>.+)\}$' | first | get inner
        }
        $found = ($found | append $bare)
    }
    if $single { $found | first } else { $found }
}

# One GramRef braced, none as itself, refused unless it holds either form.
def one_braced [
    ref: string
]: nothing -> string {
    if ($ref == 'none') or ($ref =~ '^\{[a-z]+:[^{}]+\}$') {
        return $ref
    }
    if not ($ref =~ '^[a-z]+:[^{}]+$') {
        error make --unspanned $"not a GramRef, braced or braceless: '($ref)'"
    }
    $"{($ref)}"
}

# A GramRef's file, its index's summary, an iter's top or subiters, or nothing.
def located [
    ref: string
]: [
    nothing -> record<
        path: oneof<nothing, path>, summary: oneof<nothing, string>,
        actual: oneof<
            nothing,
            record<top: string, summary: string, path: directory>,
            table<sub: string, summary: string, path: directory>
        >
    >
] {
    if $ref == 'none' {
        return {path: null, summary: null, actual: null}
    }
    let parts = ($ref | parse --regex '^\{(?P<kind>[a-z]+):(?P<body>[^{}]+)\}$')
    if ($parts | is-empty) {
        error make --unspanned $"not a GramRef: '($ref)'"
    }
    let kind = ($parts | first | get kind)
    let body = ($parts | first | get body)
    if $kind == 'iter' {
        let model = (iter $body)
        return {path: $model.path, summary: $model.summary, actual: $model.nest}
    }
    let found = match $kind {
        'log' => {
            let named = (iter_and_name $ref $body)
            if not ($named.name =~ '^[0-9]+$') {
                error make --unspanned $"not a log rev in '($ref)'"
            }
            let entry = (log rev $named.iter ($named.name | into int))
            {path: $entry.file, summary: $entry.summary}
        }
        'protocol' | 'proto' => {
            let named = (iter_and_name $ref $body)
            let entry = (protocol $named.iter $named.name)
            {path: $entry.file, summary: $entry.summary}
        }
        'sequence' | 'seq' => {
            let named = (iter_and_name $ref $body)
            let entry = (sequence $named.iter $named.name)
            {path: $entry.file, summary: $entry.summary}
        }
        'info' => {
            let parts = ($body | split row '#' | first | split row ':')
            let iter_parts = ($parts | take while {|part| $part =~ '^[a-z0-9_/-]+$' })
            let rest = ($parts | skip ($iter_parts | length))
            if ($iter_parts | is-empty) {
                error make --unspanned $"no iter in '($ref)'"
            } else if ($rest | is-empty) {
                error make --unspanned $"no concept in '($ref)'"
            } else {
                let concept = ($rest | first)
                if not ($concept =~ '^[A-Z][A-Za-z0-9]*(/[A-Z][A-Za-z0-9]*)*$') {
                    error make --unspanned $"not a concept path in '($ref)'"
                }
                let repo_dir = (repo repo_dir)
                let iter_dir = (common repo_dir_iter $repo_dir ($iter_parts | str join ':'))
                let file = ($iter_dir | path join 'info' $"($concept).md")
                common require_files $repo_dir [$file]
                let index_file = ($iter_dir | path join 'info' 'info.yaml')
                {
                    path: $file
                    summary: (indexed_summary $repo_dir $index_file 'concept' $concept)
                }
            }
        }
        'study' => {
            let parts = ($body | split row '#' | first | split row ':')
            let iter_parts = ($parts | take while {|part| $part =~ '^[a-z0-9_/-]+$' })
            let rest = ($parts | skip ($iter_parts | length))
            if ($iter_parts | is-empty) {
                error make --unspanned $"no iter in '($ref)'"
            } else if ($rest | length) < 2 {
                error make --unspanned $"no study and concept in '($ref)'"
            } else {
                let study = ($rest | first)
                let concept = ($rest | get 1)
                if not ($study =~ '^([a-z0-9_]+/)*[A-Z][A-Za-z0-9]*$') {
                    error make --unspanned $"not a study namepath in '($ref)'"
                }
                if not ($concept =~ '^[A-Z][A-Za-z0-9]*(/[A-Z][A-Za-z0-9]*)*$') {
                    error make --unspanned $"not a concept path in '($ref)'"
                }
                let repo_dir = (repo repo_dir)
                let iter_dir = (common repo_dir_iter $repo_dir ($iter_parts | str join ':'))
                let file = ($iter_dir | path join 'study' $study $"($concept).md")
                common require_files $repo_dir [$file]
                let index_file = ($iter_dir | path join 'study' $study 'info.yaml')
                {
                    path: $file
                    summary: (indexed_summary $repo_dir $index_file 'concept' $concept)
                }
            }
        }
        'mem' => {
            let concept = ($body | split row '#' | first | split row ':' | first)
            if not ($concept =~ '^[A-Z][A-Za-z0-9]*(/[A-Z][A-Za-z0-9]*)*$') {
                error make --unspanned $"not a memory concept path in '($ref)'"
            }
            let repo_dir = (repo repo_dir)
            let file = (['.' 'mem' $"($concept).md"] | path join)
            common require_files $repo_dir [$file]
            let index_file = (['.' 'mem' 'mem.yaml'] | path join)
            {path: $file, summary: (indexed_summary $repo_dir $index_file 'mem' $concept)}
        }
        'plan' => {
            plan_located $body
        }
        'file' => {
            let written = ($body | split row '#' | first | split row ':' | first)
            let on_disk = if ($written | str starts-with '~') {
                $written | path expand
            } else {
                repo repo_dir | path join $written
            }
            if not ($on_disk | path exists) {
                error make --unspanned $"missing file: ($written) in '($ref)'"
            }
            {path: $written, summary: null}
        }
        _ => {path: null, summary: null}
    }
    $found | insert actual null
}

# A summary from an index, the one item whose key names the entry.
def indexed_summary [
    repo_dir: directory
    index_file: path
    key: string
    name: string
]: nothing -> string {
    let found = (listed_summary $repo_dir $index_file $key $name)
    if $found == null {
        error make --unspanned $"no ($key) ($name) in ($index_file)"
    }
    $found
}

# A summary from an index where it lists the entry, nothing where it does not.
def listed_summary [
    repo_dir: directory
    index_file: path
    key: string
    name: string
]: nothing -> oneof<nothing, string> {
    let listed = (
        common read_index $repo_dir $index_file
        | where {|item| ($item | get -o $key) == $name }
    )
    if ($listed | length) > 1 {
        error make --unspanned $"($key) ($name) listed twice in ($index_file)"
    }
    if ($listed | is-empty) { null } else { $listed | first | get summary }
}

# A plan ref's nearest file and its summary; a whole iter's tasking its plan/.
def plan_located [
    body: string
]: [
    nothing -> record<
        path: oneof<nothing, path>, summary: oneof<nothing, string>
    >
] {
    let named = ($body | parse --regex '^(?P<iter>.+):(?P<name>[A-Z][^:]*)$')
    if ($named | is-empty) {
        let repo_dir = (repo repo_dir)
        let iter_dir = (common repo_dir_iter $repo_dir $body)
        return {path: ($iter_dir | path join 'plan'), summary: null}
    }
    let iter = ($named | first).iter
    let names = ($named | first | get name | split row '/')
    if ($names | length) == 1 {
        let entry = (plan campaign $iter ($names | first))
        return {path: $entry.file, summary: $entry.summary}
    }
    let entry = (plan task $iter ($names | str join '/'))
    let ancestors = (
        2..<($names | length)
        | each {|depth| $names | first $depth | str join '/' }
        | reverse
    )
    let held = ($ancestors | reduce --fold $entry.file {|namepath, found|
        if $found != null {
            $found
        } else {
            plan task $iter $namepath | get file
        }
    })
    let file = if $held != null {
        $held
    } else {
        plan campaign $iter ($names | first) | get file
    }
    {path: $file, summary: $entry.summary}
}

# A GramRef's body split at its last colon into an iter namepath and a name.
def iter_and_name [
    ref: string
    body: string
]: nothing -> record<iter: string, name: string> {
    let parts = ($body | parse --regex '^(?P<iter>.+):(?P<name>[^:]+)$')
    if ($parts | is-empty) {
        error make --unspanned $"no iter and name in '($ref)'"
    }
    $parts | first
}
