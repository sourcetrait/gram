use equip/sourcetrait/gram/lib/model
use equip/sourcetrait/gram/lib/ref

# Campaigns' index entries by their plan refs, each with its pool and file.
export def main [args: record<refs: list<string>>]: nothing -> record<campaigns: table<campaign: string, pool: string, summary: string, stage: string, tasks: table<task: string, summary: string>, file: path>> {
    { campaigns: (model campaign (ref braced $args.refs)) }
}
