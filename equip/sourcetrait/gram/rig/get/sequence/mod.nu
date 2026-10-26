use equip/sourcetrait/gram/lib/model
use equip/sourcetrait/gram/lib/ref

# Sequences by their GramRefs: each one's name, summary, and file.
export def main [args: record<refs: list<string>>]: nothing -> record<sequences: table<name: string, summary: string, file: path>> {
    { sequences: (model sequence (ref braced $args.refs)) }
}
