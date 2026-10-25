use equip/sourcetrait/gram/lib/log

# One entry in an iter's log by its rev.
export def main [args: record<iter: string, rev: int>]: nothing -> record<rev: int, summary: string, file: path> {
    log rev $args.iter $args.rev
}
