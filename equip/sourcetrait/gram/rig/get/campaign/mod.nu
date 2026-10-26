use equip/sourcetrait/gram/lib/plan

# A campaign's index entry from whichever pool lists it, with its pool and file.
export def main [args: record<iter: string, campaign: string>]: nothing -> record<campaign: string, pool: string, summary: string, stage: string, tasks: table<task: string, summary: string>, file: path> {
    plan campaign $args.iter $args.campaign
}
