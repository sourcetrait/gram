use equip/sourcetrait/gram/lib/plan

# New campaigns in order, each scaffolded into its pool at criteria.
export def main [args: record<campaigns: table<iter: string, pool: string, campaign: string, summary: string>>]: nothing -> record<campaigns: table<campaign: string, pool: string, summary: string, stage: string, tasks: table<task: string, summary: string>, file: path>> {
    mut made = []
    for entry in $args.campaigns {
        let one = (
            plan new campaign $entry.iter $entry.pool $entry.campaign $entry.summary
        )
        $made = ($made | append $one)
    }
    { campaigns: $made }
}
