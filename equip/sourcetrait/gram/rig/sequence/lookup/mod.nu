use equip/sourcetrait/gram/lib/sequence

# A sequence by name: its summary and its file.
export def main [args: record<iter: string, sequence: string>]: nothing -> record<name: string, summary: string, file: path> {
    sequence $args.iter $args.sequence
}
