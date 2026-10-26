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

# An iter's GramIter.
export def iter []: nothing -> string {
    help gram iter
}

# A new iter scaffolded: its empty indices, its fresh state, its empty bootstrap.
export def "iter new" [
    iter: string
]: nothing -> record<iter: string, path: directory, files: list<path>> {
    use ../lib/iter
    iter new $iter
}

# An iter's GramLog.
export def log []: nothing -> string {
    help gram log
}

# The newest entry in an iter's log: its rev, its summary, and its file.
export def "log last" [
    iter: string
]: nothing -> record<rev: int, summary: string, file: path> {
    use ../lib/log
    log latest $iter
}

# One entry in an iter's log by its rev, or a table of them by a list of revs.
export def "log rev" [
    iter: string
    rev: oneof<int, list<int>>
]: [
    nothing -> oneof<
        record<rev: int, summary: string, file: path>,
        table<rev: int, summary: string, file: path>
    >
] {
    use ../lib/log
    log rev $iter $rev
}

# A new entry in an iter's log: its index item and a stub titled with its rev.
export def "log new" [
    iter: string
    summary: string
]: nothing -> record<rev: int, summary: string, file: path> {
    use ../lib/log
    log new $iter $summary
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
            nest: oneof<
                nothing,
                record<top: string, summary: string, path: directory>,
                table<sub: string, summary: string, path: directory>
            >
        >,
        table<
            ref: string, path: oneof<nothing, path>,
            summary: oneof<nothing, string>,
            nest: oneof<
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

# A sequence by name, or a table of them by a list of names.
export def sequence [
    iter: string
    sequence: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<name: string, summary: string, file: path>,
        table<name: string, summary: string, file: path>
    >
] {
    use ../lib/sequence
    sequence $iter $sequence
}

# A protocol by name, or a table of them by a list of names.
export def protocol [
    iter: string
    protocol: oneof<list<string>, string>
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
    use ../lib/protocol
    protocol $iter $protocol
}

# An iter's GramPlan.
export def plan []: nothing -> string {
    help gram plan
}

# A campaign's index entry from whichever pool lists it, with its pool and file.
export def "plan campaign" [
    iter: string
    campaign: string
]: [
    nothing -> record<
        campaign: string, pool: string, summary: string, stage: string,
        tasks: table<task: string, summary: string>, file: path
    >
] {
    use ../lib/plan
    plan campaign $iter $campaign
}

# A task's index entry by its plan namepath, with its campaign, pool, and file.
export def "plan task" [
    iter: string
    task: string
]: [
    nothing -> record<
        task: string, campaign: string, pool: string, summary: string,
        stage: string, tasks: table<task: string, summary: string>,
        file: oneof<nothing, path>
    >
] {
    use ../lib/plan
    plan task $iter $task
}

# New entries in an iter's GramPlan.
export def "plan new" []: nothing -> string {
    help gram plan new
}

# A campaign scaffolded into a pool at criteria, returned as campaign returns it.
export def "plan new campaign" [
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

# A task scaffolded under its plan namepath at criteria, returned as task does.
export def "plan new task" [
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

# An iter's GramState.
export def state []: nothing -> string {
    help gram state
}

# An iter's now state: its rev, its ptr, and the file its ptr names.
export def "state now" [
    iter: string
]: [
    nothing -> record<
        rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
    >
] {
    use ../lib/state
    state now $iter
}

# An iter's next state: its rev, its ptr, and the file its ptr names.
export def "state next" [
    iter: string
]: [
    nothing -> record<
        rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
    >
] {
    use ../lib/state
    state next $iter
}

# An iter's last state: its rev, its ptr, and the file its ptr names.
export def "state last" [
    iter: string
]: [
    nothing -> record<
        rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>
    >
] {
    use ../lib/state
    state latest $iter
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
    use ../lib/state
    state states $iter
}
