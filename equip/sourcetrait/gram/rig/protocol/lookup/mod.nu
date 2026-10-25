use equip/sourcetrait/gram/lib/protocol

# A protocol by name: its summary, its conditions, and its file.
export def main [args: record<iter: string, protocol: string>]: nothing -> record<name: string, summary: string, apply: table<on: string>, file: path> {
    protocol $args.iter $args.protocol
}
