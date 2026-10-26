use equip/sourcetrait/gram/lib/sequence

# Sequences by name: each one's summary and its file.
export def main [args: record<iter: string, sequences: list<string>>]: nothing -> record<sequences: table<name: string, summary: string, file: path>> {
    { sequences: (sequence $args.iter $args.sequences) }
}
