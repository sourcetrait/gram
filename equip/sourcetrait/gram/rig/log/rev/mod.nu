use equip/sourcetrait/gram/lib/log

# Entries in an iter's log by their revs, in the order asked.
export def main [args: record<iter: string, revs: list<int>>]: nothing -> record<entries: table<rev: int, summary: string, file: path>> {
    { entries: (log rev $args.iter $args.revs) }
}
