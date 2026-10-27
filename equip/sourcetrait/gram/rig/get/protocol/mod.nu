use equip/sourcetrait/gram/lib/model
use equip/sourcetrait/gram/lib/ref

# Protocols by their GramRefs: each one's name, summary, conditions, and file.
export def main [data: record<refs: list<string>>]: nothing -> record<protocols: table<name: string, summary: string, apply: table<on: string>, file: path>> {
    { protocols: (model protocol (ref braced $data.refs)) }
}
