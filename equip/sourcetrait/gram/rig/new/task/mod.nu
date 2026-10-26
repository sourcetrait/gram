use equip/sourcetrait/gram/lib/plan

# New tasks in order, each scaffolded under its plan namepath at criteria.
export def main [args: record<tasks: table<iter: string, task: string, summary: string>>]: nothing -> record<tasks: table<task: string, campaign: string, pool: string, summary: string, stage: string, tasks: table<task: string, summary: string>, file: oneof<nothing, path>>> {
    mut made = []
    for entry in $args.tasks {
        $made = ($made | append (plan new task $entry.iter $entry.task $entry.summary))
    }
    { tasks: $made }
}
