use equip/sourcetrait/gram/lib/model
use equip/sourcetrait/gram/lib/ref

# Quotes by their GramRefs: each one's name, summary, and file.
export def main [data: record<refs: list<string>>]: nothing -> record<quotes: table<quote: string, summary: string, file: path>> {
    { quotes: (model quote (ref braced $data.refs)) }
}
