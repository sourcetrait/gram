# GramGov's tools for the repository it runs in; gram alone lists every command.
export def main []: nothing -> string {
    let own = (scope modules | where name == 'gram' | first | get commands)
    let ids = ($own | get decl_id)
    let main_id = ($own | where name == 'gram' | first | get decl_id)
    let commands = (
        scope commands | where {|command| $command.decl_id in $ids }
    )
    let head = ($commands | where decl_id == $main_id | first)
    let listed = (
        $commands
        | where decl_id != $main_id
        | sort-by name
        | each {|command| $"  ($command.name) - ($command.description)" }
    )
    [$head.description '' 'Commands:' ...$listed] | str join (char nl)
}

# An iter's model by its GramRef: its namepath, directory, summary, and nest.
export def "get iter" [
    ref?: string
]: [
    nothing -> record<
        iter: string, path: directory, summary: string,
        nest: oneof<
            record<top: string, summary: string, path: directory>,
            table<sub: string, summary: string, path: directory>
        >
    >
    string -> record<
        iter: string, path: directory, summary: string,
        nest: oneof<
            record<top: string, summary: string, path: directory>,
            table<sub: string, summary: string, path: directory>
        >
    >
] {
    let given = (one_given $ref $in 'ref')
    use ../lib/model
    use ../lib/ref
    model iter (ref braced $given)
}

# Iters' models by their GramRefs, a table in the order asked.
export def "list iter" [
    refs?: list<string>
]: [
    nothing -> table<
        iter: string, path: directory, summary: string,
        nest: oneof<
            record<top: string, summary: string, path: directory>,
            table<sub: string, summary: string, path: directory>
        >
    >
    list<string> -> table<
        iter: string, path: directory, summary: string,
        nest: oneof<
            record<top: string, summary: string, path: directory>,
            table<sub: string, summary: string, path: directory>
        >
    >
] {
    let given = (one_given $refs $in 'refs')
    use ../lib/model
    use ../lib/ref
    model iter (ref braced $given)
}

# A log entry by its GramRef: its rev, its summary, and its file.
export def "get log" [
    ref?: string
]: [
    nothing -> record<rev: int, summary: string, file: path>
    string -> record<rev: int, summary: string, file: path>
] {
    let given = (one_given $ref $in 'ref')
    use ../lib/model
    use ../lib/ref
    model log (ref braced $given)
}

# Log entries by their GramRefs, a table in the order asked.
export def "list log" [
    refs?: list<string>
]: [
    nothing -> table<rev: int, summary: string, file: path>
    list<string> -> table<rev: int, summary: string, file: path>
] {
    let given = (one_given $refs $in 'refs')
    use ../lib/model
    use ../lib/ref
    model log (ref braced $given)
}

# A campaign's index entry by its plan ref, with its pool and file.
export def "get campaign" [
    ref?: string
]: [
    nothing -> record<
        campaign: string, pool: string, summary: string, stage: string,
        tasks: table<task: string, summary: string>, file: path
    >
    string -> record<
        campaign: string, pool: string, summary: string, stage: string,
        tasks: table<task: string, summary: string>, file: path
    >
] {
    let given = (one_given $ref $in 'ref')
    use ../lib/model
    use ../lib/ref
    model campaign (ref braced $given)
}

# Campaigns' index entries by their plan refs, a table in the order asked.
export def "list campaign" [
    refs?: list<string>
]: [
    nothing -> table<
        campaign: string, pool: string, summary: string, stage: string,
        tasks: table<task: string, summary: string>, file: path
    >
    list<string> -> table<
        campaign: string, pool: string, summary: string, stage: string,
        tasks: table<task: string, summary: string>, file: path
    >
] {
    let given = (one_given $refs $in 'refs')
    use ../lib/model
    use ../lib/ref
    model campaign (ref braced $given)
}

# A task's index entry by its plan ref, with its campaign, pool, and file.
export def "get task" [
    ref?: string
]: [
    nothing -> record<
        task: string, campaign: string, pool: string, summary: string,
        stage: string, tasks: table<task: string, summary: string>,
        file: oneof<nothing, path>
    >
    string -> record<
        task: string, campaign: string, pool: string, summary: string,
        stage: string, tasks: table<task: string, summary: string>,
        file: oneof<nothing, path>
    >
] {
    let given = (one_given $ref $in 'ref')
    use ../lib/model
    use ../lib/ref
    model task (ref braced $given)
}

# Tasks' index entries by their plan refs, a table in the order asked.
export def "list task" [
    refs?: list<string>
]: [
    nothing -> table<
        task: string, campaign: string, pool: string, summary: string,
        stage: string, tasks: table<task: string, summary: string>,
        file: oneof<nothing, path>
    >
    list<string> -> table<
        task: string, campaign: string, pool: string, summary: string,
        stage: string, tasks: table<task: string, summary: string>,
        file: oneof<nothing, path>
    >
] {
    let given = (one_given $refs $in 'refs')
    use ../lib/model
    use ../lib/ref
    model task (ref braced $given)
}

# A sequence by its GramRef: its name, its summary, and its file.
export def "get sequence" [
    ref?: string
]: [
    nothing -> record<name: string, summary: string, file: path>
    string -> record<name: string, summary: string, file: path>
] {
    let given = (one_given $ref $in 'ref')
    use ../lib/model
    use ../lib/ref
    model sequence (ref braced $given)
}

# Sequences by their GramRefs, a table in the order asked.
export def "list sequence" [
    refs?: list<string>
]: [
    nothing -> table<name: string, summary: string, file: path>
    list<string> -> table<name: string, summary: string, file: path>
] {
    let given = (one_given $refs $in 'refs')
    use ../lib/model
    use ../lib/ref
    model sequence (ref braced $given)
}

# A protocol by its GramRef: its name, summary, conditions, and file.
export def "get protocol" [
    ref?: string
]: [
    nothing -> record<
        name: string, summary: string, apply: table<on: string>, file: path
    >
    string -> record<
        name: string, summary: string, apply: table<on: string>, file: path
    >
] {
    let given = (one_given $ref $in 'ref')
    use ../lib/model
    use ../lib/ref
    model protocol (ref braced $given)
}

# Protocols by their GramRefs, a table in the order asked.
export def "list protocol" [
    refs?: list<string>
]: [
    nothing -> table<
        name: string, summary: string, apply: table<on: string>, file: path
    >
    list<string> -> table<
        name: string, summary: string, apply: table<on: string>, file: path
    >
] {
    let given = (one_given $refs $in 'refs')
    use ../lib/model
    use ../lib/ref
    model protocol (ref braced $given)
}

# An iter's next, now, and last states by its iter ref, in one record.
export def "get state" [
    ref?: string
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
    string -> record<
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
    let given = (one_given $ref $in 'ref')
    use ../lib/model
    use ../lib/ref
    model state (ref braced $given)
}

# Iters' states by their iter refs, a table in the order asked.
export def "list state" [
    refs?: list<string>
]: [
    nothing -> table<
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
    list<string> -> table<
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
    let given = (one_given $refs $in 'refs')
    use ../lib/model
    use ../lib/ref
    model state (ref braced $given)
}

# New iters, log entries, campaigns, and tasks, each scaffolded.
export def new []: nothing -> string {
    help gram new
}

# A new iter scaffolded: its empty indices, its fresh state, its empty bootstrap.
export def "new iter" [
    iter: string
]: nothing -> record<iter: string, path: directory, files: list<path>> {
    use ../lib/iter
    iter new $iter
}

# A new entry in an iter's log: its index item and a stub titled with its rev.
export def "new log" [
    iter: string
    summary: string
]: nothing -> record<rev: int, summary: string, file: path> {
    use ../lib/log
    log new $iter $summary
}

# A campaign scaffolded into a pool at criteria, as get campaign returns it.
export def "new campaign" [
    iter: string
    pool: string
    campaign: string
    summary: string
]: [
    nothing -> record<
        campaign: string, pool: string, summary: string, stage: string,
        tasks: table<task: string, summary: string>, file: path
    >
] {
    use ../lib/plan
    plan new campaign $iter $pool $campaign $summary
}

# A task scaffolded under its plan namepath at criteria, as get task returns it.
export def "new task" [
    iter: string
    task: string
    summary: string
]: [
    nothing -> record<
        task: string, campaign: string, pool: string, summary: string,
        stage: string, tasks: table<task: string, summary: string>,
        file: oneof<nothing, path>
    >
] {
    use ../lib/plan
    plan new task $iter $task $summary
}

# An iter's GramLog.
export def log []: nothing -> string {
    help gram log
}

# Every entry but the newest 20 moved into its old/log shard and its index.
export def "log prune" [
    iter: string
]: nothing -> record<kept: int, moved: int, shards: list<path>> {
    use ../lib/log
    log prune $iter
}

# A GramRef's path and indexed summary, the ref braced or braceless.
export def ref [
    ref?: string
]: [
    nothing -> record<
        ref: string, path: oneof<nothing, path>,
        summary: oneof<nothing, string>
    >
    string -> record<
        ref: string, path: oneof<nothing, path>,
        summary: oneof<nothing, string>
    >
] {
    let given = (one_given $ref $in 'ref')
    use ../lib/ref
    ref resolve (ref braced $given)
}

# GramRefs' paths and indexed summaries, a table in the order asked.
export def "list ref" [
    refs?: list<string>
]: [
    nothing -> table<
        ref: string, path: oneof<nothing, path>,
        summary: oneof<nothing, string>
    >
    list<string> -> table<
        ref: string, path: oneof<nothing, path>,
        summary: oneof<nothing, string>
    >
] {
    let given = (one_given $refs $in 'refs')
    use ../lib/ref
    ref resolve (ref braced $given)
}

# An iter's GramState.
export def state []: nothing -> string {
    help gram state
}

# An iter's state rolled: now to last, next to now, and the ptr into next.
export def "state roll" [
    iter: string
    ptr: string
]: nothing -> int {
    use ../lib/ref
    use ../lib/state
    state advance $iter (ref braced $ptr)
}

# An iter's state rolled fresh: now to last, next to now, none into next.
export def "state fresh" [
    iter: string
]: nothing -> int {
    use ../lib/state
    state fresh $iter
}

# A get's or a list's subject, passed or piped, refused both ways or neither.
def one_given [
    passed: any
    piped: any
    what: string
]: nothing -> any {
    if ($passed != null) and ($piped != null) {
        error make --unspanned $"give the ($what) by argument or by pipe, not both"
    }
    if ($passed == null) and ($piped == null) {
        error make --unspanned $"no ($what) given, by argument or by pipe"
    }
    if $passed != null { $passed } else { $piped }
}
