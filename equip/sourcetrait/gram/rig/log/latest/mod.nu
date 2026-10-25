use equip/sourcetrait/gram/lib/log

# The newest entry in an iter's log: its rev, its summary, and its file.
export def main [args: record<iter: string>]: nothing -> record<rev: int, summary: string, file: path> {
    log latest $args.iter
}
