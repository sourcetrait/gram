use equip/sourcetrait/gram/lib/plan

# A task scaffolded under its plan namepath at criteria, returned as task does.
export def main [args: record<iter: string, task: string, summary: string>]: nothing -> record<task: string, campaign: string, pool: string, summary: string, stage: string, tasks: table<task: string, summary: string>, file: oneof<nothing, path>> {
    plan new task $args.iter $args.task $args.summary
}
