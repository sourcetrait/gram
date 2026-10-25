use equip/sourcetrait/gram/lib/plan

# A task's index entry by its plan namepath, with its campaign, pool, and file.
export def main [args: record<iter: string, task: string>]: nothing -> record<task: string, campaign: string, pool: string, summary: string, stage: string, tasks: table<task: string, summary: string>, file: oneof<nothing, path>> {
    plan task $args.iter $args.task
}
