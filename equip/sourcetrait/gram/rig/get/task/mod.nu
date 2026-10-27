use equip/sourcetrait/gram/lib/model
use equip/sourcetrait/gram/lib/ref

# Tasks' index entries by their plan refs, with campaign, pool, and file.
export def main [data: record<refs: list<string>>]: nothing -> record<tasks: table<task: string, campaign: string, pool: string, summary: string, stage: string, tasks: table<task: string, summary: string>, file: oneof<nothing, path>>> {
    { tasks: (model task (ref braced $data.refs)) }
}
