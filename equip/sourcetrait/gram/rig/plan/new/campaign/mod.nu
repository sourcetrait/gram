use equip/sourcetrait/gram/lib/plan

# A campaign scaffolded into a pool at criteria, returned as campaign returns it.
export def main [args: record<iter: string, pool: string, campaign: string, summary: string>]: nothing -> record<campaign: string, pool: string, summary: string, stage: string, tasks: table<task: string, summary: string>, file: path> {
    plan new campaign $args.iter $args.pool $args.campaign $args.summary
}
