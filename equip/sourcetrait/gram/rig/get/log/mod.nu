use equip/sourcetrait/gram/lib/log

# An iter's log entries by rev in the order asked, the newest for none asked.
export def main [args: record<iter: string, revs: list<int>>]: nothing -> record<entries: table<rev: int, summary: string, file: path>> {
    let entries = if ($args.revs | is-empty) {
        [(log $args.iter)]
    } else {
        log $args.iter $args.revs
    }
    { entries: $entries }
}
