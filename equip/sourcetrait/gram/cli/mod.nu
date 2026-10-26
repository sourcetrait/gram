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
    ref: string
]: [
    nothing -> record<
        iter: string, path: directory, summary: string,
        nest: oneof<
            record<top: string, summary: string, path: directory>,
            table<sub: string, summary: string, path: directory>
        >
    >
] {
    use ../lib/model
    use ../lib/ref
    model iter (ref braced $ref)
}

# Iters' models by their GramRefs, a table in the order asked.
export def "list iter" [
    refs: list<string>
]: [
    nothing -> table<
        iter: string, path: directory, summary: string,
        nest: oneof<
            record<top: string, summary: string, path: directory>,
            table<sub: string, summary: string, path: directory>
        >
    >
] {
    use ../lib/model
    use ../lib/ref
    model iter (ref braced $refs)
}

# A log entry by its GramRef: its rev, its summary, and its file.
export def "get log" [
    ref: string
]: nothing -> record<rev: int, summary: string, file: path> {
    use ../lib/model
    use ../lib/ref
    model log (ref braced $ref)
}

# Log entries by their GramRefs, a table in the order asked.
export def "list log" [
    refs: list<string>
]: nothing -> table<rev: int, summary: string, file: path> {
    use ../lib/model
    use ../lib/ref
    model log (ref braced $refs)
}

# A campaign's index entry by its plan ref, with its pool and file.
export def "get campaign" [
    ref: string
]: [
    nothing -> record<
        campaign: string, pool: string, summary: string, stage: string,
        tasks: table<task: string, summary: string>, file: path
    >
] {
    use ../lib/model
    use ../lib/ref
    model campaign (ref braced $ref)
}

# Campaigns' index entries by their plan refs, a table in the order asked.
export def "list campaign" [
    refs: list<string>
]: [
    nothing -> table<
        campaign: string, pool: string, summary: string, stage: string,
        tasks: table<task: string, summary: string>, file: path
    >
] {
    use ../lib/model
    use ../lib/ref
    model campaign (ref braced $refs)
}

# A task's index entry by its plan ref, with its campaign, pool, and file.
export def "get task" [
    ref: string
]: [
    nothing -> record<
        task: string, campaign: string, pool: string, summary: string,
        stage: string, tasks: table<task: string, summary: string>,
        file: oneof<nothing, path>
    >
] {
    use ../lib/model
    use ../lib/ref
    model task (ref braced $ref)
}

# Tasks' index entries by their plan refs, a table in the order asked.
export def "list task" [
    refs: list<string>
]: [
    nothing -> table<
        task: string, campaign: string, pool: string, summary: string,
        stage: string, tasks: table<task: string, summary: string>,
        file: oneof<nothing, path>
    >
] {
    use ../lib/model
    use ../lib/ref
    model task (ref braced $refs)
}

# A sequence by its GramRef: its name, its summary, and its file.
export def "get sequence" [
    ref: string
]: nothing -> record<name: string, summary: string, file: path> {
    use ../lib/model
    use ../lib/ref
    model sequence (ref braced $ref)
}

# Sequences by their GramRefs, a table in the order asked.
export def "list sequence" [
    refs: list<string>
]: nothing -> table<name: string, summary: string, file: path> {
    use ../lib/model
    use ../lib/ref
    model sequence (ref braced $refs)
}

# A protocol by its GramRef: its name, summary, conditions, and file.
export def "get protocol" [
    ref: string
]: [
    nothing -> record<
        name: string, summary: string, apply: table<on: string>, file: path
    >
] {
    use ../lib/model
    use ../lib/ref
    model protocol (ref braced $ref)
}

# Protocols by their GramRefs, a table in the order asked.
export def "list protocol" [
    refs: list<string>
]: [
    nothing -> table<
        name: string, summary: string, apply: table<on: string>, file: path
    >
] {
    use ../lib/model
    use ../lib/ref
    model protocol (ref braced $refs)
}

# An iter's next, now, and last states by its iter ref, in one record.
export def "get state" [
    ref: string
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
    use ../lib/model
    use ../lib/ref
    model state (ref braced $ref)
}

# Iters' states by their iter refs, a table in the order asked.
export def "list state" [
    refs: list<string>
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
] {
    use ../lib/model
    use ../lib/ref
    model state (ref braced $refs)
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

# Each GramRef's path and summary, an iter's top or subiters, a record or table.
export def ref [
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
    use ../lib/ref
    ref resolve (ref braced $ref)
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
