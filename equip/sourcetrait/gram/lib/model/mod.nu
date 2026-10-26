use ../ref

# An iter's model by its GramRef, or a table of them by a list of refs.
export def iter [
    ref: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<
            iter: string, path: directory, summary: string,
            nest: oneof<
                record<top: string, summary: string, path: directory>,
                table<sub: string, summary: string, path: directory>
            >
        >,
        table<
            iter: string, path: directory, summary: string,
            nest: oneof<
                record<top: string, summary: string, path: directory>,
                table<sub: string, summary: string, path: directory>
            >
        >
    >
] {
    use ../iter
    let single = (($ref | describe) == 'string')
    let refs = if $single { [$ref] } else { $ref }
    mut found = []
    for one in $refs {
        $found = ($found | append (iter (body_of $one ['iter'])))
    }
    if $single { $found | first } else { $found }
}

# A log entry by its GramRef, or a table of them by a list of refs.
export def log [
    ref: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<rev: int, summary: string, file: path>,
        table<rev: int, summary: string, file: path>
    >
] {
    use ../log
    let single = (($ref | describe) == 'string')
    let refs = if $single { [$ref] } else { $ref }
    mut found = []
    for one in $refs {
        let named = (ref iter_and_name $one (body_of $one ['log']))
        if not ($named.name =~ '^[0-9]+$') {
            error make --unspanned $"not a log rev in '($one)'"
        }
        $found = ($found | append (log rev $named.iter ($named.name | into int)))
    }
    if $single { $found | first } else { $found }
}

# A campaign's index entry by its plan ref, or a table of them by a list.
export def campaign [
    ref: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<
            campaign: string, pool: string, summary: string, stage: string,
            tasks: table<task: string, summary: string>, file: path
        >,
        table<
            campaign: string, pool: string, summary: string, stage: string,
            tasks: table<task: string, summary: string>, file: path
        >
    >
] {
    use ../plan
    let single = (($ref | describe) == 'string')
    let refs = if $single { [$ref] } else { $ref }
    mut found = []
    for one in $refs {
        let named = (ref iter_and_name $one (body_of $one ['plan']))
        if ($named.name | str contains '/') {
            error make --unspanned $"a task, not a campaign: '($one)'"
        }
        $found = ($found | append (plan campaign $named.iter $named.name))
    }
    if $single { $found | first } else { $found }
}

# A task's index entry by its plan ref, or a table of them by a list.
export def task [
    ref: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<
            task: string, campaign: string, pool: string, summary: string,
            stage: string, tasks: table<task: string, summary: string>,
            file: oneof<nothing, path>
        >,
        table<
            task: string, campaign: string, pool: string, summary: string,
            stage: string, tasks: table<task: string, summary: string>,
            file: oneof<nothing, path>
        >
    >
] {
    use ../plan
    let single = (($ref | describe) == 'string')
    let refs = if $single { [$ref] } else { $ref }
    mut found = []
    for one in $refs {
        let named = (ref iter_and_name $one (body_of $one ['plan']))
        if not ($named.name | str contains '/') {
            error make --unspanned $"a campaign, not a task: '($one)'"
        }
        $found = ($found | append (plan task $named.iter $named.name))
    }
    if $single { $found | first } else { $found }
}

# A sequence by its GramRef, or a table of them by a list of refs.
export def sequence [
    ref: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<name: string, summary: string, file: path>,
        table<name: string, summary: string, file: path>
    >
] {
    use ../sequence
    let single = (($ref | describe) == 'string')
    let refs = if $single { [$ref] } else { $ref }
    mut found = []
    for one in $refs {
        let named = (ref iter_and_name $one (body_of $one ['sequence' 'seq']))
        $found = ($found | append (sequence $named.iter $named.name))
    }
    if $single { $found | first } else { $found }
}

# A protocol by its GramRef, or a table of them by a list of refs.
export def protocol [
    ref: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<
            name: string, summary: string, apply: table<on: string>, file: path
        >,
        table<
            name: string, summary: string, apply: table<on: string>, file: path
        >
    >
] {
    use ../protocol
    let single = (($ref | describe) == 'string')
    let refs = if $single { [$ref] } else { $ref }
    mut found = []
    for one in $refs {
        let named = (ref iter_and_name $one (body_of $one ['protocol' 'proto']))
        $found = ($found | append (protocol $named.iter $named.name))
    }
    if $single { $found | first } else { $found }
}

# An iter's next, now, and last states by its iter ref, or a table of them.
export def state [
    ref: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<
            next: record<
                rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
            >,
            now: record<
                rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
            >,
            last: record<
                rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
            >
        >,
        table<
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
    >
] {
    use ../state
    let single = (($ref | describe) == 'string')
    let refs = if $single { [$ref] } else { $ref }
    mut found = []
    for one in $refs {
        $found = ($found | append (state states (body_of $one ['iter'])))
    }
    if $single { $found | first } else { $found }
}

# A braced GramRef's body, the ref refused unless its kind is one given.
def body_of [
    one: string
    kinds: list<string>
]: nothing -> string {
    let parts = (ref kind_body $one)
    if $parts.kind not-in $kinds {
        error make --unspanned $"not a ($kinds | first) ref: '($one)'"
    }
    $parts.body
}
