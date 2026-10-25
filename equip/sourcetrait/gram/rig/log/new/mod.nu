use equip/sourcetrait/gram/lib/log

# A new entry in an iter's log: its index item and a stub titled with its rev.
export def main [args: record<iter: string, summary: string>]: nothing -> record<rev: int, summary: string, file: path> {
    log new $args.iter $args.summary
}
