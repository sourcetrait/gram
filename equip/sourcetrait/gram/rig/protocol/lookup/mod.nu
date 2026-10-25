use equip/sourcetrait/gram/lib/protocol

# Protocols by name: each one's summary, its conditions, and its file.
export def main [args: record<iter: string, protocols: list<string>>]: nothing -> record<protocols: table<name: string, summary: string, apply: table<on: string>, file: path>> {
    { protocols: (protocol $args.iter $args.protocols) }
}
